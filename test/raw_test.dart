import 'dart:io';
import 'package:dl/dl.dart';
import 'package:test/test.dart';
import '_utils.dart';

Future<void> main() async {
  final Uri url = Uri.parse('https://picsum.photos/1000');

  const Downloader<RawDLProvider> downloader =
      Downloader<RawDLProvider>(provider: RawDLProvider());

  final Directory trashDir = await getTrashDir();

  group(
    'Raw DL Provider',
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
            file: File('${trashDir.path}/image.jpg'),
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
            directory: await getTrashDir(),
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
