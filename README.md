# Dart DL

Simple library to download files.

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
