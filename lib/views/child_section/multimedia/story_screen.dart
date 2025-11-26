import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/story_model.dart';
// Ensure this provider path is correct for your project
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storyViewModelProvider.notifier).fetchStories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStoryCard(StoryModel story, int index) {
    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1 * index, 1.0, curve: Curves.easeOutCubic),
    );

    // FIX: Handle nullable URL safely
    final String displayImage = story.thumbnailUrl ?? "";

    return FadeTransition(
      opacity: fade,
      child: GestureDetector(
        onTap: () => context.goNamed('storyPlayScreen', extra: story),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2F5755).withOpacity(0.95),
                    const Color(0xFF0D324D).withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: displayImage.isNotEmpty && displayImage.startsWith('http')
                        ? Image.network(
                      displayImage, // FIX: Corrected variable name
                      height: 12.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 12.h,
                          color: Colors.black12,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        );
                      },
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                        : _buildPlaceholder(), // Fallback if URL is null/empty/local
                  ),

                  // Details
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${story.pages.length} Pages",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.8.h),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 12.h,
      color: Colors.white10,
      child: Center(
        child: Icon(Icons.auto_stories, color: Colors.white24, size: 30.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D324D),
              Color(0xFF2F5755),
              Color(0xFF1E3C40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Builder(
              builder: (context) {
                if (storyState.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (storyState.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${storyState.error}',
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  );
                }

                if (storyState.stories == null || storyState.stories!.isEmpty) {
                  return Center(
                    child: Text(
                      'No stories found.',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.h,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: storyState.stories!.length,
                  itemBuilder: (context, index) {
                    final story = storyState.stories![index];
                    return _buildStoryCard(story, index);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}