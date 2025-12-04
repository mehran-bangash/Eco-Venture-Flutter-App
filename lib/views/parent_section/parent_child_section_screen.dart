import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/parent_section/report_safety/parent_safety_provider.dart';


class ParentChildSelectionScreen extends ConsumerStatefulWidget {
  const ParentChildSelectionScreen({super.key});

  @override
  ConsumerState<ParentChildSelectionScreen> createState() => _ParentChildSelectionScreenState();
}

class _ParentChildSelectionScreenState extends ConsumerState<ParentChildSelectionScreen> {
  // Loading state for batch operation
  bool _isLinking = false;

  // Local list to handle optimistic UI updates for Dismissible
  List<Map<String, dynamic>> _localChildrenList = [];

  @override
  void initState() {
    super.initState();
    // 1. Initialize local list from current state immediately
    _localChildrenList = List.from(ref.read(parentSafetyViewModelProvider).linkedChildren);

    // 2. Fetch fresh data
    Future.microtask(() => _fetchChildren());
  }

  Future<void> _fetchChildren() async {
    await ref.read(parentSafetyViewModelProvider.notifier).fetchLinkedChildren();
  }

  // --- DYNAMIC LINKING DIALOG ---
  void _showLinkChildDialog() {
    List<Map<String, TextEditingController>> entries = [
      {'name': TextEditingController(), 'email': TextEditingController()}
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Link Children", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            content: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(maxHeight: 50.h),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Enter child details to link.", style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                    SizedBox(height: 2.h),
                    ...entries.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                        child: Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text("Child ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue)),
                              if (entries.length > 1) InkWell(onTap: () => setDialogState(() => entries.removeAt(index)), child: Icon(Icons.close, color: Colors.red, size: 18.sp))
                            ]),
                            SizedBox(height: 1.h),
                            TextField(controller: controllers['name'], decoration: InputDecoration(hintText: "Name", filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.all(3.w), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
                            SizedBox(height: 1.h),
                            TextField(controller: controllers['email'], decoration: InputDecoration(hintText: "Email", filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.all(3.w), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                        onPressed: () => setDialogState(() => entries.add({'name': TextEditingController(), 'email': TextEditingController()})),
                        icon: const Icon(Icons.add_circle_outline), label: const Text("Add Another Child")
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _processBatchLinking(entries); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Link Profiles", style: TextStyle(color: Colors.white))
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _processBatchLinking(List<Map<String, TextEditingController>> entries) async {
    setState(() => _isLinking = true);
    int successCount = 0;
    List<String> errors = [];

    for (var entry in entries) {
      String name = entry['name']!.text.trim();
      String email = entry['email']!.text.trim();
      if (name.isEmpty || email.isEmpty) continue;
      try {
        await ref.read(parentSafetyViewModelProvider.notifier).linkChildByEmail(email, name);
        successCount++;
      } catch (e) {
        errors.add("$name: ${e.toString().replaceAll('Exception:', '').trim()}");
      }
    }

    setState(() => _isLinking = false);

    if (mounted) {
      if (successCount > 0) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Linked $successCount children!"), backgroundColor: Colors.green));
      if (errors.isNotEmpty) showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Issues"), content: Column(mainAxisSize: MainAxisSize.min, children: errors.map((e) => Text("• $e", style: const TextStyle(color: Colors.red))).toList()), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
    }
  }

  // --- UNLINK LOGIC ---
  Future<void> _unlinkChild(String childId) async {
    try {
      // This assumes you added unlinkChild to your ViewModel as instructed
      await ref.read(parentSafetyViewModelProvider.notifier).unlinkChild(childId);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Child unlinked successfully"), backgroundColor: Colors.orange)
      );
    } catch (e) {
      // If backend fails, re-fetch to restore the list
      await ref.read(parentSafetyViewModelProvider.notifier).fetchLinkedChildren();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unlink failed: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentSafetyViewModelProvider);

    // --- STATE LISTENER ---
    ref.listen(parentSafetyViewModelProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red));
      }

      // SYNC LIST: We only sync if the provider list length actually changes in a way that indicates
      // a backend update we didn't initiate locally, OR if we are just loading.
      // This check prevents the "flash" of old data if the provider updates before our local animation finishes.
      // Since ViewModel should handle optimistic updates (removing item immediately),
      // 'next.linkedChildren' should already be smaller, so syncing here is safe.
      if (!next.isLoading) {
        setState(() {
          _localChildrenList = List.from(next.linkedChildren);
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Who are you managing?", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // LOADING STATE: Only show spinner if we have NO data at all.
            if (_isLinking || (state.isLoading && _localChildrenList.isEmpty))
              const Center(child: CircularProgressIndicator())

            // EMPTY STATE
            else if (_localChildrenList.isEmpty)
              _buildEmptyState()

            // DATA STATE
            else
              Expanded(
                child: GridView.builder(
                  itemCount: _localChildrenList.length + 1,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.w,
                    mainAxisSpacing: 4.w,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    if (index == _localChildrenList.length) {
                      return _buildAddButton();
                    }
                    final child = _localChildrenList[index];
                    return _buildDismissibleChildCard(child, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- DISMISSIBLE CARD FOR DELETE ---
  Widget _buildDismissibleChildCard(Map<String, dynamic> child, int index) {
    return Dismissible(
      key: Key(child['uid']),
      direction: DismissDirection.up,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Unlink Child?"),
            content: Text("Are you sure you want to remove ${child['name']} from your dashboard?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Unlink", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // 1. Call backend (ViewModel handles optimistic update)
        _unlinkChild(child['uid']);

        // Note: We don't need manual setState removal here because the listener
        // will pick up the optimistic update from the ViewModel and refresh _localChildrenList.
        // But for immediate visual feedback before the listener fires:
        setState(() {
          _localChildrenList.removeAt(index);
        });
      },
      background: Container(decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red)), child: const Center(child: Icon(Icons.delete_forever, color: Colors.red, size: 40))),
      child: _buildChildCard(child),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return GestureDetector(
      onTap: () {
        ref.read(parentSafetyViewModelProvider.notifier).selectChild(child['uid']);
        context.pushNamed('bottomNavParent');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30.sp,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, color: Colors.blue, size: 40),
            ),
            SizedBox(height: 2.h),
            Text(child['name'] ?? "Child", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
            Text("Tap to Manage", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showLinkChildDialog,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_add_alt_1_rounded, color: Colors.blue, size: 32.sp), SizedBox(height: 1.h), Text("Link Child", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.blue, fontWeight: FontWeight.w600))]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(height: 10.h), Icon(Icons.family_restroom_rounded, size: 50.sp, color: Colors.grey.shade300), SizedBox(height: 2.h), Text("No children linked yet.", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)), SizedBox(height: 4.h), SizedBox(width: 70.w, height: 7.h, child: ElevatedButton(onPressed: _showLinkChildDialog, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text("Link Existing Account", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp))))]));
  }
}