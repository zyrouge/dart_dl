import 'dart:async';
import 'dart:io';
import '../response/exports.dart';
import 'model.dart';

class RawDLProvider extends DLProvider {
  const RawDLProvider();

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required HttpClient client,
  }) async {
    final req = await client.getUrl(url);
    final res = await req.close();
    final progress = DLProgress.create();

    var downloadedLength = 0;
    final totalLength = res.contentLength;

    return PartialDLResponse(
      request: req,
      response: res,
      data: res.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add(data);

            downloadedLength += data.length;
            progress.add(DLProgress(downloadedLength, totalLength));
          },
          handleDone: (sink) async {
            sink.close();
            await progress.close();
          },
          handleError: (Object error, StackTrace stacktrace, EventSink sink) {
            sink.addError(error, stacktrace);
            progress.addError(error, stacktrace);
          },
        ),
      ),
      progress: progress.stream,
      onDoneFutures: [progress.done],
    );
  }
}
