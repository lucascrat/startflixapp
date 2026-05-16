import 'dart:io';

void main() async {
  var result = await Process.run('adb', [
    'logcat',
    '-d',
    '-v',
    'time',
    '-t',
    '500',
  ]);
  var lines = result.stdout.toString().split('\n');
  for (var line in lines) {
    if (line.toLowerCase().contains('exception') ||
        line.toLowerCase().contains('fatal') ||
        line.toLowerCase().contains('error') ||
        line.toLowerCase().contains('crash')) {
      print(line);
    }
  }
}
