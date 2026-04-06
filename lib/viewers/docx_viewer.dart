import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/converter_service.dart';

class DocxViewer extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const DocxViewer({super.key, required this.path, required this.onTap});

  @override
  State<DocxViewer> createState() => _DocxViewerState();
}

class _DocxViewerState extends State<DocxViewer> {
  String? _html;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final html = await ConverterService.docxToHtml(widget.path);
      setState(() {
        _html = html;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Convirtiendo DOCX…'),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 40),
        child: Html(
          data: _html!,
          style: {
            'body': Style(
              fontSize: FontSize(16),
              lineHeight: LineHeight(1.7),
              color: isDark
                  ? const Color(0xFFDDDBD5)
                  : const Color(0xFF2A2820),
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'h1': Style(
              fontSize: FontSize(24),
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            'h2': Style(
              fontSize: FontSize(20),
              fontWeight: FontWeight.w600,
            ),
            'h3': Style(
              fontSize: FontSize(17),
              fontWeight: FontWeight.w600,
            ),
            'table': Style(
              border: Border.all(color: theme.dividerColor),
            ),
            'td': Style(
              padding: HtmlPaddings.all(8),
              border: Border.all(color: theme.dividerColor),
            ),
            'th': Style(
              padding: HtmlPaddings.all(8),
              fontWeight: FontWeight.w700,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              border: Border.all(color: theme.dividerColor),
            ),
          },
        ),
      ),
    );
  }
}
