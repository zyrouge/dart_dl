// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dl/dl.dart';

const String url =
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
const String outputDir = 'example/trash';

Future<void> main() async {
  const Downloader<RawDLProvider> downloader =
      Downloader<RawDLProvider>(provider: RawDLProvider());

  final FileDLResponse res = await downloader.downloadToDirectory(
    url: Uri.parse(url),
    directory: Directory(outputDir),
    overwriteFile: true,
  );

  res.progress.listen((final DLProgress progress) {
    const int maxBarLength = 20;
    final String barPrefix = List<String>.filled(
      ((progress.percent / 100) * maxBarLength).floor(),
      '#',
    ).join();
    final String barSuffix =
        List<String>.filled(maxBarLength - barPrefix.length, '-').join();

    stdout.write(
      '\r[$barPrefix$barSuffix] ${progress.current}/${progress.total} bytes (${progress.percent.toStringAsFixed(2)}%)',
    );
  });

  await res.asFuture();
  stdout.writeln();
  print('Output: ${res.file.path}');
}
