import 'dart:async';
import 'dart:io';
import '../response/exports.dart';

abstract class DLProvider {
  const DLProvider();

  Future<PartialDLResponse> download({
    required final Uri url,
    required HttpClient client,
  });

  String resolveFilename(final String filename) => filename;
}
