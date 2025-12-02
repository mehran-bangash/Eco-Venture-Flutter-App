import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/video_model.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoViewModelProvider.notifier).fetchVideos();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildVideoCard(VideoModel video, int index) {
    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval((0.1 * index).clamp(0.0, 1.0), 1.0, curve: Curves.easeOutCubic),
    );

    // Check origin
    final bool isTeacher = video.createdBy == 'teacher';

    return FadeTransition(
      opacity: fade,
      child: GestureDetector(
        onTap: () => context.goNamed('videoPlayScreen', extra: video),
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    // Highlight border for Teacher content
                    color: isTeacher ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.25),
                    width: isTeacher ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMAGE + BADGE STACK ---
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            video.thumbnailUrl ?? "",
                            height: 13.h, // Increased slightly
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 13.h,
                              color: Colors.grey[300],
                              child: Center(child: Icon(Icons.broken_image, color: Colors.redAccent, size: 10.w)),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(height: 13.h, color: Colors.black12);
                            },
                          ),
                        ),

                        // --- BADGE ---
                        Positioned(
                          top: 8, left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                            decoration: BoxDecoration(
                              color: isTeacher ? Colors.amber : Colors.cyan,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isTeacher ? Icons.school : Icons.public, size: 12.sp, color: Colors.black87),
                                SizedBox(width: 1.w),
                                Text(
                                  isTeacher ? "Classroom" : "Global",
                                  style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video.duration,
                                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
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
        ),
      ),
    );
  }

  Widget _animatedBackground({required Widget child}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF283593), Color(0xFF6A1B9A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoViewModelProvider);

    return Scaffold(
      body: _animatedBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                  child: Text(
                    "Explore Nature Videos",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: videoState.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.75, // Adjusted aspect ratio
                    ),
                    itemCount: videoState.videos?.length,
                    itemBuilder: (context, index) {
                      final video = videoState.videos?[index];
                      return _buildVideoCard(video!, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}