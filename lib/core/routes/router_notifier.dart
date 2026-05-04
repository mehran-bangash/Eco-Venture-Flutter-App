import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/auth/auth_provider.dart';
import '../../viewmodels/child_view_model/inbox_report/child_safety_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to Auth changes
    _ref.listen(authViewModelProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });

    // Fix: Using the correct name 'childSafetyServiceProvider' from your file
    _ref.listen(childSafetyServiceProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});