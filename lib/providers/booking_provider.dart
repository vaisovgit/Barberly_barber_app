import 'package:barber_panel/screens/bookings/booking_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';
import 'firebase_auth_provider.dart';

final bookingServiceProvider = Provider((ref) => BookingService());

final bookingFilterDetailsProvider = StateProvider<BookingFilter>((ref) {
  final filterType = ref.watch(bookingFilterProvider);
  final now = DateTime.now();
  switch (filterType) {
    case BookingFilterType.today:
      return BookingFilter(
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case BookingFilterType.upcoming:
      return BookingFilter(
        startDate: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1)),
      );
    case BookingFilterType.past:
      return BookingFilter(
        endDate: DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(seconds: 1)),
      );
    default:
      return BookingFilter();
  }
});

final bookingsProvider = StreamProvider<List<Booking>>((ref) {
  // Убери family, теперь простой
  final filter = ref.watch(
    bookingFilterDetailsProvider,
  ); // Watch на стабильный filter
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(bookingServiceProvider).getBookingsStream(user.uid, filter);
});

final todayBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(bookingServiceProvider).getTodayBookingsStream(user.uid);
});

final todayStatsProvider = StreamProvider<DayStats>((ref) {
  final bookings = ref.watch(todayBookingsProvider).value ?? [];

  final completed = bookings
      .where((b) => b.status == BookingStatus.completed)
      .length;
  final revenue = bookings
      .where((b) => b.status == BookingStatus.completed)
      .fold<double>(0, (sum, b) => sum + b.totalPrice);

  return Stream.value(
    DayStats(
      totalBookings: bookings.length,
      completedBookings: completed,
      totalRevenue: revenue,
    ),
  );
});

class BookingFilter {
  final BookingStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  BookingFilter({this.status, this.startDate, this.endDate});
}

class DayStats {
  final int totalBookings;
  final int completedBookings;
  final double totalRevenue;

  DayStats({
    required this.totalBookings,
    required this.completedBookings,
    required this.totalRevenue,
  });
}
