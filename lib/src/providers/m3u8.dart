import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../response/exports.dart';
import '../utils.dart';
import 'raw.dart';

class M3U8Item {
  const M3U8Item(this.url, this.attributes);

  final String url;
  final Map<String, String> attributes;
}

abstract class M3U8Utils {
  static List<M3U8Item> parseM3U8({
    required final String url,
    required final String data,
  }) =>
      RegExp(r'#(EXT-X-STREAM-INF|EXTINF):([^\n]+)\n([^\n]+)')
          .allMatches(data)
          .map(
        (x) {
          final attributes = <String, String>{};
          for (final x in x.group(2)!.split(',')) {
            final parsed = x.trim().split('=');
            if (parsed.length == 2) {
              attributes[parsed[0]] = parsed[1];
            }
          }

          var route = x.group(3)!.trim();
          if (!route.startsWith('http')) {
            route = _joinURL(url, route);
          }

          return M3U8Item(route, attributes);
        },
      ).toList();

  static String _joinURL(
    final String parent,
    final String child, {
    final bool removeParentLastRoute = true,
  }) {
    final sParent = parent.split('/');
    final sChild = child.split('/');

    if (removeParentLastRoute) sParent.removeLast();

    var done = false;
    while (!done) {
      if (sChild[0] == '.') {
        sChild.removeAt(0);
      } else if (sChild[0] == '..') {
        sParent.removeLast();
        sChild.removeAt(0);
      } else {
        done = true;
      }
    }

    if (sParent.last != '') sParent.add('');
    if (sChild.first == '') sChild.removeAt(0);

    return sParent.join('/') + sChild.join('/');
  }
}

enum M3U8OutputFileExtensions {
  ts,
  mpeg,
}

extension M3U8OutputFileExtensionsUtils on M3U8OutputFileExtensions {
  String get ext => '.$name';
}

class M3U8DLProvider extends RawDLProvider {
  const M3U8DLProvider({
    this.outputFileExtension = M3U8OutputFileExtensions.ts,
  });

  final M3U8OutputFileExtensions outputFileExtension;

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required HttpClient client,
  }) async {
    final masterRes = await super.download(url: url, client: client);

    final masterData = await resolveStream(masterRes.data);
    final masterM3U8 = M3U8Utils.parseM3U8(
      url: url.toString(),
      data:
          utf8.decode(masterData.fold<List<int>>([], (pv, x) => pv..addAll(x))),
    );

    final progress = DLProgress.create();
    final dataStreamCompleter = Completer<void>();

    return PartialDLResponse(
      request: masterRes.request,
      response: masterRes.response,
      data: _getDataStream(
        client: client,
        masterM3U8: masterM3U8,
        progress: progress,
      ).transform(
        StreamTransformer.fromHandlers(
          handleDone: (sink) async {
            sink.close();
            dataStreamCompleter.complete();
          },
          handleError: (Object error, StackTrace stacktrace, EventSink sink) {
            sink.addError(error, stacktrace);
            dataStreamCompleter.completeError(error, stacktrace);
          },
        ),
      ),
      progress: progress.stream,
      onDoneFutures: [progress.done, dataStreamCompleter.future],
    );
  }

  Stream<List<int>> _getDataStream({
    required final HttpClient client,
    required final List<M3U8Item> masterM3U8,
    required final StreamController<DLProgress> progress,
  }) async* {
    var downloadedLength = 0;
    const totalLength = -1;
    final extraDetails = <dynamic, dynamic>{
      'currentPart': 0,
      'totalParts': masterM3U8.length,
      'currentPartTotalLength': -1,
    };

    for (final x in masterM3U8) {
      final currentRes =
          await super.download(url: Uri.parse(x.url), client: client);
      extraDetails['currentPartTotalLength'] =
          currentRes.response.contentLength;

      yield* currentRes.data.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(data);

            downloadedLength += data.length;
            progress.add(
              DLProgress(
                downloadedLength,
                totalLength,
                extraDetails: extraDetails,
              ),
            );
          },
          handleDone: (sink) {
            sink.close();

            extraDetails['currentPart'] =
                (extraDetails['currentPart'] as int) + 1;
            progress.add(
              DLProgress(
                downloadedLength,
                totalLength,
                extraDetails: extraDetails,
              ),
            );
          },
          handleError: (Object error, StackTrace stacktrace, EventSink sink) {
            sink.addError(error, stacktrace);
            progress.addError(error, stacktrace);
          },
        ),
      );
    }

    progress.add(
      DLProgress(
        downloadedLength,
        totalLength,
        finished: true,
        extraDetails: extraDetails,
      ),
    );
    await progress.close();
  }

  @override
  String resolveFilename(final String filename) {
    final ext = outputFileExtension.ext;
    if (filename.endsWith(ext)) return filename;
    if (filename.endsWith('.m3u8')) {
      return '${filename.substring(0, filename.length - 5)}$ext';
    }
    return '$filename$ext';
  }
}
