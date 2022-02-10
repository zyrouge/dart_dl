import 'dart:async';
import 'dart:io';
import 'provider.dart';
import 'response/exports.dart';
import 'utils.dart';

class Downloader<T extends DLProvider> {
  const Downloader({
    required this.provider,
    final this.client,
  });

  final T provider;
  final HttpClient? client;

  Future<DLResponse> download(final Uri url) async {
    final partial = await provider.download(url: url, client: _client);

    return DLResponse.fromPartialDLResponse(
      partial,
      asFuture: () => partial.progress.listen((_) {}).asFuture<void>(),
    );
  }

  Future<FileDLResponse> downloadToDirectory(
    final Uri url,
    final Directory directory, {
    final String? filename,
    final String? defaultFilename,
    final bool overwriteFile = false,
  }) async {
    final res = await download(url);

    final contentDisposition =
        res.response.headers.value('content-disposition');

    final finalFilename = filename ??
        (contentDisposition != null
            ? parseFilenameFromContentDisposition(contentDisposition)
            : parseFilenameFromURL(res.request.uri.toString())) ??
        defaultFilename;

    if (finalFilename == null) throw Exception('Unable to determine file name');

    final file = File('${directory.path}/$finalFilename');

    return _downloadToFile(
      res,
      file,
      overwriteFile: overwriteFile,
    );
  }

  Future<FileDLResponse> downloadToFile(
    final Uri url,
    final File file, {
    final bool overwriteFile = false,
  }) async =>
      _downloadToFile(
        await download(url),
        file,
        overwriteFile: overwriteFile,
      );

  Future<FileDLResponse> _downloadToFile(
    final PartialDLResponse res,
    final File file, {
    final bool overwriteFile = false,
  }) async {
    final fileExists = file.existsSync();
    if (!fileExists) {
      await file.create(recursive: true);
    } else {
      if (!overwriteFile) throw Exception('File already exists');
      await file.writeAsBytes([]);
    }

    final writeStream = file.openWrite();
    unawaited(res.data.pipe(writeStream));

    return FileDLResponse.fromPartialDLResponse(
      res,
      file: file,
      asFuture: () => writeStream.done,
    );
  }

  HttpClient get _client => client ?? _defaultClient;

  static final _defaultClient = HttpClient();
}
