import 'package:barber_panel/providers/booking_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Booking>> getBookingsStream(
    String barberId,
    BookingFilter filter,
  ) {
    Query query = _firestore
        .collection('booking')
        .where('barberId', isEqualTo: barberId);

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    if (filter.startDate != null) {
      query = query.where(
        'dateTime',
        isGreaterThanOrEqualTo: filter.startDate!.toIso8601String(),
      );
    }

    if (filter.endDate != null) {
      query = query.where(
        'dateTime',
        isLessThanOrEqualTo: filter.endDate!.toIso8601String(),
      );
    }

    return query
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id),
              )
              .toList(),
        );
  }

  Stream<List<Booking>> getTodayBookingsStream(String barberId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('booking')
        .where('barberId', isEqualTo: barberId)
        .where('dateTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('dateTime', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    await _firestore.collection('booking').doc(bookingId).update({
      'status': status.name,
    });
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _firestore.collection('booking').doc(bookingId).update({
      'dateTime': newDateTime.toIso8601String(),
    });
  }
}
