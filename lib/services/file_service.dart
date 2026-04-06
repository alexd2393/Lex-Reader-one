import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document.dart';

class FileService {
  // Historial en memoria (en producción podrías persistir con SharedPreferences)
  static final List<Document> _recentDocs = [];

  static List<Document> get recentDocuments => List.unmodifiable(_recentDocs);

  /// Abre el selector de archivos del sistema y retorna el documento elegido.
  static Future<Document?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'epub',
        'docx', 'doc',
        'pptx', 'ppt',
        'xlsx', 'xls',
        'md', 'markdown',
      ],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.first;
    if (picked.path == null) return null;

    final doc = Document.fromFile(File(picked.path!));
    _addToRecent(doc);
    return doc;
  }

  /// Agrega al historial sin duplicar, máximo 20 items.
  static void _addToRecent(Document doc) {
    _recentDocs.removeWhere((d) => d.path == doc.path);
    _recentDocs.insert(0, doc);
    if (_recentDocs.length > 20) _recentDocs.removeLast();
  }

  static void registerOpened(Document doc) => _addToRecent(doc);

  /// Comparte el archivo usando el sistema nativo de Android.
  static Future<void> shareDocument(Document doc) async {
    await Share.shareXFiles(
      [XFile(doc.path)],
      subject: doc.name,
    );
  }

  static void removeFromRecent(String path) {
    _recentDocs.removeWhere((d) => d.path == path);
  }
}
