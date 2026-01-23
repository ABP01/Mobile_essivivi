import 'dart:async';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/websocket_repository_impl.dart';
import '../domain/repositories/i_websocket_repository.dart';

class WebSocketService {
  final IWebSocketRepository _repository = WebSocketRepositoryImpl();
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get notifications => _repository.messages;
  bool get isConnected => _repository.isConnected;

  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  Future<void> connect() async {
    if (_repository.isConnected) return;

    final token = await AuthRepository().getAccessToken();
    if (token == null) return;

    try {
      await _repository.connect(token);
    } catch (e) {
      _reconnect();
    }
  }

  void _reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _repository.disconnect();
  }
}
