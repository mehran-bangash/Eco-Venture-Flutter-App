import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/story_model.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';
import '../../../services/shared_preferences_helper.dart';

class StoryPlayScreen extends ConsumerStatefulWidget {
  final StoryModel story;

  const StoryPlayScreen({super.key, required this.story});

  @override
  ConsumerState<StoryPlayScreen> createState() => _StoryPlayScreenState();
}

class _StoryPlayScreenState extends ConsumerState<StoryPlayScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  int _currentPage = 0;
  bool _isPlaying = false;
  String? _userId;
  String _selectedLocale = "en-US";

  // Caching for translated text
  final Map<int, String> _urduCache = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted && _isPlaying) {
        if (_currentPage < widget.story.pages.length - 1) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && _isPlaying) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              );
            }
          });
        } else {
          setState(() => _isPlaying = false);
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    ref.read(storyViewModelProvider.notifier).incrementView(widget.story);
    final id = SharedPreferencesHelper.instance.getUserId();
    if (mounted) setState(() => _userId = id);
  }

  void _onLikeTapped(StoryModel currentStory) {
    if (_userId == null) return;
    ref
        .read(storyViewModelProvider.notifier)
        .toggleLikeDislike(
          story: currentStory,
          isLiking: true,
          userId: _userId!,
        );
  }

  void _onDislikeTapped(StoryModel currentStory) {
    if (_userId == null) return;
    ref
        .read(storyViewModelProvider.notifier)
        .toggleLikeDislike(
          story: currentStory,
          isLiking: false,
          userId: _userId!,
        );
  }

  void _showLanguageSelection(String storyText) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Language",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text("English"),
              onTap: () {
                Navigator.pop(context);
                _startReading(storyText, "en-US");
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: const Text("Urdu (اردو)"),
              onTap: () {
                Navigator.pop(context);
                _startReading(storyText, "ur-PK");
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startReading(String text, String locale) async {
    setState(() {
      _selectedLocale = locale;
      _isPlaying = true;
    });

    await _flutterTts.setLanguage(locale);

    String textToSpeak = text;
    if (locale == "ur-PK") {
      // Check cache first
      if (_urduCache.containsKey(_currentPage)) {
        textToSpeak = _urduCache[_currentPage]!;
      } else {
        var translation = await _translator.translate(
          text,
          from: 'en',
          to: 'ur',
        );
        textToSpeak = translation.text;
        _urduCache[_currentPage] = textToSpeak; // Save to cache
      }
    }

    await _flutterTts.speak(textToSpeak);
  }

  Future<void> _togglePlay(String storyText) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      _showLanguageSelection(storyText);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyViewModelProvider);

    final StoryModel? currentStory = storyState.stories
        ?.cast<StoryModel?>()
        .firstWhere(
          (s) => s?.id == widget.story.id,
          orElse: () => widget.story,
        );

    final pages = currentStory?.pages ?? widget.story.pages;

    final likeColor = (currentStory?.userLikes[_userId] == true)
        ? Colors.blue
        : Colors.grey;
    final dislikeColor = (currentStory?.userLikes[_userId] == false)
        ? Colors.red
        : Colors.grey;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed('multiMediaContent');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FE),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              _flutterTts.stop();
              context.goNamed('multiMediaContent');
            },
          ),
          title: Text(
            widget.story.title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.red),
              onPressed: () {
                _flutterTts.stop();
                context.pushNamed(
                  'childReportIssueScreen',
                  extra: {
                    'id': widget.story.id,
                    'title': widget.story.title,
                    'type': 'Story',
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  if (_isPlaying) {
                    _startReading(pages[index].text, _selectedLocale);
                  }
                },
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Caching for Images
                        Container(
                          margin: EdgeInsets.all(5.w),
                          height: 35.h,
                          width: 100.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: page.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            page.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              height: 1.6,
                            ),
                          ),
                        ),
                        if (index == pages.length - 1)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildActionButton(
                                  Icons.thumb_up,
                                  "${currentStory?.likes}",
                                  likeColor,
                                  () => _onLikeTapped(currentStory!),
                                ),
                                SizedBox(width: 8.w),
                                _buildActionButton(
                                  Icons.thumb_down,
                                  "${currentStory?.dislikes}",
                                  dislikeColor,
                                  () => _onDislikeTapped(currentStory!),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => Container(
                  margin: EdgeInsets.all(1.w),
                  width: 2.w,
                  height: 2.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (pages.isNotEmpty) _togglePlay(pages[_currentPage].text);
          },
          backgroundColor: _isPlaying
              ? Colors.redAccent
              : const Color(0xFF8E2DE2),
          icon: Icon(
            _isPlaying ? Icons.stop : Icons.volume_up,
            color: Colors.white,
          ),
          label: Text(
            _isPlaying ? "Stop" : "Read",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
