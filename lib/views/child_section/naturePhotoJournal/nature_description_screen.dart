import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import '../../../models/nature_fact_{sqllite}.dart';
import '../../../models/nature_photo_upload_model.dart';// Verify path to natureProvider
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/nature_photo_view_model/nature_photo_provider.dart'; // Verify path to SharedPrefs

class NatureDescriptionScreen extends ConsumerStatefulWidget {
  final JournalEntry entry;

  const NatureDescriptionScreen({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<NatureDescriptionScreen> createState() => _NatureDescriptionScreenState();
}

class _NatureDescriptionScreenState extends ConsumerState<NatureDescriptionScreen> {

  // Local state to show the updated description immediately without waiting for a full reload
  late String _currentDescription;

  @override
  void initState() {
    super.initState();
    _currentDescription = widget.entry.fact.description;
  }

  // --- EDIT DESCRIPTION LOGIC ---
  void _showEditDescriptionDialog() {
    final TextEditingController descController = TextEditingController(text: _currentDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
              "Edit Note",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)
          ),
          content: TextField(
            controller: descController,
            maxLines: 5, // Allow multiple lines for better editing
            style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Write your thoughts about this photo...",
              hintStyle: GoogleFonts.poppins(color: Colors.black38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.yellow, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final newDescription = descController.text.trim();
                if (newDescription.isEmpty) return;

                // 1. Get Real User ID
                final userId = await SharedPreferencesHelper.instance.getUserId();

                if (userId != null) {
                  // 2. Create Updated Objects
                  // We need to update the Fact inside the Entry
                  // Assuming NatureFact has copyWith, or we reconstruct it:
                  final updatedFact = NatureFact(
                    name: widget.entry.fact.name,
                    category: widget.entry.fact.category,
                    description: newDescription, // <--- THE CHANGE
                  );

                  final updatedEntry = widget.entry.copyWith(fact: updatedFact);

                  // 3. Save to Firebase via ViewModel
                  ref.read(natureProvider.notifier).updateEntry(userId, updatedEntry);

                  // 4. Update UI locally
                  setState(() {
                    _currentDescription = newDescription;
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Description updated!", style: GoogleFonts.poppins())),
                    );
                  }
                }
              },
              child: Text("Save", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header Section (Yellow Part)
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade600,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    SizedBox(height: 1.h),

                    // Title (Heading - NOT Editable)
                    Text(
                      widget.entry.prediction.label,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.entry.imageUrl,
                        width: 100.w,
                        height: 25.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100.w,
                            height: 25.h,
                            color: Colors.white.withOpacity(0.5),
                            child: const Center(child: CircularProgressIndicator(color: Colors.black)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100.w,
                            height: 25.h,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, color: Colors.black54),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Date
                    Text(
                      DateFormat('d MMM, yyyy').format(widget.entry.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade400,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.black54),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _getCategoryIcon(widget.entry.fact.category),
                              color: Colors.black87,
                              size: 18
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            widget.entry.fact.category,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // 🔹 Description Section (Editable)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black26, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Edit Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Description :",
                            style: GoogleFonts.poppins(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          // --- EDIT BUTTON ---
                          IconButton(
                            onPressed: _showEditDescriptionDialog,
                            icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                            tooltip: "Edit Description",
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // The Description Text
                      Text(
                        _currentDescription, // Displays the updated text locally
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for icons
  IconData _getCategoryIcon(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains('plant') || catLower.contains('flower')) {
      return Icons.local_florist;
    } else if (catLower.contains('insect') || catLower.contains('bug')) {
      return Icons.bug_report;
    } else if (catLower.contains('bird')) {
      return Icons.flutter_dash;
    } else {
      return Icons.pets;
    }
  }
}
