import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/barber.dart';

class BarberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<Barber?> getBarberStream(String barberId) {
    return _firestore
        .collection('barbers')
        .where('firebase_uid', isEqualTo: barberId)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty
              ? Barber.fromMap(
                  snapshot.docs.first.data(),
                  snapshot.docs.first.id,
                )
              : null,
        );
  }

  Future<Barber?> getBarber(String barberId) async {
    final doc = await _firestore.collection('barbers').doc(barberId).get();
    return doc.exists ? Barber.fromMap(doc.data()!, doc.id) : null;
  }

  Future<void> updateBarber(String barberId, Map<String, dynamic> data) async {
    await _firestore.collection('barbers').doc(barberId).update(data);
  }

  Future<String?> uploadProfileImage(String barberId, File imageFile) async {
    try {
      final ref = _storage.ref().child('barbers/$barberId/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateWorkingHours(
    String barberId,
    Map<String, WorkingHours> workingHours,
  ) async {
    await _firestore.collection('barbers').doc(barberId).update({
      'workingHours': workingHours.map((k, v) => MapEntry(k, v.toMap())),
    });
  }

  Future<void> addService(String barberId, Services service) async {
    final barber = await getBarber(barberId);
    if (barber != null) {
      final services = [...barber.services, service];
      await _firestore.collection('barbers').doc(barberId).update({
        'services': services.map((s) => s.toMap()).toList(),
      });
    }
  }

  Future<void> updateService(String barberId, Services service) async {
    final barber = await getBarber(barberId);
    if (barber != null) {
      final services = barber.services
          .map((s) => s.id == service.id ? service : s)
          .toList();
      await _firestore.collection('barbers').doc(barberId).update({
        'services': services.map((s) => s.toMap()).toList(),
      });
    }
  }

  Future<void> deleteService(String barberId, String serviceId) async {
    final barber = await getBarber(barberId);
    if (barber != null) {
      final services = barber.services.where((s) => s.id != serviceId).toList();
      await _firestore.collection('barbers').doc(barberId).update({
        'services': services.map((s) => s.toMap()).toList(),
      });
    }
  }
}
