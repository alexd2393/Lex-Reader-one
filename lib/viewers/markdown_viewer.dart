import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const MarkdownViewer({super.key, required this.path, required this.onTap});

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  String _content = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await File(widget.path).readAsString();
      setState(() {
        _content = text;
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final mdStyle = MarkdownStyleSheet(
      p: TextStyle(
        fontSize: 16,
        height: 1.7,
        color: isDark ? const Color(0xFFDDDBD5) : const Color(0xFF2A2820),
      ),
      h1: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
      h2: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFE8E6E0) : const Color(0xFF1A1814),
      ),
      h3: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: theme.dividerColor.withOpacity(0.4),
        color: theme.colorScheme.primary,
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F30)
            : const Color(0xFFF0EDE6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      blockquotePadding: const EdgeInsets.all(12),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Markdown(
        data: _content,
        styleSheet: mdStyle,
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
        selectable: true,
      ),
    );
  }
}
