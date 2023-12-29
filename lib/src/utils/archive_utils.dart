import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class ArchiveUtils {
  static Future<XmlDocument> toXML(final List<int> bytes) async {
    final Archive archive = ZipDecoder().decodeBytes(bytes);

    if (archive.isEmpty) {
      return XmlDocument();
    }

    // here, we get the first document from the archive
    // ! very slow
    final XmlDocument xml = XmlDocument.parse(String.fromCharCodes(archive.first.content));

    if (xml.children.length < 2) {
      return XmlDocument();
    }

    return xml;
  }
}
