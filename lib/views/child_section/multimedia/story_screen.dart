import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Changed
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Import your models and providers
import '../../../models/story_model.dart';
import '../../../viewmodels/child_view_model/multimedia_content/video_story_provider.dart';

class StoryScreen extends ConsumerStatefulWidget { // Changed
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState(); // Changed
}

class _StoryScreenState extends ConsumerState<StoryScreen> // Changed
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Hardcoded list is no longer needed
  // final List<Map<String, dynamic>> stories = [ ... ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Fetch data from Firebase when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storyViewModelProvider.notifier).fetchStories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Changed parameter from Map to StoryModel
  Widget _buildStoryCard(StoryModel story, int index) {
    final fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1 * index, 1.0, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: fade,
      child: GestureDetector(
        // Pass the real story object to the next screen
        onTap: () => context.goNamed('storyPlayScreen', extra: story),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    // Fixed .withValues to .withOpacity
                    const Color(0xFF2F5755).withValues(alpha: 0.95),
                    const Color(0xFF0D324D).withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                    // Changed from Image.asset to Image.network
                    child: Image.network(
                      story.thumbnailUrl, // Use data from Firebase
                      height: 12.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Added a loading builder for network images
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 12.h,
                          color: Colors.black12,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        height: 12.h,
                        color: Colors.grey[300],
                        child: Center(
                          child: const Icon(Icons.broken_image,
                              color: Colors.redAccent, size: 40),
                        ),
                      ),
                    ),
                  ),

                  // Details
                  Expanded(
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.title, // Use data from Firebase
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
                                // Calculate pages from the list
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
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
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

  // ===== MAIN UI =====
  @override
  Widget build(BuildContext context) {
    // Watch the state from the ViewModel
    final storyState = ref.watch(storyViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D324D), // Deep Ocean Blue
              Color(0xFF2F5755), // Teal Green blend
              Color(0xFF1E3C40), // Muted dark blend
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(2.h),
            // Use a Builder to handle loading/error states
            child: Builder(
              builder: (context) {
                // 1. Loading State
                if (storyState.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                // 2. Error State
                if (storyState.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${storyState.error}',
                      style: GoogleFonts.poppins(color: Colors.redAccent),
                    ),
                  );
                }

                // 3. Empty State
                if (storyState.stories == null || storyState.stories!.isEmpty) {
                  return Center(
                    child: Text(
                      'No stories found.',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                  );
                }

                // 4. Success State (Data is available)
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.h,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: storyState.stories!.length, // Use data length
                  itemBuilder: (context, index) {
                    final story = storyState.stories![index]; // Use data
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