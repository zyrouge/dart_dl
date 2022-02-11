import 'dart:io';
import 'package:dl/dl.dart';
import 'package:test/test.dart';
import '_utils.dart';

Future<void> main() async {
  final url = Uri.parse('https://picsum.photos/1000');

  const downloader = Downloader(provider: RawDLProvider());
  final trashDir = await getTrashDir();

  group(
    'Raw DL Provider',
    () {
      test(
        '.download()',
        () async {
          final res = await downloader.download(url);
          final closed = <String, bool>{
            'data': false,
            'progress': false,
          };

          res.data.listen(
            (data) {},
            onDone: () {
              closed['data'] = true;
            },
          );

          res.progress.listen(
            (data) {},
            onDone: () {
              closed['progress'] = true;
            },
          );

          await res.asFuture();
          expect(closed.values.every((x) => x), true);
        },
        timeout: Timeout.none,
      );

      test(
        '.downloadToFile()',
        () async {
          final res = await downloader.downloadToFile(
            url,
            File('${trashDir.path}/image.jpg'),
            overwriteFile: true,
          );

          var received = 0;
          res.progress.listen((progress) {
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
          final res = await downloader.downloadToDirectory(
            url,
            await getTrashDir(),
            overwriteFile: true,
          );

          var received = 0;
          res.progress.listen((progress) {
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
