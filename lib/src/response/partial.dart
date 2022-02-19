import 'dart:async';
import 'dart:io';
import 'progress.dart';

/// Represents a partial download response.
class PartialDLResponse {
  const PartialDLResponse({
    required this.request,
    required this.response,
    required this.data,
    required this.progress,
    required this.onDoneFutures,
  });

  final HttpClientRequest request;
  final HttpClientResponse response;
  final Stream<List<int>> data;
  final Stream<DLProgress> progress;
  final List<Future<void>> onDoneFutures;
}
