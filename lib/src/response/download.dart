import 'dart:async';
import 'dart:io';
import 'partial.dart';
import 'progress.dart';

typedef DLResponseAsFuture = Future<void> Function();

class DLResponse extends PartialDLResponse {
  const DLResponse({
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

  factory DLResponse.fromPartialDLResponse(
    final PartialDLResponse partialDlResponse, {
    required final DLResponseAsFuture asFuture,
  }) =>
      DLResponse(
        request: partialDlResponse.request,
        response: partialDlResponse.response,
        data: partialDlResponse.data,
        progress: partialDlResponse.progress,
        asFuture: asFuture,
      );

  final DLResponseAsFuture asFuture;
}
