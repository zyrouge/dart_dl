import 'dart:async';
import 'dart:io';
import '../response/exports.dart';

/// Interface of download provider. Can be used to create custom providers.
abstract class DLProvider {
  const DLProvider();

  /// Downloads a file.
  Future<PartialDLResponse> download({
    required final Uri url,
    required final Map<String, String> headers,
    required final HttpClient client,
  });

  /// This function is called to finalize the computed filename.
  String resolveFilename(final String filename) => filename;
}
