import 'dart:async';
import 'dart:io';
import 'providers/model.dart';
import 'response/exports.dart';
import 'utils.dart';

/// Represents top-level downloader.
class Downloader<T extends DLProvider> {
  const Downloader({
    required this.provider,
    final this.client,
  });

  final T provider;
  final HttpClient? client;

  /// Downloads an URL and returns a stream that can be consumed.
  Future<DLResponse> download({
    required final Uri url,
    final Map<String, String> headers = _defaultHeaders,
  }) async {
    final PartialDLResponse res = await provider.download(
      url: url,
      headers: headers,
      client: _client,
    );

    return DLResponse.fromPartialDLResponse(res);
  }

  /// Downloads an URL and returns a stream that finishes when the output file is fully written.
  Future<FileDLResponse> downloadToDirectory({
    required final Uri url,
    required final Directory directory,
    final Map<String, String> headers = _defaultHeaders,
    final String? filename,
    final String? defaultFilename,
    final bool overwriteFile = false,
  }) async {
    final DLResponse res = await download(url: url, headers: headers);

    final String? contentDisposition =
        res.response.headers.value('content-disposition');

    String? finalFilename = filename ??
        (contentDisposition != null
            ? parseFilenameFromContentDisposition(contentDisposition)
            : parseFilenameFromURL(res.request.uri.toString())) ??
        defaultFilename;

    if (finalFilename == null) throw Exception('Unable to determine file name');
    finalFilename = provider.resolveFilename(finalFilename);

    final File file = File('${directory.path}/$finalFilename');

    return downloadToFileFromDLResponse(
      res,
      file,
      overwriteFile: overwriteFile,
    );
  }

  /// Downloads an URL and returns a stream that finishes when the output file is fully written.
  Future<FileDLResponse> downloadToFile({
    required final Uri url,
    required final File file,
    final Map<String, String> headers = _defaultHeaders,
    final bool overwriteFile = false,
  }) async =>
      downloadToFileFromDLResponse(
        await download(url: url, headers: headers),
        file,
        overwriteFile: overwriteFile,
      );

  /// Takes in a download response and returns a stream that finishes when the output file is fully written.
  Future<FileDLResponse> downloadToFileFromDLResponse(
    final DLResponse res,
    final File file, {
    final bool overwriteFile = false,
  }) async {
    final bool fileExists = file.existsSync();
    if (!fileExists) {
      await file.create(recursive: true);
    } else {
      if (!overwriteFile) throw Exception('File already exists');
      await file.writeAsBytes(<int>[]);
    }

    final IOSink writeStream = file.openWrite();
    unawaited(res.data.pipe(writeStream));

    res.onDoneFutures.add(writeStream.done);
    return FileDLResponse.fromPartialDLResponse(res, file: file);
  }

  HttpClient get _client => client ?? _defaultClient;

  static final HttpClient _defaultClient = HttpClient();

  static const Map<String, String> _defaultHeaders = <String, String>{};
}
