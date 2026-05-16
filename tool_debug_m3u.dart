import 'dart:io';
import 'dart:convert';

void main() async {
  print('--- TESTING CATEGORIZATION WITH FINAL LOGIC (v16) ---\n');

  await testFile('canais.m3u', 'CHANNEL');
  await testFile('filmes.m3u', 'MOVIES');
  await testFile('series.m3u', 'SERIES');

  print('\n--- ALL TESTS DONE ---');
}

Future<void> testFile(String filename, String expectedType) async {
  final file = File('d:/APPS GRAVITY/APPS/startflix/$filename');
  if (!await file.exists()) {
    print('File not found: $filename');
    return;
  }

  // Use the same decoding logic as the app
  final bytes = await file.readAsBytes();
  String decoded;
  try {
    decoded = utf8.decode(bytes);
  } catch (e) {
    decoded = latin1.decode(bytes);
  }

  final lines = LineSplitter.split(decoded).toList();
  print('Testing $filename (${lines.length} lines)...');

  int correct = 0;
  int totalItems = 0;
  Map<String, int> misclassifiedAs = {};

  String? pendingExtinf;

  for (final line in lines) {
    if (line.isEmpty) continue;
    if (line.startsWith('#EXTINF')) {
      pendingExtinf = line;
    } else if (pendingExtinf != null && !line.startsWith('#')) {
      totalItems++;
      final item = parseItem(pendingExtinf, line);

      String actualType = 'CHANNEL';
      if (item['isSeries']) {
        actualType = 'SERIES';
      } else if (item['isMovie'])
        actualType = 'MOVIES';

      if (actualType == expectedType) {
        correct++;
      } else {
        misclassifiedAs[actualType] = (misclassifiedAs[actualType] ?? 0) + 1;
        if (misclassifiedAs.values.reduce((a, b) => a + b) < 3) {
          print(
            '  Mismatch: [${item['group']}] ${item['name']} -> Categorized as $actualType (Expected $expectedType)',
          );
          print('  URL: $line');
        }
      }
      pendingExtinf = null;
    }
  }

  print(
    'Result for $filename: $correct/$totalItems CORRECT (${(correct / totalItems * 100).toStringAsFixed(1)}%)',
  );
  if (misclassifiedAs.isNotEmpty) {
    print('  Misclassified as: $misclassifiedAs');
  }
}

Map<String, dynamic> parseItem(String extinfLine, String url) {
  String rawName = "Sem Nome";
  final commaIndex = extinfLine.lastIndexOf(',');
  if (commaIndex != -1 && commaIndex < extinfLine.length - 1) {
    rawName = extinfLine.substring(commaIndex + 1).trim();
  }

  String? group = _getAttrValue(extinfLine, 'group-title');
  group ??= _getAttrValue(extinfLine, 'tvg-group');
  group ??= "Geral";

  final isSeries = _fastIsSeries(group, rawName, url);
  final isMovie = _fastIsMovie(group, rawName, url, isSeries);

  return {
    'name': rawName,
    'group': group,
    'isSeries': isSeries,
    'isMovie': isMovie,
  };
}

String? _getAttrValue(String line, String attrName) {
  final key = '$attrName="';
  int start = line.indexOf(key);
  if (start == -1) return null;
  start += key.length;
  final end = line.indexOf('"', start);
  if (end == -1) return null;
  return line.substring(start, end);
}

// --- LOGIC REPLICATED FROM M3U_SERVICE.DART ---

String _classifyClean(String s) {
  return s
      .toLowerCase()
      .replaceAll('Ã¡', 'a')
      .replaceAll('Ã¢', 'a')
      .replaceAll('Ã£', 'a')
      .replaceAll('Ã©', 'e')
      .replaceAll('Ãª', 'e')
      .replaceAll('Ã­', 'i')
      .replaceAll('Ã³', 'o')
      .replaceAll('Ã´', 'o')
      .replaceAll('Ãµ', 'o')
      .replaceAll('Ãº', 'u')
      .replaceAll('Ã§', 'c')
      .replaceAll('ã¡', 'a')
      .replaceAll('ã£', 'a')
      .replaceAll('ã©', 'e')
      .replaceAll('ã§', 'c')
      .trim();
}

bool _isVodUrl(String u) {
  if (u.contains('#.mp4') || u.contains('#.mkv') || u.contains('#.avi')) {
    return true;
  }
  if (u.endsWith('.mp4') ||
      u.endsWith('.mkv') ||
      u.endsWith('.avi') ||
      u.endsWith('.webm') ||
      u.endsWith('.m4v')) {
    return true;
  }
  return false;
}

bool _fastIsSeries(String group, String name, String url) {
  final u = url.toLowerCase();
  if (u.contains('/series/') ||
      u.contains('/serie/') ||
      u.contains('type=series')) {
    return true;
  }

  final n = name.toLowerCase();
  if (n.contains(RegExp(r'\bs\d{1,2}\s*[-.:]?\s*e\d{1,2}\b')) ||
      n.contains(RegExp(r'\bt\d{1,2}\s*ep\d{1,2}\b')) ||
      n.contains(RegExp(r'\b\d{1,2}x\d{1,2}\b')) ||
      n.contains(RegExp(r'\bcap[ií]tulo\s*\d+\b'))) {
    return true;
  }

  final g = _classifyClean(group);
  final isVod = _isVodUrl(u);

  if (g.contains('serie') ||
      g.contains('season') ||
      g.contains('temporada') ||
      g.contains('episodio') ||
      g.contains('novelas') ||
      g.contains('animes') ||
      g.contains('doramas') ||
      g.contains('desenhos') ||
      g.contains('netflix') ||
      g.contains('globoplay') ||
      g.contains('amazon prime') ||
      g.contains('disney+') ||
      g.contains('hbo max')) {
    if (!isVod &&
        (g.contains('24h') ||
            g.contains('canais') ||
            g.contains('ao vivo') ||
            g.contains('filmes'))) {
      if (n.contains(RegExp(r'\bs\d{1,2}\b'))) return true;
      return false;
    }
    return true;
  }
  return false;
}

bool _fastIsMovie(String group, String name, String url, bool isSeries) {
  if (isSeries) return false;
  final u = url.toLowerCase();

  if (u.contains('/movie/') ||
      u.contains('type=movie') ||
      u.contains('type=vod')) {
    return true;
  }

  final isVod = _isVodUrl(u);
  if (isVod) {
    if (u.contains('/live/') || u.contains('type=live')) return false;
    return true;
  }
  final g = _classifyClean(group);
  final n = name.toLowerCase();

  if (_isBroadcasterName(n)) {
    if (!n.contains(RegExp(r'\(\d{4}\)'))) return false;
  }

  if (g.contains('filmes') ||
      g.contains('movies') ||
      g.contains('vod') ||
      g.contains('ondemand') ||
      g.contains('box office') ||
      g.contains('cine') ||
      g.contains('cinema') ||
      g.contains('4k') ||
      g.contains('lancamento')) {
    if (!isVod &&
        (g.contains('canais') ||
            g.contains('24h') ||
            g.contains('ao vivo') ||
            g.contains('filmes') ||
            g.contains('series'))) {
      if (n.contains('dublado') ||
          n.contains('legendado') ||
          n.contains('dual') ||
          n.contains('multi')) {
        return true;
      }
      if (n.contains(RegExp(r'\(\d{4}\)'))) return true;
      return false;
    }
    return true;
  }
  if (g.contains('acao') ||
      g.contains('comedia') ||
      g.contains('terror') ||
      g.contains('suspense') ||
      g.contains('drama') ||
      g.contains('romance') ||
      g.contains('infantil') ||
      g.contains('adulto') ||
      g.contains('documentario') ||
      g.contains('faroeste') ||
      g.contains('guerra') ||
      g.contains('ficcao')) {
    if (!isVod && _fastIsChannelGroup(g)) {
      if (n.contains(RegExp(r'\(\d{4}\)'))) return true;
      if (n.contains('dublado') ||
          n.contains('legendado') ||
          n.contains('dual') ||
          n.contains('multi')) {
        return true;
      }
      return false;
    }
    return true;
  }
  if (n.contains(RegExp(r'\(\d{4}\)'))) return true;
  return false;
}

bool _fastIsChannelGroup(String groupLower) {
  return groupLower.contains('tv') ||
      groupLower.contains('canais') ||
      groupLower.contains('aberto') ||
      groupLower.contains('esporte') ||
      groupLower.contains('noticias') ||
      groupLower.contains('religioso') ||
      groupLower.contains('bbb') ||
      groupLower.contains('radio') ||
      groupLower.contains('24h');
}

bool _isBroadcasterName(String nameLower) {
  return nameLower.contains('globo') ||
      nameLower.contains('sbt') ||
      nameLower.contains('record') ||
      nameLower.contains('band') ||
      nameLower.contains('espn') ||
      nameLower.contains('hbo') ||
      nameLower.contains('telecine') ||
      nameLower.contains('sportv') ||
      nameLower.contains('fox') ||
      nameLower.contains('discovery') ||
      nameLower.contains('disney') ||
      nameLower.contains('cartoon') ||
      nameLower.contains('tnt') ||
      nameLower.contains('cnn') ||
      nameLower.contains('combate');
}
