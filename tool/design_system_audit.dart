// Counts visual literals that bypass the design system.
//
// Run from the repo root:  dart run tool/design_system_audit.dart
// Scans lib/ except lib/theme/ (the token source) and generated files.
// Pass --shared to also exclude lib/shared/ (the component library), which is
// the scope the guardrail test will enforce.
//
// Numbers are tracked in docs/design-system/CHANGELOG.md after every slice.
import 'dart:io';

final checks = <String, RegExp>{
  'Colors.* (excl. transparent)': RegExp(r'\bColors\.(?!transparent\b)\w+'),
  'Color(0x…) literal': RegExp(r'\bColor\(0x'),
  'withOpacity/withValues(alpha)': RegExp(r'\.(withOpacity|withValues)\('),
  'static StillwaterColors.*': RegExp(r'\bStillwaterColors\.\w+'),
  'raw fontSize:': RegExp(r'\bfontSize:\s*[0-9]'),
  'TextStyle( constructor': RegExp(r'(?<![\w.])TextStyle\('),
  'GoogleFonts.': RegExp(r'\bGoogleFonts\.'),
  'BorderRadius.circular(<number>)': RegExp(
    r'BorderRadius\.circular\(\s*[0-9]',
  ),
  'EdgeInsets with numbers': RegExp(
    r'EdgeInsets(Directional)?\.\w+\([^)]*?\b[0-9]+(\.[0-9]+)?\b',
  ),
  'SizedBox(width/height: <number>)': RegExp(
    r'SizedBox\(\s*(width|height):\s*[0-9]',
  ),
  'inline Duration(milliseconds:)': RegExp(r'Duration\(\s*milliseconds:'),
  'AppBar(': RegExp(r'(?<![\w.])(SliverAppBar|AppBar)\('),
  'showModalBottomSheet': RegExp(r'\bshowModalBottomSheet\b'),
  'showDialog / AlertDialog': RegExp(r'\b(showDialog|AlertDialog)\b'),
  'showDatePicker / showDateRangePicker': RegExp(
    r'\bshow(Date|DateRange|Time)Picker\b',
  ),
  'ScaffoldMessenger': RegExp(r'\bScaffoldMessenger\b'),
  'DropdownButton / PopupMenuButton': RegExp(
    r'\b(DropdownButton(FormField)?|DropdownMenu|PopupMenuButton)\b',
  ),
  'Divider(': RegExp(r'(?<![\w.])(Divider|VerticalDivider)\('),
  'raw progress indicators': RegExp(
    r'(?<![\w.])(CircularProgressIndicator|LinearProgressIndicator)\(',
  ),
  'Theme.of(context).colorScheme / context.colorScheme': RegExp(
    r'(Theme\.of\(context\)|context\.theme|context)\.colorScheme',
  ),
};

void main(List<String> args) {
  final excludeShared = args.contains('--shared');
  final files =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .where((p) => p.endsWith('.dart'))
          .where((p) => !p.endsWith('.g.dart') && !p.endsWith('.freezed.dart'))
          .where((p) => !p.startsWith('lib/theme/'))
          .where((p) => !excludeShared || !p.startsWith('lib/shared/'))
          .toList()
        ..sort();

  final hits = <String, int>{};
  final fileHits = <String, Set<String>>{};
  final perFile = <String, int>{};
  for (final path in files) {
    final lines = File(path).readAsLinesSync();
    for (final line in lines) {
      final code = line.trimLeft();
      if (code.startsWith('//')) continue;
      checks.forEach((name, re) {
        final n = re.allMatches(line).length;
        if (n == 0) return;
        hits[name] = (hits[name] ?? 0) + n;
        (fileHits[name] ??= {}).add(path);
        if (!name.startsWith('Theme.of')) {
          perFile[path] = (perFile[path] ?? 0) + n;
        }
      });
    }
  }

  stdout.writeln(
    'Scope: lib/ minus lib/theme/${excludeShared ? ' and lib/shared/' : ''}'
    ' (${files.length} files)\n',
  );
  stdout.writeln('| Check | Hits | Files |');
  stdout.writeln('|---|---:|---:|');
  for (final name in checks.keys) {
    stdout.writeln(
      '| $name | ${hits[name] ?? 0} | ${fileHits[name]?.length ?? 0} |',
    );
  }
  final worst =
      perFile.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  stdout.writeln('\nTop 15 files by leak count:');
  for (final e in worst.take(15)) {
    stdout.writeln('${e.value.toString().padLeft(5)}  ${e.key}');
  }
}
