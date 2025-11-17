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
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..forward();

    // ADDED: Fetch data once on start
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
      curve: Interval(
          (0.1 * index).clamp(0.0, 1.0), // Safety clamp
          1.0,
          curve: Curves.easeOutCubic
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: GestureDetector(
        // CHANGED: Pass the video object to the next screen
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
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      // CHANGED: Image.network for Cloudinary URL
                      child: Image.network(
                        video.thumbnailUrl,
                        height: 12.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        // Added simple error builder to match your style
                        errorBuilder: (_, __, ___) => Container(
                          height: 12.h,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.redAccent, size: 10.w),
                          ),
                        ),
                        // Optional: Keep layout while loading
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(height: 12.h, color: Colors.black12);
                        },
                      ),
                    ),

                    /// Content (title + info + play)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title
                            Text(
                              video.title, // CHANGED: from map key to model property
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const Spacer(),

                            /// Duration + Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video.duration, // CHANGED: from map key to model property
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 0.8.h),

                            /// Play Button
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4), width: 1),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 20),
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
      ),
    );
  }


  // Gradient Background (KEPT EXACTLY SAME)
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
    // ADDED: Watch the state
    final videoState = ref.watch(videoViewModelProvider);

    return Scaffold(
      body: _animatedBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Padding(
                  padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                  child: Text(
                    "Explore Nature Videos ",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),


                Expanded(
                  // CHANGED: Logic to handle Loading vs Data
                  child: videoState.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.78,
                    ),
                    // CHANGED: Use real data length
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