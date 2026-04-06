import 'dart:io';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';

class EpubViewer extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const EpubViewer({super.key, required this.path, required this.onTap});

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  late EpubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openFile(File(widget.path)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: EpubView(
        controller: _controller,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(
            textStyle: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: isDark
                  ? const Color(0xFFDDDBD5)
                  : const Color(0xFF2A2820),
            ),
          ),
          chapterDividerBuilder: (_) => const Divider(height: 40),
        ),
      ),
    );
  }
}
