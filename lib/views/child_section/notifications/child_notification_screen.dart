import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/shared_preferences_helper.dart';

class ChildNotificationScreen extends StatefulWidget {
  const ChildNotificationScreen({super.key});

  @override
  State<ChildNotificationScreen> createState() => _ChildNotificationScreenState();
}

class _ChildNotificationScreenState extends State<ChildNotificationScreen> {
  final _database = FirebaseDatabase.instance;
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) uid = await SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;

    // FIX: Listen to 'child_notifications' instead of 'user_notifications'
    _database.ref('child_notifications/$uid').onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> loaded = [];

      if (data != null && data is Map) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['key'] = key;

          loaded.add({
            'key': key,
            'title': map['title'] ?? 'Alert',
            'body': map['body'] ?? '',
            'type': map['type'] ?? 'info',
            'timestamp': DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
          });
        });
      }

      loaded.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      if (mounted) {
        setState(() {
          _notifications = loaded;
          _isLoading = false;
        });
      }
    });
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteNotification(String key) async {
    String? uid = _auth.currentUser?.uid ?? await SharedPreferencesHelper.instance.getUserId();
    if (uid != null) {
      await _database.ref('child_notifications/$uid/$key').remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Notifications", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(child: Text("No notifications yet!", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16.sp)))
          : ListView.builder(
        padding: EdgeInsets.all(5.w),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];

          return Dismissible(
            key: Key(notif['key']),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: EdgeInsets.only(bottom: 2.h),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 5.w),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() { _notifications.removeAt(index); });
              _deleteNotification(notif['key']);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cleared"), duration: Duration(seconds: 1)));
            },
            child: _buildNotificationCard(notif),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    IconData icon = Icons.notifications;
    Color color = Colors.blue;

    if (notif['type'] == 'safety') { icon = Icons.security; color = Colors.orange; }
    if (notif['type'] == 'content') { icon = Icons.star; color = Colors.purple; }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(2.w), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20.sp)),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notif['title'], style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 0.5.h),
                Text(notif['body'], style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey[700])),
                SizedBox(height: 1.h),
                Text(timeago.format(notif['timestamp']), style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey[400])),
              ],
            ),
          )
        ],
      ),
    );
  }
}