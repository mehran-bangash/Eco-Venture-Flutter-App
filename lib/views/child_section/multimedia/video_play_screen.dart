import 'dart:math' as math;
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:collection/collection.dart';

import '../../../models/video_model.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoModel videoData;

  const VideoPlayerScreen({
    super.key,
    required this.videoData,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late final AnimationController _masterController;

  bool _isInitialized = false;
  bool _viewAdded = false;
  String _localUserId = "";

  // Theme Constants
  final Color _primaryDark = const Color(0xFF0F172A);
  final Color _subText = const Color(0xFF64748B);
  final Color _slate200 = const Color(0xFFE2E8F0);
  final Color _bgSurface = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _loadUser();
    _initPlayer();
  }

  Future<void> _loadUser() async {
    _localUserId = SharedPreferencesHelper.instance.getUserId() ?? "";
    if (mounted) setState(() {});
  }

  Future<void> _initPlayer() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoData.videoUrl));

    try {
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFF43F5E),
          handleColor: const Color(0xFFF43F5E),
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white10,
        ),
      );

      setState(() {
        _isInitialized = true;
      });

      if (!_viewAdded) {
        ref.read(videoViewModelProvider.notifier).incrementView(widget.videoData);
        _viewAdded = true;
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoViewModelProvider);
    final video = videoState.videos.firstWhereOrNull((v) => v.id == widget.videoData.id) ?? widget.videoData;
    final isLiked = video.userLikes[_localUserId] == true;
    final isDisliked = video.userLikes[_localUserId] == false;

    return Scaffold(
      backgroundColor: _bgSurface,
      body: AnimatedBuilder(
        animation: _masterController,
        builder: (context, _) {
          final t = _masterController.value;
          return Stack(
            children: [
              // Background Gradient & Blobs
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF1F5F9), Colors.white, Color(0xFFF8FAFC)],
                  ),
                ),
              ),
              Positioned(
                top: 20.h, right: -10.w,
                child: _buildGlowBlob(const Color(0xFF06B6D4).withOpacity(0.1), 60.w, t, 0),
              ),
              Positioned(
                bottom: 10.h, left: -10.w,
                child: _buildGlowBlob(const Color(0xFFF43F5E).withOpacity(0.08), 70.w, t, 2),
              ),

              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    _buildVideoArea(),
                    Expanded(child: _buildInfoPanel(video, isLiked, isDisliked)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGlowBlob(Color color, double size, double t, double phase) {
    return Transform.translate(
      offset: Offset(30 * math.sin(t * 2 * math.pi + phase), 30 * math.cos(t * 2 * math.pi + phase)),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _slate200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Icon(Icons.arrow_back_ios_new, color: _primaryDark, size: 17.sp),
            ),
          ),
          const Spacer(),
          Text("Video Player", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w900, color: _primaryDark)),
          const Spacer(),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      height: 28.h,
      width: 100.w,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _isInitialized && _chewieController != null
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E))),
    );
  }

  Widget _buildInfoPanel(VideoModel video, bool isLiked, bool isDisliked) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(video.title, style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _primaryDark)),
              ),
              IconButton(
                onPressed: () => context.pushNamed('childReportIssueScreen', extra: {'id': video.id, 'title': video.title, 'type': 'Video'}),
                icon: Icon(Icons.flag_rounded, color: const Color(0xFFF43F5E).withOpacity(0.6)),
              )
            ],
          ),
          Row(
            children: [
              Text("${video.views} views", style: GoogleFonts.poppins(color: _subText, fontSize: 13.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 2.w),
              Icon(Icons.circle, size: 4, color: _slate200),
              SizedBox(width: 2.w),
              Text(video.duration, style: GoogleFonts.poppins(color: _subText, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 3.h),

          // Action Buttons with High-Depth Elevation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionBtn(
                icon: isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                label: "${video.likes}",
                isActive: isLiked,
                activeColor: const Color(0xFF3B82F6),
                onTap: () {
                  if (_localUserId.isNotEmpty) {
                    ref.read(videoViewModelProvider.notifier).toggleVideoLikeDislike(video: video, userId: _localUserId, isLiking: true);
                  }
                },
              ),
              _buildActionBtn(
                icon: isDisliked ? Icons.thumb_down_rounded : Icons.thumb_down_outlined,
                label: "${video.dislikes}",
                isActive: isDisliked,
                activeColor: const Color(0xFFF43F5E),
                onTap: () {
                  if (_localUserId.isNotEmpty) {
                    ref.read(videoViewModelProvider.notifier).toggleVideoLikeDislike(video: video, userId: _localUserId, isLiking: false);
                  }
                },
              ),
              _buildActionBtn(
                icon: Icons.share_rounded,
                label: "Share",
                isActive: false,
                isAvailable: false,
                onTap: () => _showComingSoonToast(),
              ),
              _buildActionBtn(
                icon: Icons.bookmark_rounded,
                label: "Save",
                isActive: false,
                isAvailable: false,
                onTap: () => _showComingSoonToast(),
              ),
            ],
          ),

          SizedBox(height: 3.h),
          Text("Description", style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.w800, fontSize: 16.sp)),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(4.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _slate200),
            ),
            child: Text(
              video.description.isNotEmpty ? video.description : "No description available for this adventure.",
              style: GoogleFonts.poppins(color: _subText, fontSize: 14.sp, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    Color activeColor = const Color(0xFF3B82F6),
    bool isAvailable = true,
    required VoidCallback onTap
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? activeColor : _slate200),
              boxShadow: [
                BoxShadow(
                  color: isActive ? activeColor.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                  blurRadius: 15, offset: const Offset(0, 8),
                )
              ],
            ),
            child: Icon(icon, color: isActive ? Colors.white : (isAvailable ? _subText : _slate200), size: 19.sp),
          ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          isAvailable ? label : "Soon",
          style: GoogleFonts.poppins(color: isAvailable ? (isActive ? activeColor : _subText) : _slate200, fontSize: 11.sp, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _showComingSoonToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Feature coming in the next update! 🚀", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF06B6D4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}