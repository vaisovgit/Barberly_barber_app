import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';

class MapState {
  final String? user;
  final AsyncValue<dynamic> status;

  MapState({this.user, this.status = const AsyncData(null)});

  MapState copyWith({String? user, AsyncValue<dynamic>? status}) {
    return MapState(user: user ?? this.user, status: status ?? this.status);
  }
}

class MapController extends StateNotifier<MapState> {
  final ApiService api;

  MapController(this.api) : super(MapState());


  // Register
  Future<void> sendLocation(String name, String phone, String password) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final res = await api.postData('register', {
        'name': name,
        'phone': phone,
        'password': password,
      });
      state = state.copyWith(user: null, status: AsyncData(res));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }
}


