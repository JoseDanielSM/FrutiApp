import 'dart:convert';
import 'dart:html';

Future<void> downloadJson(String content, String filename) async {
  final bytes = utf8.encode(content);
  final blob = Blob([bytes]);
  final url = Url.createObjectUrlFromBlob(blob);

  final anchor = AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';

  document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  Url.revokeObjectUrl(url);
}
