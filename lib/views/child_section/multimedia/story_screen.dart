import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/story_model.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Professional Theme Palette
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _accentCyan = const Color(0xFF06B6D4);
  final Color _accentAmber = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800)
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
    final bool isTeacher = story.createdBy == 'teacher';
    final Color accentColor = isTeacher ? _accentAmber : _accentCyan;

    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval((0.1 * index).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(fade),
        child: GestureDetector(
          onTap: () => context.goNamed('storyPlayScreen', extra: story),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              // HIGH-DEPTH BORDER
              border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
              boxShadow: [
                // DEEP FLOATING SHADOW
                BoxShadow(
                  color: accentColor.withOpacity(0.12),
                  blurRadius: 25,
                  spreadRadius: -2,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // THUMBNAIL SECTION
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      child: story.thumbnailUrl != null && story.thumbnailUrl!.startsWith('http')
                          ? Image.network(
                        story.thumbnailUrl!,
                        height: 12.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                          : _buildPlaceholder(),
                    ),
                    // CATEGORY BADGE
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isTeacher ? Icons.stars_rounded : Icons.public_rounded, size: 13.sp, color: Colors.white),
                            SizedBox(width: 1.w),
                            Text(
                              isTeacher ? "CLASS" : "GLOBAL",
                              style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // CONTENT SECTION
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(3.5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: _primaryDark,
                            height: 1.1,
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
                              style: GoogleFonts.poppins(fontSize: 11.sp, color: _subText, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.auto_stories_rounded, color: accentColor, size: 18.sp),
                            ),
                          ],
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Center(child: Icon(Icons.auto_stories_rounded, color: _subText, size: 25.sp)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyState = ref.watch(storyViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by parent
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.w, bottom: 2.h, top: 1.h),
                child: Text(
                  "Explore Story Books",
                  style: GoogleFonts.poppins(
                      color: _primaryDark,
                      fontSize: 17.5.sp,
                      fontWeight: FontWeight.w800
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (storyState.isLoading) return Center(child: CircularProgressIndicator(color: _accentAmber));
                    if (storyState.error != null) return Center(child: Text('Error: ${storyState.error}', style: GoogleFonts.poppins(color: Colors.redAccent)));
                    if (storyState.stories == null || storyState.stories!.isEmpty) return Center(child: Text('No stories found.', style: GoogleFonts.poppins(color: _subText)));

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.w,
                        mainAxisSpacing: 2.5.h,
                        childAspectRatio: 0.78,
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
            ],
          ),
        ),
      ),
    );
  }
}