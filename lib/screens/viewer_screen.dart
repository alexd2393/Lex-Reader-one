import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../widgets/blue_light_filter.dart';
import '../viewers/pdf_viewer.dart';
import '../viewers/epub_viewer.dart';
import '../viewers/markdown_viewer.dart';
import '../viewers/excel_viewer.dart';
import '../viewers/docx_viewer.dart';
import '../viewers/pptx_viewer.dart';

class ViewerScreen extends StatefulWidget {
  final Document document;

  const ViewerScreen({super.key, required this.document});

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool _barsVisible = true;

  void _toggleBars() => setState(() => _barsVisible = !_barsVisible);

  Widget _buildViewer() {
    switch (widget.document.type) {
      case DocumentType.pdf:
        return PdfViewer(path: widget.document.path, onTap: _toggleBars);
      case DocumentType.epub:
        return EpubViewer(path: widget.document.path, onTap: _toggleBars);
      case DocumentType.markdown:
        return MarkdownViewer(path: widget.document.path, onTap: _toggleBars);
      case DocumentType.xlsx:
        return ExcelViewer(path: widget.document.path, onTap: _toggleBars);
      case DocumentType.docx:
        return DocxViewer(path: widget.document.path, onTap: _toggleBars);
      case DocumentType.pptx:
        return PptxViewer(path: widget.document.path, onTap: _toggleBars);
      default:
        return const Center(child: Text('Formato no soportado.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final theme = Theme.of(context);

    return BlueLightFilter(
      intensity: settings.blueLightIntensity,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // El viewer ocupa toda la pantalla
            _buildViewer(),

            // AppBar animada
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: _barsVisible ? 0 : -120,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          widget.document.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () =>
                            FileService.shareDocument(widget.document),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
