# Dart DL

Simple library to download files.

[![Tests](https://github.com/zyrouge/dart_dl/actions/workflows/tests.yml/badge.svg)](https://github.com/zyrouge/dart_dl/actions/workflows/tests.yml)

## Links

-   [GitHub](https://github.com/zyrouge/dart_dl)
-   [Pub.dev](https://pub.dev/packages/dl)
-   [Documentation](https://pub.dev/documentation/dl/latest)

## Features

-   Uses native `dart:io` to get data.
-   Ability to parse different kind of files.

## Usage

```dart
import 'dart:io';
import 'import:dl/dl.dart';

Future<void> main() async {
    const downloader = Downloader(provider: RawDLProvider());
    final res = await downloader.downloadToFile(
        Uri.parse('https://jaspervdj.be/lorem-markdownum/markdown.txt'),
        File('lipsum.md'),
        overwriteFile: true,
    );

    await res.asFuture();
}
```

Checkout `/example` folder for examples.
