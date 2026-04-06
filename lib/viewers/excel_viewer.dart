import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class ExcelViewer extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const ExcelViewer({super.key, required this.path, required this.onTap});

  @override
  State<ExcelViewer> createState() => _ExcelViewerState();
}

class _ExcelViewerState extends State<ExcelViewer> {
  Excel? _excel;
  String? _activeSheet;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = File(widget.path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      setState(() {
        _excel = excel;
        _activeSheet = excel.sheets.keys.first;
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

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_excel == null) return const SizedBox();

    final sheet = _excel!.sheets[_activeSheet]!;
    final rows = sheet.rows;
    if (rows.isEmpty) {
      return const Center(child: Text('Hoja vacía.'));
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        children: [
          const SizedBox(height: 80), // espacio para el AppBar flotante

          // Selector de hojas
          if (_excel!.sheets.length > 1)
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _excel!.sheets.keys.map((name) {
                  final active = name == _activeSheet;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: active,
                      onSelected: (_) => setState(() => _activeSheet = name),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // Tabla scrolleable en ambas direcciones
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.primary.withOpacity(0.12),
                    ),
                    border: TableBorder.all(
                      color: theme.dividerColor,
                      width: 0.8,
                    ),
                    columnSpacing: 16,
                    horizontalMargin: 16,
                    columns: rows.first
                        .map(
                          (cell) => DataColumn(
                            label: Text(
                              cell?.value?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    rows: rows.skip(1).map((row) {
                      return DataRow(
                        cells: row.map((cell) {
                          return DataCell(
                            Text(
                              cell?.value?.toString() ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
