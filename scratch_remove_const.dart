import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  int changedFiles = 0;
  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('AppColors')) {
      // Find 'const ' and remove it if the statement contains AppColors.
      // But a simple regex: replace "const " with "" on lines containing AppColors.
      var lines = content.split('\n');
      var newLines = <String>[];
      var changed = false;
      for (var line in lines) {
        if (line.contains('AppColors') && line.contains('const ')) {
          newLines.add(line.replaceAll('const ', ''));
          changed = true;
        } else {
          newLines.add(line);
        }
      }
      if (changed) {
        file.writeAsStringSync(newLines.join('\n'));
        changedFiles++;
      }
    }
  }
  print('Removed const from $changedFiles files.');
}
