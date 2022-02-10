import 'dart:async';

String? parseFilenameFromContentDisposition(final String value) =>
    RegExp('filename=[\'"]?([\\w,\\s-.]+)[\'"]?;?').firstMatch(value)?.group(1);

String? parseFilenameFromURL(final String url) {
  try {
    var _url = url;
    if (_url.endsWith('/')) _url = _url.substring(0, _url.length - 1);
    if (url.isNotEmpty) return _url.split('/').last.split('?').first;
  } catch (_) {}
  return null;
}

Future<List<T>> resolveStream<T>(final Stream<T> stream) async {
  final completer = Completer<List<T>>();
  final data = <T>[];

  stream.listen(
    data.add,
    onDone: () {
      completer.complete(data);
    },
    onError: (Object error, StackTrace stack) {
      completer.completeError(error, stack);
    },
  );

  return completer.future;
}
