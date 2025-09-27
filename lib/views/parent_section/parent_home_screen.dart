import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async{
          final id=await SharedPreferencesHelper.instance.getUserId();
          final name=await SharedPreferencesHelper.instance.getUserName();
          final phoneNumber=await SharedPreferencesHelper.instance.getUserPhoneNumber();
          final email=await SharedPreferencesHelper.instance.getUserEmail();
          print("id: $id  Name: $name PhoneNumber :$phoneNumber Email: $email");


      },),
      body: Center(child: Text("Parent is coming soon"),),
    );
  }
}
