import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio que llama al lado Android (Kotlin + Apache POI)
/// para convertir DOCX → HTML y PPTX → lista de imágenes PNG.
class ConverterService {
  static const _channel = MethodChannel('com.lexreader/converter');

  /// Convierte un .docx a HTML. Retorna el string HTML.
  static Future<String> docxToHtml(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final html = await _channel.invokeMethod<String>('docxToHtml', {
        'path': filePath,
        'outDir': tempDir.path,
      });
      return html ?? '<p>No se pudo procesar el documento.</p>';
    } on PlatformException catch (e) {
      return '<p>Error al convertir DOCX: ${e.message}</p>';
    }
  }

  /// Convierte un .pptx a imágenes PNG. Retorna lista de rutas absolutas.
  static Future<List<String>> pptxToImages(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final paths = await _channel.invokeMethod<List<dynamic>>('pptxToImages', {
        'path': filePath,
        'outDir': tempDir.path,
      });
      return paths?.map((p) => p.toString()).toList() ?? [];
    } on PlatformException catch (e) {
      return [];
    }
  }

  /// Limpia el directorio temporal de conversiones anteriores.
  static Future<void> clearTemp() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();
    for (final f in files) {
      if (f.path.contains('lexreader_')) {
        try {
          await f.delete(recursive: true);
        } catch (_) {}
      }
    }
  }
}
