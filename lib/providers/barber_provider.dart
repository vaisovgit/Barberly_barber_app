import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/barber.dart';
import '../services/barber_service.dart';
<<<<<<< HEAD
import 'firebase_auth_provider.dart';
=======
import 'auth_provider.dart';
>>>>>>> e0dab743b36fb8223681963f40cf677510bf29f5

final barberServiceProvider = Provider((ref) => BarberService());

final currentBarberProvider = StreamProvider<Barber?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(barberServiceProvider).getBarberStream(user.uid);
});
