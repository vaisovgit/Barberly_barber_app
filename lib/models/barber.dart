class Barber {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final String? bio;
  final Map<String, WorkingHours>? workingHours;
  final List<Services> services;
  final DateTime createdAt;

  Barber({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    this.bio,
    this.workingHours,
    this.services = const [],
    required this.createdAt,
  });

  factory Barber.fromMap(Map<String, dynamic> map, String id) {
    return Barber(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      imageUrl: map['imageUrl'],
      bio: map['bio'],
      workingHours: map['workingHours'] != null
          ? (map['workingHours'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, WorkingHours.fromMap(value)),
            )
          : null,
      services:
          (map['services'] as List?)
              ?.map((s) => Services.fromMap(s))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'bio': bio,
      'workingHours': workingHours?.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'services': services.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WorkingHours {
  final String startTime;
  final String endTime;
  final bool isWorking;

  WorkingHours({
    required this.startTime,
    required this.endTime,
    this.isWorking = true,
  });

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '18:00',
      isWorking: map['isWorking'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'startTime': startTime, 'endTime': endTime, 'isWorking': isWorking};
  }
}

class Services {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String? description;

  Services({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description,
  });

  factory Services.fromMap(Map<String, dynamic> map) {
    return Services(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      durationMinutes: map['durationMinutes'] ?? 30,
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
    };
  }
}
