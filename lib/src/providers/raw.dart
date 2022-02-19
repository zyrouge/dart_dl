import 'dart:async';
import 'dart:io';
import '../response/exports.dart';
import 'model.dart';

/// Parser for any kind of file.
class RawDLProvider extends DLProvider {
  const RawDLProvider();

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required final Map<String, String> headers,
    required final HttpClient client,
  }) async {
    final HttpClientRequest req = await client.getUrl(url);
    for (final MapEntry<String, String> x in headers.entries) {
      req.headers.set(x.key, x.value);
    }
    final HttpClientResponse res = await req.close();
    final StreamController<DLProgress> progress = DLProgress.create();

    int downloadedLength = 0;
    final int totalLength = res.contentLength;

    return PartialDLResponse(
      request: req,
      response: res,
      data: res.transform<List<int>>(
        StreamTransformer<List<int>, List<int>>.fromHandlers(
          handleData: (final List<int> data, final EventSink<List<int>> sink) {
            sink.add(data);

            downloadedLength += data.length;
            progress.add(DLProgress(downloadedLength, totalLength));
          },
          handleDone: (final EventSink<List<int>> sink) async {
            sink.close();
            await progress.close();
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
      ),
      progress: progress.stream,
      onDoneFutures: <Future<void>>[progress.done],
    );
  }
}
