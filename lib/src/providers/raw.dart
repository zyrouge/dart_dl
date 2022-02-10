import 'dart:async';
import 'dart:io';
import '../provider.dart';
import '../response/exports.dart';

class RawDLProvider extends DLProvider {
  const RawDLProvider();

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required HttpClient client,
  }) async {
    final req = await client.getUrl(url);
    final res = await req.close();
    final progress = StreamController<DLProgress>.broadcast();

    var downloadedLength = 0;
    final totalLength = res.contentLength;

    return PartialDLResponse(
      request: req,
      response: res,
      data: res.asBroadcastStream().transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) {
                sink.add(data);

                downloadedLength += data.length;
                progress.add(DLProgress(downloadedLength, totalLength));
              },
              handleDone: (sink) {
                sink.close();
                progress
                  ..add(
                    DLProgress(downloadedLength, totalLength, finished: true),
                  )
                  ..close();
              },
              handleError:
                  (Object error, StackTrace stacktrace, EventSink sink) {
                sink.addError(error, stacktrace);
                progress.addError(error, stacktrace);
              },
            ),
          ),
      progress: progress.stream,
    );
  }
}
