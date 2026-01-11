import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/api_config.dart';
import '../data/repositories/auth_repository.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;
  Timer? _reconnectTimer;

  Stream<Map<String, dynamic>> get notifications => _controller.stream;
  bool get isConnected => _isConnected;

  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await AuthRepository().getAccessToken();
    if (token == null) return;

    final uri = Uri.parse('${ApiConfig.wsUrl}?token=$token');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _controller.add(data);
        },
        onDone: () {
          _isConnected = false;
          _reconnect();
        },
        onError: (error) {
          _isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
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
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}
