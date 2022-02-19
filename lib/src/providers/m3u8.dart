import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../response/exports.dart';
import '../utils.dart';
import 'raw.dart';

class M3U8DLProvider extends RawDLProvider {
  const M3U8DLProvider({
    this.outputFileExtension = M3U8OutputFileExtensions.ts,
  });

  final M3U8OutputFileExtensions outputFileExtension;

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required final Map<String, String> headers,
    required final HttpClient client,
  }) async {
    final PartialDLResponse masterRes = await super.download(
      url: url,
      headers: headers,
      client: client,
    );

    final List<List<int>> masterData = await resolveStream(masterRes.data);
    final List<M3U8Item> masterM3U8 = parseM3U8(
      url: url.toString(),
      headers: headers,
      data: utf8.decode(
        masterData.fold<List<int>>(
          <int>[],
          (final List<int> pv, final List<int> x) => pv..addAll(x),
        ),
      ),
    );

    final StreamController<DLProgress> progress = DLProgress.create();
    final Completer<void> dataStreamCompleter = Completer<void>();

    return PartialDLResponse(
      request: masterRes.request,
      response: masterRes.response,
      data: _getDataStream(
        client: client,
        masterM3U8: masterM3U8,
        progress: progress,
      ).transform(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleDone: (final EventSink<List<int>> sink) async {
            sink.close();
            dataStreamCompleter.complete();
          },
          handleError: (
            final Object error,
            final StackTrace stacktrace,
            final EventSink<List<int>> sink,
          ) {
            sink.addError(error, stacktrace);
            dataStreamCompleter.completeError(error, stacktrace);
          },
        ),
      ),
      progress: progress.stream,
      onDoneFutures: <Future<void>>[progress.done, dataStreamCompleter.future],
    );
  }

  Stream<List<int>> _getDataStream({
    required final HttpClient client,
    required final List<M3U8Item> masterM3U8,
    required final StreamController<DLProgress> progress,
  }) async* {
    int downloadedLength = 0;
    const int totalLength = -1;
    final Map<dynamic, dynamic> extraDetails = <dynamic, dynamic>{
      'currentPart': 0,
      'totalParts': masterM3U8.length,
      'currentPartTotalLength': -1,
    };

    for (final M3U8Item x in masterM3U8) {
      final PartialDLResponse currentRes = await super.download(
        url: Uri.parse(x.url),
        headers: x.headers,
        client: client,
      );

      extraDetails['currentPartTotalLength'] =
          currentRes.response.contentLength;

      yield* currentRes.data.transform<List<int>>(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (final List<int> data, final EventSink<List<int>> sink) {
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
          handleDone: (final EventSink<List<int>> sink) {
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
          handleError: (
            final Object error,
            final StackTrace stacktrace,
            final EventSink<List<int>> sink,
          ) {
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
    final String ext = outputFileExtension.ext;
    if (filename.endsWith(ext)) return filename;
    if (filename.endsWith('.m3u8')) {
      return '${filename.substring(0, filename.length - 5)}$ext';
    }
    return '$filename$ext';
  }

  static List<M3U8Item> parseM3U8({
    required final String url,
    required final Map<String, String> headers,
    required final String data,
  }) =>
      RegExp(r'#(EXT-X-STREAM-INF|EXTINF):([^\n]+)\n([^\n]+)')
          .allMatches(data)
          .map(
        (final RegExpMatch x) {
          final Map<String, String> attributes = <String, String>{};
          for (final String x in x.group(2)!.split(',')) {
            final List<String> parsed = x.trim().split('=');
            if (parsed.length == 2) {
              attributes[parsed[0]] = parsed[1];
            }
          }

          String route = x.group(3)!.trim();
          if (!route.startsWith('http')) {
            route = joinURL(url, route, removeParentLastRoute: true);
          }

          return M3U8Item(route, headers, attributes);
        },
      ).toList();
}

class M3U8Item {
  const M3U8Item(this.url, this.headers, this.attributes);

  final String url;
  final Map<String, String> headers;
  final Map<String, String> attributes;
}

enum M3U8OutputFileExtensions {
  ts,
  mpeg,
}

extension M3U8OutputFileExtensionsUtils on M3U8OutputFileExtensions {
  String get ext => '.$name';
}
