// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dl/dl.dart';

const url =
    'https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_640_3MG.mp4';
const outputDir = 'example/trash';

Future<void> main() async {
  const downloader = Downloader(provider: RawDLProvider());
  final res = await downloader.downloadToDirectory(
    Uri.parse(url),
    Directory(outputDir),
    overwriteFile: true,
  );

  res.progress.listen((progress) {
    print(
      '${progress.current}/${progress.total} (${progress.percent.toStringAsFixed(2)}%)',
    );
  });
  print(res.response.headers);

  await res.asFuture();
  print('Output: ${res.file.path}');
}
