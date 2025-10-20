import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  // Suggested videos dummy data
  final List<Map<String, String>> suggestedVideos = [
    {
      "image": "https://via.placeholder.com/200x120.png?text=Park+Adventures",
      "title": "Park Adventures",
      "duration": "10 min",
    },
    {
      "image": "https://via.placeholder.com/200x120.png?text=Playtime+Fun",
      "title": "Playtime Fun",
      "duration": "12 min",
    },
    {
      "image": "https://via.placeholder.com/200x120.png?text=Outdoor+Games",
      "title": "Outdoor Games",
      "duration": "8 min",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Load local asset video
    _videoPlayerController = VideoPlayerController.asset("assets/video/test.mp4")
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      allowPlaybackSpeedChanging: true,
      allowFullScreen: true,
      allowMuting: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
         leading: GestureDetector(
           onTap: () {
             context.goNamed('multiMediaContent');
           },
             child: Icon(Icons.arrow_back_ios)),
         centerTitle: true,
        title: Text('Pass title here',style: GoogleFonts.poppins(fontWeight: FontWeight.w600,fontSize: 16.sp,color: Color(0xFF000080)),),
      ) ,
      backgroundColor: AppColors.whiteBackGroundCard,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Video Player ---
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()),
              ),

              // --- Video Details Section ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fun Day at the Park",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111217),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Text("15 min", style: TextStyle(color: Colors.grey)),
                        SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text("4.8", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Like / Dislike / Share / Save
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAction(Icons.thumb_up, "1.2K"),
                        _buildAction(Icons.thumb_down, "23"),
                        _buildAction(Icons.share, "Share"),
                        _buildAction(Icons.bookmark_add, "Save"),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Suggested Section ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  "Suggested",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111217),
                  ),
                ),
              ),

              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: suggestedVideos.length,
                  itemBuilder: (context, index) {
                    final video = suggestedVideos[index];
                    return SuggestedCard(
                      imageUrl: video["image"]!,
                      title: video["title"]!,
                      duration: video["duration"]!,
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

  // Helper for actions
  static Widget _buildAction(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
class SuggestedCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String duration;

  const SuggestedCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111217),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            duration,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
