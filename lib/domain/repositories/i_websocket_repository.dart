
abstract class IWebSocketRepository {
  /// Connects to the WebSocket with the given token
  Future<void> connect(String token);

  /// Disconnects from the WebSocket
  void disconnect();

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messages;

  /// Connection status
  bool get isConnected;
}
