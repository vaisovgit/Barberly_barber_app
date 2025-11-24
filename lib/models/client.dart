class Client {
  final int id;
  final String name;
  final String phone;
  final int tenantId;
  final List<String> roles;
  final List<ServiceModel> services;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.tenantId,
    required this.roles,
    required this.services,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      tenantId: json['tenant_id'],
      roles: List<String>.from(json['roles'].map((x) => x)),
      services: json['services'] != null
          ? List<ServiceModel>.from(
          json['services'].map((x) => ServiceModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'tenant_id': tenantId,
    'roles': roles,
    'services': services.map((x) => x.toJson()).toList(),
  };
}

class ServiceModel {
  final int id;
  final String name;
  final String price;
  final String serviceDuration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.serviceDuration,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      serviceDuration: json['service_duration'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'service_duration': serviceDuration,
  };
}
