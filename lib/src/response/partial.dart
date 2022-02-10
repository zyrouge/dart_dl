import 'dart:async';
import 'dart:io';
import 'progress.dart';

class PartialDLResponse {
  const PartialDLResponse({
    required this.request,
    required this.response,
    required this.data,
    required this.progress,
  });

  final HttpClientRequest request;
  final HttpClientResponse response;
  final Stream<List<int>> data;
  final Stream<DLProgress> progress;
}
