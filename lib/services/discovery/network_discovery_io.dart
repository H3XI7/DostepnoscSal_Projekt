import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<String?> discoverLanServerUdpPlatform() async {
  RawDatagramSocket? socket;
  try {
    socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final message = utf8.encode('DISCOVER_ROOM_SERVER');

    // Broadcast to port 8082
    socket.send(message, InternetAddress('255.255.255.255'), 8082);

    final completer = Completer<String?>();
    final subscription = socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final dg = socket?.receive();
        if (dg != null) {
          try {
            final text = utf8.decode(dg.data);
            if (text.contains('lanUrl')) {
              final jsonMap = json.decode(text) as Map<String, dynamic>;
              final lanUrl = jsonMap['lanUrl'] as String?;
              if (lanUrl != null && lanUrl.isNotEmpty && !completer.isCompleted) {
                completer.complete(lanUrl);
              }
            }
          } catch (_) {}
        }
      }
    });

    final timer = Timer(const Duration(milliseconds: 1500), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    final result = await completer.future;
    timer.cancel();
    await subscription.cancel();
    return result;
  } catch (e) {
    return null;
  } finally {
    socket?.close();
  }
}
