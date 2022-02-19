import 'dart:async';
import 'dart:io';
import 'partial.dart';
import 'progress.dart';

/// Represents a fully computed download response.
class DLResponse extends PartialDLResponse {
  const DLResponse({
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

  factory DLResponse.fromPartialDLResponse(
    final PartialDLResponse partialDlResponse,
  ) =>
      DLResponse(
        request: partialDlResponse.request,
        response: partialDlResponse.response,
        data: partialDlResponse.data,
        progress: partialDlResponse.progress,
        onDoneFutures: partialDlResponse.onDoneFutures,
      );

  Future<void> asFuture() async => Future.wait(onDoneFutures);
}
