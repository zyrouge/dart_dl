// ignore_for_file: avoid_print

import 'dart:io';

const prefixSpacer = '    ';

void debugPrint(final Object data) =>
    print('\u001b[36m$prefixSpacer$data\u001b[0m');

final trashDir = Directory('test/trash');

Future<void> ensureFile(final File file) async {
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
}

Future<void> ensureDirectory(final Directory directory) async {
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

var _hasTrashedDir = false;
Future<Directory> getTrashDir({
  final bool deleteDir = false,
}) async {
  if (deleteDir) {
    await trashDir.delete(recursive: true);
  }

  if (!_hasTrashedDir) {
    await ensureDirectory(trashDir);
    _hasTrashedDir = true;
  }

  return trashDir;
}
