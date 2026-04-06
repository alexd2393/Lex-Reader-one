import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document.dart';
import '../services/file_service.dart';
import '../services/settings_service.dart';
import '../widgets/file_card.dart';
import '../widgets/blue_light_filter.dart';
import 'viewer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Document> _recent = [];

  void _refresh() => setState(() => _recent = FileService.recentDocuments);

  Future<void> _openPicker() async {
    final doc = await FileService.pickDocument();
    if (doc == null || !mounted) return;
    _refresh();
    _navigate(doc);
  }

  void _navigate(Document doc) {
    Navigator.of(context).push(_buildRoute(doc)).then((_) => _refresh());
  }

  PageRoute _buildRoute(Document doc) {
    switch (doc.type) {
      case DocumentType.epub:
      case DocumentType.docx:
        // Slide desde la derecha — documentos tipo libro
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => ViewerScreen(document: doc),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 380),
        );

      case DocumentType.pptx:
        // Fade + escala — presentaciones
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => ViewerScreen(document: doc),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 420),
        );

      case DocumentType.xlsx:
        // Escala desde abajo — tablas/datos
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => ViewerScreen(document: doc),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutQuint)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          transitionDuration: const Duration(milliseconds: 350),
        );

      case DocumentType.markdown:
        // Slide desde abajo — documentos de texto simple
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => ViewerScreen(document: doc),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 360),
        );

      default:
        // PDF y resto: fade clásico
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => ViewerScreen(document: doc),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlueLightFilter(
      intensity: settings.blueLightIntensity,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                title: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.menu_book,
                          size: 16, color: Colors.black),
                    ),
                    const SizedBox(width: 10),
                    const Text('Lex Reader'),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    ),
                    tooltip: 'Cambiar tema',
                    onPressed: settings.toggleDarkMode,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Ajustes',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),

              // Sección recientes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    _recent.isEmpty ? 'Sin archivos recientes' : 'Recientes',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (_recent.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64,
                            color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Abrí tu primer archivo\ncon el botón +',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final doc = _recent[i];
                      return FileCard(
                        doc: doc,
                        onTap: () => _navigate(doc),
                        onShare: () => FileService.shareDocument(doc),
                        onRemove: () {
                          FileService.removeFromRecent(doc.path);
                          _refresh();
                        },
                      );
                    },
                    childCount: _recent.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        ),

        // FAB para abrir el file picker
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openPicker,
          icon: const Icon(Icons.add),
          label: const Text('Abrir archivo'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}
