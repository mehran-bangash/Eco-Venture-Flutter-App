import 'package:chewie/chewie.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:collection/collection.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';


class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  final String videoUrl;
  final String title;
  final String duration;
  final int views;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.title,
    required this.duration,
    required this.views,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _viewAdded = false;

  String localUserId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load userId from SharedPreferences
    ref.read(videoViewModelProvider.notifier).fetchVideos();
    _initPlayer();
  }

  Future<void> _loadUserId() async {
    localUserId = await SharedPreferencesHelper.instance.getUserId() ?? "";
    setState(() {});
  }

  Future<void> _initPlayer() async {
    _videoController = VideoPlayerController.network(widget.videoUrl);

    await _videoController.initialize();

    if (!_viewAdded) {
      ref.read(videoViewModelProvider.notifier)
          .incrementView(widget.videoId);
      _viewAdded = true;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      aspectRatio: _videoController.value.aspectRatio,
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoViewModelProvider);

    final video = videoState.videos.firstWhereOrNull((v) => v.id == widget.videoId);

    final likeColor = (video?.userLikes[localUserId] == true)
        ? Colors.blue
        : Colors.grey[700]!;

    final dislikeColor = (video?.userLikes[localUserId] == false)
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
        appBar: AppBar(
             leading: GestureDetector(
                   onTap: () {
                     context.goNamed('multiMediaContent');
                   },
                 child: Icon(Icons.arrow_back_ios,)),
            title: Text(widget.title)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: _videoController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(widget.duration, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${video?.views ?? widget.views}",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _action(Icons.thumb_up, "${video?.likes ?? 0}", () {


                          if (localUserId.isEmpty) {

                            return;
                          }

                          ref.read(videoViewModelProvider.notifier)
                              .toggleVideoLikeDislike(
                            videoId: widget.videoId,
                            userId: localUserId,
                            isLiking: true,
                          );
                        }, iconColor: likeColor),

                        _action(Icons.thumb_down, "${video?.dislikes ?? 0}", () {

                          if (localUserId.isEmpty) {
                            return;
                          }

                          ref.read(videoViewModelProvider.notifier)
                              .toggleVideoLikeDislike(
                            videoId: widget.videoId,
                            userId: localUserId,
                            isLiking: false,
                          );
                        }, iconColor: dislikeColor),

                        _action(Icons.share, "Share", () {}),
                        _action(Icons.bookmark_add, "Save", () {}),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
