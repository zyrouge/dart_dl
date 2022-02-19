import 'dart:async';
import 'dart:io';
import 'partial.dart';
import 'progress.dart';

/// Represents a fully computed file download response.
class FileDLResponse extends PartialDLResponse {
  const FileDLResponse({
    required this.file,
    required final HttpClientRequest request,
    required final HttpClientResponse response,
    required final Stream<List<int>> data,
    required final Stream<DLProgress> progress,
    required final List<Future<void>> onDoneFutures,
  }) : super(
          request: request,
          response: response,
          data: data,
          progress: progress,
          onDoneFutures: onDoneFutures,
        );

  factory FileDLResponse.fromPartialDLResponse(
    final PartialDLResponse partialDlResponse, {
    required final File file,
  }) =>
      FileDLResponse(
        file: file,
        request: partialDlResponse.request,
        response: partialDlResponse.response,
        data: partialDlResponse.data,
        progress: partialDlResponse.progress,
        onDoneFutures: partialDlResponse.onDoneFutures,
      );

  final File file;

  Future<void> asFuture() async => Future.wait(onDoneFutures);
}
