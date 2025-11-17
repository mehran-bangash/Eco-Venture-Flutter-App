import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Import your models, providers, and helpers
import '../../../models/story_model.dart';
import '../../../core/helper/speak_story.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';
import '../../../services/shared_preferences_helper.dart';

class StoryPlayScreen extends ConsumerStatefulWidget {
  // 1. Accept the StoryModel
  final StoryModel story;

  const StoryPlayScreen({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<StoryPlayScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryPlayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPlaying = false;
  String? _userId; // To store the user's ID for like/dislike colors

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // When narration finishes automatically
    flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });

    // When narration is stopped manually
    flutterTts.setCancelHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _loadInitialData() async {
    // 2. Increment view count
    ref.read(storyViewModelProvider.notifier).incrementView(widget.story.id);

    // Get the user ID for setting button colors
    final idFromPrefs = await SharedPreferencesHelper.instance.getUserId();
    if (mounted) {
      setState(() {
        _userId = idFromPrefs;
      });
    }
  }

  Future<void> _togglePlay(String storyText) async {
    if (_isPlaying) {
      await flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      await speakStory(storyText);
      setState(() => _isPlaying = true);
    }
  }

  // --- 3. Add Like/Dislike Handlers ---
  void _onLikeTapped() {
    ref.read(storyViewModelProvider.notifier).toggleLikeDislike(
      storyId: widget.story.id,
      isLiking: true,
    );
  }

  void _onDislikeTapped() {
    ref.read(storyViewModelProvider.notifier).toggleLikeDislike(
      storyId: widget.story.id,
      isLiking: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get real-time like/dislike updates
    final storyState = ref.watch(storyViewModelProvider);

    // Find the current story from the state
    final StoryModel? currentStory = storyState.stories?.firstWhere(
          (s) => s.id == widget.story.id,
      orElse: () => widget.story, // Fallback to the initial story
    );

    // Get the dynamic pages from the story
    final pages = currentStory?.pages ?? widget.story.pages;
    final bool isLastPage = _currentPage == pages.length - 1;

    // Determine button colors
    final likeColor = (currentStory?.userLikes[_userId] == true)
        ? Colors.blue
        : Colors.grey[700]!;
    final dislikeColor = (currentStory?.userLikes[_userId] == false)
        ? Colors.red
        : Colors.grey[700]!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('multiMediaContent');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteBackGroundCard,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Text(
            widget.story.title, // Use real title
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              flutterTts.stop(); // Stop speaking on back
              context.goNamed('multiMediaContent');
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length, // Use real page count
                onPageChanged: (index) {
                  flutterTts.stop(); // Stop speech on page swipe
                  setState(() {
                    _currentPage = index;
                    _isPlaying = false;
                  });
                },
                itemBuilder: (context, index) {
                  final page = pages[index]; // Use real page data
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(4.w),
                          height: 35.h,
                          width: 90.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(2, 2),
                              )
                            ],
                            image: DecorationImage(
                              image: NetworkImage(page.imageUrl), // Use real image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Text(
                            page.text, // Use real text
                            style: GoogleFonts.poppins(
                              fontSize: 17.sp,
                              height: 1.5,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- 4. Conditional Like/Dislike Section ---
            if (isLastPage)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                    ]
                ),
                child: Column(
                  children: [
                    Text(
                      "Did you enjoy this story?",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAction(
                            Icons.thumb_up,
                            "${currentStory?.likes ?? 0}",
                            _onLikeTapped,
                            iconColor: likeColor
                        ),
                        _buildAction(
                            Icons.thumb_down,
                            "${currentStory?.dislikes ?? 0}",
                            _onDislikeTapped,
                            iconColor: dislikeColor
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
            // Show Dots Indicator if NOT the last page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: _currentPage == index ? 3.w : 2.w,
                    height: _currentPage == index ? 3.w : 2.w,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.blue.withOpacity(0.3), // Fixed withOpacity
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 2.h),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            // Speak the text of the *current* page
            if (pages.isNotEmpty) {
              final storyText = pages[_currentPage].text;
              _togglePlay(storyText);
            }
          },
          child: Icon(
            _isPlaying ? Icons.stop : Icons.play_arrow,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- 5. Add Action Button Builder ---
  Widget _buildAction(IconData icon, String label, VoidCallback onTap,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? Colors.grey[700], size: 28.sp),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}