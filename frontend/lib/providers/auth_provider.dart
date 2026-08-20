import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

enum AuthStatus { unknown, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  final _api = ApiService.instance;

  AuthStatus status = AuthStatus.unknown;
  Map<String, dynamic>? currentUser;
  String? errorMessage;
  bool busy = false;

  Future<void> bootstrap() async {
    status = (await _api.isLoggedIn) ? AuthStatus.loggedIn : AuthStatus.loggedOut;
    notifyListeners();
    if (status == AuthStatus.loggedIn) {
      SyncService.instance.syncAll();
    }
  }

  Future<bool> login(String email, String password) => _run(() async {
        final data = await _api.login(email: email, password: password);
        currentUser = data['user'] as Map<String, dynamic>;
        status = AuthStatus.loggedIn;
        SyncService.instance.syncAll();
      });

  Future<bool> register(String email, String password, String? name) => _run(() async {
        final data = await _api.register(email: email, password: password, name: name);
        currentUser = data['user'] as Map<String, dynamic>;
        status = AuthStatus.loggedIn;
      });

  Future<bool> forgotPassword(String email) => _run(() async {
        await _api.forgotPassword(email);
      });

  Future<void> logout() async {
    await _api.logout();
    currentUser = null;
    status = AuthStatus.loggedOut;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      busy = false;
      notifyListeners();
      return false;
    }
  }
}
