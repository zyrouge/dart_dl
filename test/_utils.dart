// ignore_for_file: avoid_print

import 'dart:io';

void debugPrint(final Object data) => print('\u001b[90mͰ $data\u001b[0m');

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

final Directory _trashDir = Directory('test/trash');
bool _hasTrashedDir = false;
Future<Directory> getTrashDir() async {
  if (!_hasTrashedDir) {
    if (_trashDir.existsSync()) {
      await _trashDir.delete(recursive: true);
    }
    await _trashDir.create(recursive: true);
    _hasTrashedDir = true;
  }

  return _trashDir;
}
