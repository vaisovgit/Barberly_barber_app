import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/firebase_auth_service.dart';
import '../storage/localstorage_service.dart';

class AuthState {
  final String? user;
  final String? role;
  final AsyncValue<dynamic> status;

  AuthState({this.user,this.role, this.status = const AsyncData(null)});

  AuthState copyWith({String? user,String? role, AsyncValue<dynamic>? status}) {
    return AuthState(user: user ?? this.user,role: role ?? this.role, status: status ?? this.status);
  }
}

class AuthController extends StateNotifier<AuthState> {
  final ApiService api;

  AuthController(this.api) : super(AuthState());

  // Login
  Future<void> login(String phone, String password) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final res = await api.postData('login', {
        'phone': phone,
        'password': password,
      });

      final token = res['data']['token'];
      api.setToken(token);
      await LocalStorage.saveToken(token);

      final firebaseToken = res['data']['user']['firebase_token'];
      await AuthService().signInWithCustomToken(firebaseToken);

      final user = res['data']['user']['name'];
      await LocalStorage.saveUsername(user);

      final role = res['data']['user']['role'];
      await LocalStorage.saveRole(role);


      state = state.copyWith(user: user, status: AsyncData(res));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  // Register
  Future<void> register(String name, String phone, String password) async {
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

  // Verify OTP
  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final res = await api.postData('verify', {'phone': phone, 'code': code});

      final token = res['data']['token'];
      api.setToken(token);
      await LocalStorage.saveToken(token);

      final user = res['data']['user']['name'];
      await LocalStorage.saveUsername(user);

      state = state.copyWith(user: user, status: AsyncData(res));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  // Resend OTP
  Future<void> resendCode(String phone) async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      final res = await api.postData('resend', {'phone': phone});
      state = state.copyWith(status: AsyncData(res));
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }

  // Logout
  Future<void> logOut() async {
    state = state.copyWith(status: const AsyncLoading());
    try {
      await api.postData('logout', {});
      await LocalStorage.clearToken();
      await LocalStorage.clearUserInfo();
      api.clearToken();

      state = AuthState(
        user: null,
        status: const AsyncData({'success': true, 'message': 'Logged out'}),
      );
    } catch (e, st) {
      state = state.copyWith(status: AsyncError(e, st));
    }
  }
}
