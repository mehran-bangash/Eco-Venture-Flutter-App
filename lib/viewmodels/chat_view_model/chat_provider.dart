import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_view_model.dart';
import 'chat_state.dart';

// Global provider for accessing ChatViewModel
final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>(
      (ref) => ChatViewModel(),
);
