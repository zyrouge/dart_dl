String? parseFilenameFromContentDisposition(final String value) =>
    RegExp('filename=[\'"]?([\\w,\\s-.]+)[\'"]?;?').firstMatch(value)?.group(1);

String? parseFilenameFromURL(final String url) =>
    RegExp(r'\/([\w,\s-.]+)\??[^\/]+$').firstMatch(url)?.group(1);
