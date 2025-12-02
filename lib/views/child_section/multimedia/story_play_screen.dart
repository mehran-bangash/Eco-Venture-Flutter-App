import 'dart:io'; // FIX: Added import for File
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  int _currentPage = 0;
  bool _isPlaying = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if(mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadInitialData() async {
    ref.read(storyViewModelProvider.notifier).incrementView(widget.story);
    final id = await SharedPreferencesHelper.instance.getUserId();
    if (mounted) setState(() => _userId = id);
  }

  Future<void> _togglePlay(String storyText) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      if (storyText.isNotEmpty) {
        setState(() => _isPlaying = true);
        await _flutterTts.speak(storyText);
      }
    }
  }

  void _onLikeTapped(StoryModel currentStory) {
    if (_userId == null) return;
    ref.read(storyViewModelProvider.notifier).toggleLikeDislike(
        story: currentStory,
        isLiking: true,
        userId: _userId!
    );
  }

  void _onDislikeTapped(StoryModel currentStory) {
    if (_userId == null) return;
    ref.read(storyViewModelProvider.notifier).toggleLikeDislike(
        story: currentStory,
        isLiking: false,
        userId: _userId!
    );
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

    // Get Live Data
    final StoryModel? currentStory = storyState.stories?.cast<StoryModel?>().firstWhere(
          (s) => s?.id == widget.story.id,
      orElse: () => widget.story,
    );

    final pages = currentStory?.pages ?? widget.story.pages;
    final bool isLastPage = _currentPage == pages.length - 1;

    final likeColor = (currentStory?.userLikes[_userId] == true) ? Colors.blue : Colors.grey;
    final dislikeColor = (currentStory?.userLikes[_userId] == false) ? Colors.red : Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () { _flutterTts.stop(); context.pop(); },
        ),
        title: Text(widget.story.title, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 17.sp)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                _flutterTts.stop();
                setState(() { _currentPage = index; _isPlaying = false; });
              },
              itemBuilder: (context, index) {
                final page = pages[index];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5.w),
                        height: 35.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          image: (page.imageUrl.isNotEmpty)
                              ? DecorationImage(image: NetworkImage(page.imageUrl), fit: BoxFit.cover)
                              : null,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(page.text, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16.sp, height: 1.6)),
                      ),

                      // --- FIXED: Show Like/Dislike ON THE PAGE if it's the last one ---
                      if (index == pages.length - 1)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(Icons.thumb_up, "${currentStory?.likes}", likeColor, () => _onLikeTapped(currentStory!)),
                              SizedBox(width: 8.w),
                              _buildActionButton(Icons.thumb_down, "${currentStory?.dislikes}", dislikeColor, () => _onDislikeTapped(currentStory!)),
                            ],
                          ),
                        ),

                      SizedBox(height: 10.h), // Spacer for FAB
                    ],
                  ),
                );
              },
            ),
          ),

          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) => Container(
              margin: EdgeInsets.all(1.w),
              width: 2.w, height: 2.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == i ? Colors.blue : Colors.grey.shade300),
            )),
          ),
          SizedBox(height: 2.h),
        ],
      ),

      // --- FIXED: FAB IS ALWAYS VISIBLE ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (pages.isNotEmpty) _togglePlay(pages[_currentPage].text);
        },
        backgroundColor: _isPlaying ? Colors.redAccent : const Color(0xFF8E2DE2),
        icon: Icon(_isPlaying ? Icons.stop : Icons.volume_up, color: Colors.white),
        label: Text(_isPlaying ? "Stop" : "Read", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}