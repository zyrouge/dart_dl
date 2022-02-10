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
