import 'dart:io';

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
