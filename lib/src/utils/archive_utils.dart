import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class ArchiveUtils {
  /// Decodes the first XML document found in [bytes], a zip archive.
  ///
  /// The opendata feeds are served as ISO-8859-1, which [latin1] maps
  /// one byte to one code unit, so accented town names survive.
  static XmlDocument toXML(final List<int> bytes) {
    final Archive archive = ZipDecoder().decodeBytes(bytes);

    final ArchiveFile? file = archive.files.cast<ArchiveFile?>().firstWhere(
          (f) => f!.isFile && f.name.toLowerCase().endsWith('.xml'),
          orElse: () => null,
        );

    if (file == null) {
      return XmlDocument();
    }

    return XmlDocument.parse(latin1.decode(file.readBytes() ?? const []));
  }
}
