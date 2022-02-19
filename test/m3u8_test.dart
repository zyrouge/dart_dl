import 'dart:io';
import 'package:dl/dl.dart';
import 'package:test/test.dart';
import '_utils.dart';

Future<void> main() async {
  final Uri url = Uri.parse(
    'https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa_video_180_250000.m3u8',
  );

  const Downloader<M3U8DLProvider> downloader = Downloader<M3U8DLProvider>(
    provider:
        M3U8DLProvider(outputFileExtension: M3U8OutputFileExtensions.mpeg),
  );

  final Directory trashDir = await getTrashDir();

  group(
    'M3U8 DL Provider',
    () {
      test(
        '.download()',
        () async {
          final DLResponse res = await downloader.download(url: url);

          final Map<String, bool> closed = <String, bool>{
            'data': false,
            'progress': false,
          };

          res.data.listen(
            (final List<int> data) {},
            onDone: () {
              closed['data'] = true;
            },
          );

          res.progress.listen(
            (final DLProgress data) {},
            onDone: () {
              closed['progress'] = true;
            },
          );

          await res.asFuture();
          expect(closed.values.every((final bool x) => x), true);
        },
        timeout: Timeout.none,
      );

      test(
        '.downloadToFile()',
        () async {
          final FileDLResponse res = await downloader.downloadToFile(
            url: url,
            file: File('${trashDir.path}/video.ts'),
            overwriteFile: true,
          );

          int received = 0;
          res.progress.listen((final DLProgress progress) {
            received = progress.current;
          });

          await res.asFuture();
          expect(received, await res.file.length());

          debugPrint('Output: ${res.file.path}');
        },
        timeout: Timeout.none,
      );

      test(
        '.downloadToDirectory()',
        () async {
          final FileDLResponse res = await downloader.downloadToDirectory(
            url: url,
            directory: trashDir,
            overwriteFile: true,
          );

          int received = 0;
          res.progress.listen((final DLProgress progress) {
            received = progress.current;
          });

          await res.asFuture();
          expect(received, await res.file.length());

          debugPrint('Output: ${res.file.path}');
        },
        timeout: Timeout.none,
      );
    },
    timeout: Timeout.none,
  );
}
