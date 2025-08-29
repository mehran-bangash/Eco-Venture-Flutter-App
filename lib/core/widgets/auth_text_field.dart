import 'package:eco_venture/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../constants/app_text_styles.dart';
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hintTitle,
    this.showText,
    required this.controller,
    required this.keyBoardType,
    this.customFieldWidth,
    required this.showPrefixIcon,
    this.isPassword = false,
    this.validator,
  });

  final String hintTitle;
  final double? customFieldWidth;
  final IconData showPrefixIcon;
  final String? showText;
  final TextEditingController controller;
  final TextInputType keyBoardType;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Listen for focus changes
    _focusNode.addListener(() {
      setState(() {}); // Rebuild the widget when focus changes
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.showText ?? "",
              style: AppTextStyles.body15RegularPureBlackW600,
              textAlign: TextAlign.start,
            ),
          ),
          SizedBox(height: 1.h),
          Material(
            elevation: 2, // Add elevation for a raised effect
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: widget.customFieldWidth ?? 65.w,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyBoardType,
                obscureText: widget.isPassword ? _obscureText : false,
                validator: widget.validator,
                focusNode: _focusNode, // Assign the focus node
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: widget.hintTitle,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 1.8.h, horizontal: 4.w),
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  errorStyle: TextStyle(fontSize: 14.sp),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _focusNode.hasFocus
                          ? Colors.indigo // Full indigo when focused
                          : Colors.lightBlue.shade100, // Light indigo when not focused
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.indigo, width: 2), // Full indigo color
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.all(8.0), // Small grey box around the icon
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, // Grey box color
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      widget.showPrefixIcon, // Replace with your desired icon
                      color: AppColors.indigo,
                    ),
                  ),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade800,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}