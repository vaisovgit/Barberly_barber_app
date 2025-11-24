import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber.dart';
import '../services/barber_service.dart';
import 'auth_provider.dart';

final barberServiceProvider = Provider((ref) => BarberService());

final currentBarberProvider = StreamProvider<Barber?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(barberServiceProvider).getBarberStream(user.uid);
});
