import 'package:barber_panel/models/barber.dart';

enum BookingStatus { newBooking, confirmed, completed, canceled }

class Booking {
  final String id;
  final String clientId;
  final String clientName;
  final String? clientPhone;
  final String? clientImageUrl;
  final String barberId;
  final List<Services> services;
  final DateTime dateTime;
  final int totalDuration;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientPhone,
    this.clientImageUrl,
    required this.barberId,
    required this.services,
    required this.dateTime,
    required this.totalDuration,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'],
      clientImageUrl: map['clientImageUrl'],
      barberId: map['barberId'] ?? '',
      services:
          (map['services'] as List?)
              ?.map((s) => Services.fromMap(s))
              .toList() ??
          [],
      dateTime: DateTime.parse(map['dateTime']),
      totalDuration: map['totalDuration'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => BookingStatus.newBooking,
      ),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientImageUrl': clientImageUrl,
      'barberId': barberId,
      'services': services.map((s) => s.toMap()).toList(),
      'dateTime': dateTime.toIso8601String(),
      'totalDuration': totalDuration,
      'totalPrice': totalPrice,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Booking copyWith({BookingStatus? status, DateTime? dateTime}) {
    return Booking(
      id: id,
      clientId: clientId,
      clientName: clientName,
      clientPhone: clientPhone,
      clientImageUrl: clientImageUrl,
      barberId: barberId,
      services: services,
      dateTime: dateTime ?? this.dateTime,
      totalDuration: totalDuration,
      totalPrice: totalPrice,
      status: status ?? this.status,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
