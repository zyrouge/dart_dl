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

String joinURL(
  final String parent,
  final String child, {
  final bool removeParentLastRoute = false,
}) {
  final sParent = parent.split('/');
  final sChild = child.split('/');

  if (removeParentLastRoute) sParent.removeLast();

  var done = false;
  while (!done) {
    if (sChild[0] == '.') {
      sChild.removeAt(0);
    } else if (sChild[0] == '..') {
      sParent.removeLast();
      sChild.removeAt(0);
    } else {
      done = true;
    }
  }

  if (sParent.last != '') sParent.add('');
  if (sChild.first == '') sChild.removeAt(0);

  return sParent.join('/') + sChild.join('/');
}
