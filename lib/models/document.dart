import 'dart:io';

enum DocumentType { pdf, epub, docx, pptx, xlsx, markdown, unknown }

class Document {
  final String path;
  final String name;
  final DocumentType type;
  final int sizeBytes;
  final DateTime lastOpened;

  Document({
    required this.path,
    required this.name,
    required this.type,
    required this.sizeBytes,
    required this.lastOpened,
  });

  static DocumentType typeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return DocumentType.pdf;
      case 'epub':
        return DocumentType.epub;
      case 'docx':
      case 'doc':
        return DocumentType.docx;
      case 'pptx':
      case 'ppt':
        return DocumentType.pptx;
      case 'xlsx':
      case 'xls':
        return DocumentType.xlsx;
      case 'md':
      case 'markdown':
        return DocumentType.markdown;
      default:
        return DocumentType.unknown;
    }
  }

  static String labelFromType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.epub:
        return 'EPUB';
      case DocumentType.docx:
        return 'DOCX';
      case DocumentType.pptx:
        return 'PPTX';
      case DocumentType.xlsx:
        return 'XLSX';
      case DocumentType.markdown:
        return 'MD';
      case DocumentType.unknown:
        return '?';
    }
  }

  static Document fromFile(File file) {
    final stat = file.statSync();
    return Document(
      path: file.path,
      name: file.path.split('/').last,
      type: typeFromPath(file.path),
      sizeBytes: stat.size,
      lastOpened: DateTime.now(),
    );
  }

  String get sizeLabel {
    if (sizeBytes < 1024) return '${sizeBytes}B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
