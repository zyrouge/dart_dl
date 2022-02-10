import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../response/exports.dart';
import '../utils.dart';
import 'raw.dart';

class M3U8Item {
  const M3U8Item(this.url, this.attributes);

  final String url;
  final Map<String, String> attributes;
}

abstract class M3U8Utils {
  static List<M3U8Item> parseM3U8({
    required final String url,
    required final String data,
  }) =>
      RegExp(r'#(EXT-X-STREAM-INF|EXTINF):([^\n]+)\n([^\n]+)')
          .allMatches(data)
          .map(
        (x) {
          final attributes = <String, String>{};
          for (final x in x.group(2)!.split(',')) {
            final parsed = x.trim().split('=');
            if (parsed.length == 2) {
              attributes[parsed[0]] = parsed[1];
            }
          }

          var route = x.group(3)!.trim();
          if (!route.startsWith('http')) {
            route = _joinURL(url, route);
          }

          return M3U8Item(route, attributes);
        },
      ).toList();

  static String _joinURL(
    final String parent,
    final String child, {
    final bool removeParentLastRoute = true,
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
}

class M3U8DLProvider extends RawDLProvider {
  const M3U8DLProvider();

  @override
  Future<PartialDLResponse> download({
    required final Uri url,
    required HttpClient client,
  }) async {
    final masterRes = await super.download(url: url, client: client);

    final masterData = await resolveStream(masterRes.data);
    final masterM3U8 = M3U8Utils.parseM3U8(
      url: url.toString(),
      data:
          utf8.decode(masterData.fold<List<int>>([], (pv, x) => pv..addAll(x))),
    );

    final progressStream = StreamController<DLProgress>.broadcast();

    var downloadedLength = 0;
    const totalLength = -1;
    final extraDetails = <dynamic, dynamic>{
      'currentPart': 0,
      'totalParts': masterM3U8.length,
    };

    final dataStream = StreamController<List<int>>.broadcast();
    var closed = false;

    dataStream
      ..onListen = () async {
        for (final x in masterM3U8) {
          if (closed) break;

          final currentRes =
              await super.download(url: Uri.parse(x.url), client: client);

          await currentRes.data.listen(
            (data) {
              dataStream.add(data);
              downloadedLength += data.length;
              progressStream.add(DLProgress(downloadedLength, totalLength));
            },
            onDone: () {
              extraDetails['currentPart'] =
                  (extraDetails['currentPart'] as int) + 1;
            },
            onError: (Object error, StackTrace stack) {
              dataStream.addError(error, stack);
              progressStream.addError(error, stack);
            },
          ).asFuture<void>();
        }

        progressStream
            .add(DLProgress(downloadedLength, totalLength, finished: true));

        await dataStream.close();
        await progressStream.close();
      }
      ..onCancel = () {
        closed = !dataStream.hasListener;
      };

    return PartialDLResponse(
      request: masterRes.request,
      response: masterRes.response,
      data: dataStream.stream,
      progress: progressStream.stream,
    );
  }

  @override
  String resolveFilename(final String filename) {
    if (filename.endsWith('.ts')) return filename;
    if (filename.endsWith('.m3u8')) {
      return '${filename.substring(0, filename.length - 5)}.ts';
    }
    return '$filename.ts';
  }
}
