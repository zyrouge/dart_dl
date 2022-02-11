import 'dart:io';
import 'package:dl/dl.dart';
import 'package:test/test.dart';
import '_utils.dart';

Future<void> main() async {
  final url = Uri.parse(
    'https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa_video_180_250000.m3u8',
  );

  const downloader = Downloader(provider: M3U8DLProvider());
  final trashDir = await getTrashDir();

  group(
    'M3U8 DL Provider',
    () {
      test('.download()', () async {
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
        print(closed);
        expect(closed.values.every((x) => x), true);
      });

      // test(
      //   '.downloadToFile()',
      //   () async {
      //     final res = await downloader.downloadToFile(
      //       url,
      //       File('${trashDir.path}/video.ts'),
      //       overwriteFile: true,
      //     );

      //     var received = 0;
      //     res.progress.listen((progress) {
      //       received = progress.current;
      //     });

      //     await res.asFuture();
      //     expect(received, await res.file.length());

      //     debugPrint('Output: ${res.file.path}');
      //   },
      //   timeout: Timeout.none,
      // );

      // test(
      //   '.downloadToDirectory()',
      //   () async {
      //     final res = await downloader.downloadToDirectory(
      //       url,
      //       trashDir,
      //       overwriteFile: true,
      //     );

      //     var received = 0;
      //     res.progress.listen((progress) {
      //       received = progress.current;
      //     });

      //     await res.asFuture();
      //     expect(received, await res.file.length());

      //     debugPrint('Output: ${res.file.path}');
      //   },
      //   timeout: Timeout.none,
      // );
    },
    timeout: Timeout.none,
  );
}
