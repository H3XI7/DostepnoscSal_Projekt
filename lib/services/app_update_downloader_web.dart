Future<void> downloadApkFile({
  required String url,
  required String targetPath,
  required int expectedSize,
  required Function(double progress, String status) onProgress,
}) async {
  // No-op on web
}
