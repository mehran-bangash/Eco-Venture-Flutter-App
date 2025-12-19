import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture/core/constants/app_gradients.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../viewmodels/auth/auth_provider.dart';


class ChildSettings extends ConsumerStatefulWidget {
  const ChildSettings({super.key});

  @override
  ConsumerState<ChildSettings> createState() => _ChildSettingsState();
}

class _ChildSettingsState extends ConsumerState<ChildSettings>
    with TickerProviderStateMixin {
  late AnimationController _profileImageController;
  late Animation<double> _profileImagePulse;
  String username = "Guest";
  String userImageUrl = "";

  Future<void> _loadUsername() async {
    final name = await SharedPreferencesHelper.instance.getUserName();
    final image = await SharedPreferencesHelper.instance.getUserImgUrl();
    setState(() {
      username = name ?? "Guest";
      userImageUrl = image ?? "";
    });
  }

  @override
  void initState() {
    super.initState();

    _profileImageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Very subtle shrink & grow
    _profileImagePulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _profileImageController, curve: Curves.easeInOut),
    );

    _profileImageController.repeat(reverse: true); // smooth loop
    _loadUsername();
  }

  @override
  void dispose() {
    _profileImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop: false, // prevents auto pop
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        // This runs when system back button is pressed
        context.goNamed('bottomNavChild');
      }
    },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              expandedHeight: 28.h,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.backgroundGradient,
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _profileImagePulse,
                            child: Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.h),
                                  child: SizedBox(
                                    height: 15.h,
                                    width: 15.h,
                                    child: userImageUrl.isNotEmpty
                                        ? Image.network(
                                            userImageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  );
                                                },
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.blueAccent,
                                              size: 20.w,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Settings",
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            username,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  GestureDetector(
                    onTap: () {
                      context.goNamed('childProfile');
                    },
                    child: SettingsTile(
                      title: "Profile",
                      subtitle: "Manage your personal \ninformation",
                      circleColor: Colors.blue,
                      leadingIcon: Icons.person_outline,
                      trailing: Container(
                        height: 5.h,
                        width: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SettingsTile(
                    title: "App Theme",
                    subtitle: "Light mode",
                    circleColor: Colors.blue,
                    leadingIcon: Icons.dark_mode,
                    trailing: Switch(value: true, onChanged: (val) {}),
                  ),
                  SizedBox(height: 2.h),
                  SettingsTile(
                    title: "About Company",
                    subtitle: "learn more about \ncompany",
                    circleColor: Colors.purpleAccent,
                    leadingIcon: Icons.business_outlined,
                    trailing: Container(
                      height: 5.h,
                      width: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SettingsTile(
                    title: "Contact us",
                    subtitle: "Get help and support",
                    circleColor: Colors.orangeAccent,
                    leadingIcon: Icons.support_agent,
                    trailing: Container(
                      height: 5.h,
                      width: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Consumer(
                    builder: (context, ref, child) {
                      final authVM = ref.read(authViewModelProvider.notifier);

                      return SettingsTile(
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        circleColor: Colors.redAccent,
                        leadingIcon: Icons.exit_to_app,
                        trailing: Container(
                          height: 5.h,
                          width: 10.w,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        onPressed: () async {
                          // Step 1: Ask for confirmation
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Confirm Logout"),
                              content: const Text(
                                "Do you really want to log out?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Logout"),
                                ),
                              ],
                            ),
                          );

                          // Step 2: If confirmed, call ViewModel
                          if (confirmed == true) {
                            await authVM.signOut();
                            // Step 3: Show feedback to user
                            Utils.showDelightToast(
                              context,
                              "User successfully logged out",
                              duration: Duration(seconds: 3),
                              textColor: Colors.white,
                              bgColor: Colors.green,
                              position: DelightSnackbarPosition.bottom,
                              icon: Icons.check,
                              iconColor: Colors.white,
                            );

                            // Step 4: Navigate to login page
                            context.goNamed('login');
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
