import 'package:test/test.dart';
import '_utils.dart';

Future<void> main() async {
  setUpAll(() async {
    await getTrashDir(deleteDir: true);
  });
}
