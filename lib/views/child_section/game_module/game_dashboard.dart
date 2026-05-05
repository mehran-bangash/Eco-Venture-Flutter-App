import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GameDashboard extends StatelessWidget {
  const GameDashboard({super.key});

  final List<Map<String, dynamic>> games = const [
    {
      'title': 'Recycling Sorter',
      'description': 'Sort waste to save the ecosystem!',
      'icon': Icons.recycling_rounded,
      'color': Color(0xFF2E7D32),
      'route': 'ecoGame',
      'isActive': true,
    },
    {
      'title': 'Plant Growth',
      'description': 'Water seeds and watch them bloom.',
      'icon': Icons.local_florist_rounded,
      'color': Color(0xFFFFA000),
      'route': 'plantGame',
      'isActive': true,
    },
    {
      'title': 'Circuit Builder',
      'description': 'Connect components to light the bulb.',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFF0277BD),
      'route': 'circuitGame',
      'isActive': true,
    },
    {
      'title': 'Math Adventure',
      'description': 'Solve puzzles to cross the bridge.',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFFC62828),
      'route': 'mathGame', // Now Activated
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed("bottomNavChild");
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          title: Text(
            "EcoVenture Lab",
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              context.goNamed("bottomNavChild");
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Scientific Missions",
                style: GoogleFonts.fredoka(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) =>
                      _buildGameCard(context, games[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final bool isActive = game['isActive'];
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: ListTile(
          contentPadding: EdgeInsets.all(4.w),
          leading: CircleAvatar(
            backgroundColor: game['color'].withOpacity(0.1),
            radius: 30,
            child: Icon(game['icon'], color: game['color'], size: 25.sp),
          ),
          title: Text(
            game['title'],
            style: GoogleFonts.fredoka(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            game['description'],
            style: GoogleFonts.poppins(fontSize: 13.sp),
          ),
          trailing: ElevatedButton(
            onPressed: isActive
                ? () => context.pushNamed(game['route']!)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: game['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              isActive ? "PLAY" : "SOON",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
