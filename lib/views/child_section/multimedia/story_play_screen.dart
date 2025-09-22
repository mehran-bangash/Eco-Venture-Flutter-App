import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/helper/speak_story.dart';
import '../../../viewmodels/child_view_model/multimedia_content/story_provider.dart';


class StoryPlayScreen extends ConsumerStatefulWidget {

  const StoryPlayScreen({super.key,});

  @override
  ConsumerState<StoryPlayScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryPlayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPlaying = false;
  final String storyTitle='this is for testing';

  @override
  void initState() {
    super.initState();

    // Future<void> listVoices() async {
    //   var voices = await flutterTts.getVoices;
    //   print("Available Voices: $voices");
    // }To check the list of voice

    // When narration finishes automatically
    flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });

    // When narration is stopped manually
    flutterTts.setCancelHandler(() {
      setState(() => _isPlaying = false);
    });
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

  @override
  Widget build(BuildContext context) {
    final storyPages = ref.watch(storyProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteBackGroundCard,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          storyTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.goNamed('multiMediaContent'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: storyPages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = storyPages[index];
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
                            image: NetworkImage(page.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          page.text,
                          style: TextStyle(
                            fontSize: 17.sp,
                            height: 1.5,
                            color: Colors.black87,
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
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              storyPages.length,
                  (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                width: _currentPage == index ? 3.w : 2.w,
                height: _currentPage == index ? 3.w : 2.w,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.blue
                      : Colors.blue.withValues(alpha: 0.3),
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
          final storyText = storyPages[_currentPage].text;
          _togglePlay(storyText);
        },
        child: Icon(
          _isPlaying ? Icons.stop : Icons.play_arrow,
          size: 32,
          color: Colors.white,
        ),
      ),


    );
  }
}
