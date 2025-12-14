import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:collection/collection.dart';

import '../../../models/video_model.dart'; // Import Model
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  // Accept the full VideoModel to ensure we have createdBy/adminId
  final VideoModel videoData;

  const VideoPlayerScreen({
    super.key,
    required this.videoData,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _viewAdded = false;
  String _localUserId = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initPlayer();
  }

  Future<void> _loadUser() async {
    _localUserId = await SharedPreferencesHelper.instance.getUserId() ?? "";
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
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white24,
        ),
      );

      setState(() {
        _isInitialized = true;
      });

      // FIX: Pass the full object
      if (!_viewAdded) {
        ref.read(videoViewModelProvider.notifier).incrementView(widget.videoData);
        _viewAdded = true;
      }
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoViewModelProvider);

    // Get fresh data from state
    final video = videoState.videos?.firstWhereOrNull((v) => v.id == widget.videoData.id) ?? widget.videoData;

    // Determine active colors
    final isLiked = video.userLikes[_localUserId] == true;
    final isDisliked = video.userLikes[_localUserId] == false;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E15),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- VIDEO PLAYER AREA ---
            Stack(
              children: [
                Container(
                  height: 30.h,
                  width: 100.w,
                  color: Colors.black,
                  child: _isInitialized && _chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : const Center(child: CircularProgressIndicator(color: Colors.red)),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            // --- INFO ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          video.title,
                          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            context.pushNamed('childReportIssueScreen', extra: {
                              'id': video.id,
                              'title': video.title,
                              'type': 'Video'
                            });
                          },
                          icon: Icon(Icons.flag_rounded, color: Colors.redAccent.withOpacity(0.7)),
                          tooltip: "Report this video",
                        )
                      ],
                    ),
                    SizedBox(height: 1.h),

                    Row(
                      children: [
                        Text("${video.views} views", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13.sp)),
                        SizedBox(width: 2.w),
                        const Icon(Icons.circle, size: 5, color: Colors.grey),
                        SizedBox(width: 2.w),
                        Text(video.duration, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13.sp)),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // --- ACTIONS ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionBtn(
                          icon: isLiked ? Icons.thumb_up_alt : Icons.thumb_up_off_alt,
                          label: "${video.likes}",
                          isActive: isLiked,
                          activeColor: Colors.blue,
                          onTap: () {
                            if (_localUserId.isEmpty) return;
                            // FIX: Pass full object
                            ref.read(videoViewModelProvider.notifier).toggleVideoLikeDislike(
                                video: video, userId: _localUserId, isLiking: true
                            );
                          },
                        ),
                        _buildActionBtn(
                          icon: isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_off_alt,
                          label: "${video.dislikes}",
                          isActive: isDisliked,
                          activeColor: Colors.red,
                          onTap: () {
                            if (_localUserId.isEmpty) return;
                            // FIX: Pass full object
                            ref.read(videoViewModelProvider.notifier).toggleVideoLikeDislike(
                                video: video, userId: _localUserId, isLiking: false
                            );
                          },
                        ),
                        _buildActionBtn(
                          icon: Icons.share_rounded,
                          label: "Share",
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildActionBtn(
                          icon: Icons.bookmark_border_rounded,
                          label: "Save",
                          isActive: false,
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),
                    Divider(color: Colors.white10),
                    SizedBox(height: 2.h),

                    Text("Description", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                    SizedBox(height: 1.h),
                    Text(
                      video.description.isNotEmpty ? video.description : "No description available.",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String label, required bool isActive, Color activeColor = Colors.blue, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Column(
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.white, size: 22.sp),
            SizedBox(height: 0.5.h),
            Text(label, style: GoogleFonts.poppins(color: isActive ? activeColor : Colors.white70, fontSize: 11.sp)),
          ],
        ),
      ),
    );
  }
}