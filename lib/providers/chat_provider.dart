import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';

final chatServiceProvider = Provider((ref) => ChatService());
String? phoneFromPlaceholderEmail(String email) {
  final regex = RegExp(r'phone_([0-9]+)@', caseSensitive: false);
  final match = regex.firstMatch(email);
  if (match == null) return null;

  String digits = match.group(1)!;

  // Убираем ведущие нули (если вдруг есть)
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  if (digits.isEmpty) return null;

  // Если меньше 10 цифр — просто возвращаем +digits (fallback)
  if (digits.length < 10) {
    return '+$digits';
  }

  // Если ровно 10 — предполагаем country code = 1 (США/Канада)
  if (digits.length == 10) {
    final country = '1';
    final area = digits.substring(0, 3);
    final part1 = digits.substring(3, 6);
    final part2 = digits.substring(6, 10);
    return '+$country ($area) $part1-$part2';
  }

  // Если > 10 — первые N-10 цифр — это country code
  final country = digits.substring(0, digits.length - 10);
  final area = digits.substring(digits.length - 10, digits.length - 7);
  final part1 = digits.substring(digits.length - 7, digits.length - 4);
  final part2 = digits.substring(digits.length - 4);

  return '+$country ($area) $part1-$part2';
}

final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final user = ref.watch(authStateProvider).value;

  if (user == null) return Stream.value([]);
  final phone = phoneFromPlaceholderEmail(user.email!);
  return ref.watch(chatServiceProvider).getChatRoomsStream(phone);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  chatRoomId,
) {
  return ref.watch(chatServiceProvider).getMessagesStream(chatRoomId);
});

final totalUnreadProvider = StreamProvider<int>((ref) {
  final chatRooms = ref.watch(chatRoomsProvider).value ?? [];
  return Stream.value(
    chatRooms.fold<int>(0, (sum, room) => sum + room.unreadCount),
  );
});
