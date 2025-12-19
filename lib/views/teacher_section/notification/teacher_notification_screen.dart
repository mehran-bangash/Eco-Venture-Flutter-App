import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../viewmodels/teacher_notification/teacher_notification_provider.dart';

class TeacherNotificationScreen extends ConsumerWidget {
  const TeacherNotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure you have loaded notifications via init in ViewModel or here
    final state = ref.watch(teacherNotificationViewModelProvider);
    final notifications = state.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text("No new notifications", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)))
          : ListView.separated(
        padding: EdgeInsets.all(5.w),
        itemCount: notifications.length,
        separatorBuilder: (c, i) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationCard(context, ref, notif);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, Map<String, dynamic> notif) {
    String type = notif['type'] ?? 'info';
    IconData icon = Icons.notifications;
    Color color = Colors.blue;

    if (type == 'Safety' || type == 'alert') { icon = Icons.warning_amber_rounded; color = Colors.orange; }
    else if (type == 'Parent') { icon = Icons.family_restroom; color = Colors.purple; }
    else if (type == 'Student') { icon = Icons.school; color = Colors.green; }

    return Dismissible(
      key: Key(notif['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 5.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (dir) {
        ref.read(teacherNotificationViewModelProvider.notifier).deleteNotification(notif['id']);
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border(left: BorderSide(color: color, width: 4))
        ),
        child: Row(
          children: [
            Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18.sp)),
            SizedBox(width: 3.w),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(notif['title'] ?? 'Notification', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B2559))),
                  SizedBox(height: 0.5.h),
                  Text(notif['body'] ?? '', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[700])),
                  SizedBox(height: 1.h),
                  Text(timeago.format(DateTime.parse(notif['timestamp'])), style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey[400])),
                ])
            )
          ],
        ),
      ),
    );
  }
}