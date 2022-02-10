// ignore_for_file: avoid_print

import 'dart:io';

final prefixSpacer = List.filled(10, ' ').join();

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

Future<Directory> getTrashDir() async {
  await ensureDirectory(trashDir);
  return trashDir;
}
