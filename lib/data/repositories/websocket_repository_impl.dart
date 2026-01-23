import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../domain/repositories/i_websocket_repository.dart';
import '../../utils/api_config.dart';
import '../../utils/logger.dart';

class WebSocketRepositoryImpl implements IWebSocketRepository {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  @override
  Future<void> connect(String token) async {
    if (_isConnected) return;

    final uri = Uri.parse('${ApiConfig.wsUrl}?token=$token');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _controller.add(data);
          } catch (e) {
            // Ignore malformed json
            logger.e('WebSocket JSON Error: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          // Notify disconnection? The stream stays open in this design.
        },
        onError: (error) {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  @override
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
  }
}
