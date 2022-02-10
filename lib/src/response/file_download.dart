import 'dart:async';
import 'dart:io';
import 'download.dart';
import 'partial.dart';
import 'progress.dart';

class FileDLResponse extends PartialDLResponse {
  const FileDLResponse({
    required this.file,
    required final HttpClientRequest request,
    required final HttpClientResponse response,
    required final Stream<List<int>> data,
    required final Stream<DLProgress> progress,
    required this.asFuture,
  }) : super(
          request: request,
          response: response,
          data: data,
          progress: progress,
        );

  factory FileDLResponse.fromPartialDLResponse(
    final PartialDLResponse partialDlResponse, {
    required final File file,
    required final DLResponseAsFuture asFuture,
  }) =>
      FileDLResponse(
        file: file,
        request: partialDlResponse.request,
        response: partialDlResponse.response,
        data: partialDlResponse.data,
        progress: partialDlResponse.progress,
        asFuture: asFuture,
      );

  final File file;
  final DLResponseAsFuture asFuture;
}
