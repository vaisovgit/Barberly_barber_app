import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {

  GoogleMapController? mapController;
  LatLng? origin;
  String? streetName;
  String? districtName;
  Set<Marker> _markers = {};
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

  }


  Future<Map<String, String>> getAddressFromLatLng(double lat, double lng) async {
    final placemarks = await placemarkFromCoordinates(lat, lng);

    final p = placemarks.first;


    // STREET fallback
    final street = p.thoroughfare?.isNotEmpty == true
        ? p.thoroughfare
        : p.street?.isNotEmpty == true
        ? p.street
        : null;

    // DISTRICT fallback (locality → subLocality → administrativeArea)
    final district = p.locality?.isNotEmpty == true
        ? p.locality
        : p.subLocality?.isNotEmpty == true
        ? p.subLocality
        : p.administrativeArea?.isNotEmpty == true
        ? p.administrativeArea
        : null;

    // REGION fallback (region / province)
    final region = p.administrativeArea?.isNotEmpty == true
        ? p.administrativeArea
        : p.subAdministrativeArea?.isNotEmpty == true
        ? p.subAdministrativeArea
        : p.country; // oxirgi variant

    return {
      "street_name": street ?? "",      // topilmasa bo‘sh
      "district_name": district ?? region ?? "", // district bo‘lmasa region
    };
  }

  Future<void> _getCurrentLocation() async {
    // Location enable bo‘lganmi?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location o'chirilgan");
    }

    // Permissionlar
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return Future.error("Permission yo'q");
    }

    // Hozirgi lokatsiya
    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      origin = LatLng(pos.latitude, pos.longitude);
    });

    // Kamera = turgan joyga
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(origin!, 16),
    );
    _markers.add(Marker(
      markerId: const MarkerId("me"),
      position: origin!,
      infoWindow: const InfoWindow(title: "Manzil"),
    )
    );
    final address = await getAddressFromLatLng(
      pos.latitude,
      pos.longitude,
    );

setState(() {
  streetName = address['street_name'];
  districtName = address['district_name'];
});


    print("Street: ${address['street_name']}");
    print("District: ${address['district_name']}");
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
      ),
      body: Center(
        child: origin == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
          initialCameraPosition: CameraPosition(
            target: origin!,
            zoom: 16,

          ),
            myLocationEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            }
              ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Street11111: $streetName");
            print("District1111111: $districtName");

          },
          child: const Icon(Icons.save),
        ),
    );
  }
}
