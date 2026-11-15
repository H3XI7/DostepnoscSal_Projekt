import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> downloadApkFile({
  required String url,
  required String targetPath,
  required int expectedSize,
  required Function(double progress, String status) onProgress,
}) async {
  final file = File(targetPath);
  if (await file.exists()) {
    await file.delete();
  }
  final client = http.Client();
  final request = http.Request('GET', Uri.parse(url));
  final response = await client.send(request);

  final totalBytes = response.contentLength ?? expectedSize;
  int receivedBytes = 0;
  final sink = file.openWrite();

  await for (final chunk in response.stream) {
    sink.add(chunk);
    receivedBytes += chunk.length;
    if (totalBytes > 0) {
      final p = (receivedBytes / totalBytes).clamp(0.0, 1.0);
      final currentMb = (receivedBytes / (1024 * 1024)).toStringAsFixed(1);
      final totalMb = (totalBytes / (1024 * 1024)).toStringAsFixed(1);
      onProgress(p, '$currentMb MB / $totalMb MB');
    }
  }

  await sink.flush();
  await sink.close();
  client.close();
}
