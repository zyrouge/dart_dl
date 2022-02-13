// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dl/dl.dart';

const url =
    'https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4';
const outputDir = 'example/trash';

Future<void> main() async {
  const downloader = Downloader(provider: RawDLProvider());
  final res = await downloader.downloadToDirectory(
    url: Uri.parse(url),
    directory: Directory(outputDir),
    overwriteFile: true,
  );

  res.progress.listen((progress) {
    stdout.write(
      '\r${progress.current}/${progress.total} bytes (${progress.percent.toStringAsFixed(2)}%)',
    );
  });

  await res.asFuture();
  stdout.writeln();
  print('Output: ${res.file.path}');
}
