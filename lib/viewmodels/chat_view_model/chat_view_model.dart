import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/chat_sqlflite.dart';
import 'chat_state.dart';


class ChatViewModel extends StateNotifier<ChatState> {
  final ChatDatabase _dbService = ChatDatabase();
  final ChatService _apiService = ChatService();

  ChatViewModel() : super(const ChatState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      //  Correct way to await async call
      final userId = await SharedPreferencesHelper.instance.getUserId();

      if (userId == null) {
        print(' No userId found in SharedPreferences');
        return;
      }

      //  Load last few messages from local DB
      final recent = await _dbService.getLastMessages(userId, 5);

      state = state.copyWith(
        userId: userId,
        messages: recent,
      );
      print(' Chat initialized for user: $userId');
    } catch (e) {
      print("Init load failed: $e");
    }
  }

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty || state.userId == null) {
      print(' Missing userId or empty message');
      return;
    }

    final userMessage = ChatMessage(
      userId: state.userId!,
      message: userText.trim(),
      isUser: true,
      sender: 'user',
      time: DateTime.now(),
    );

    // Update UI immediately
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Save user message locally
    await _dbService.insertMessage(userMessage);

    String aiResponse;
    try {
      print(' Sending to API for userId: ${state.userId}');
      aiResponse = await _apiService.sendMessage(
        userText.trim(),
        state.userId!,
      );
      print(' AI Response received: $aiResponse');
    } catch (e) {
      print(' API Error: $e');
      aiResponse = "Sorry, I couldn't get an answer right now. Try again later!";
    }

    final aiMessage = ChatMessage(
      userId: state.userId!,
      message: aiResponse,
      sender: 'bot',
      isUser: false,
      time: DateTime.now(),
    );

    await _dbService.insertMessage(aiMessage);

    // Add AI message to UI
    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isLoading: false,
    );
  }

  Future<void> clearHistoryForCurrentUser() async {
    if (state.userId == null) return;

    await _dbService.clearUserMessages(state.userId!);
    state = state.copyWith(messages: []);
    print(' Cleared chat history for user: ${state.userId}');
  }
}