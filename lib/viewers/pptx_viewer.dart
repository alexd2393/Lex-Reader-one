import 'dart:io';
import 'package:flutter/material.dart';
import '../services/converter_service.dart';

class PptxViewer extends StatefulWidget {
  final String path;
  final VoidCallback onTap;

  const PptxViewer({super.key, required this.path, required this.onTap});

  @override
  State<PptxViewer> createState() => _PptxViewerState();
}

class _PptxViewerState extends State<PptxViewer> {
  List<String> _slides = [];
  bool _loading = true;
  String? _error;
  late PageController _pageController;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final paths = await ConverterService.pptxToImages(widget.path);
      setState(() {
        _slides = paths;
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

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Renderizando slides…'),
          ],
        ),
      );
    }
    if (_error != null || _slides.isEmpty) {
      return Center(child: Text(_error ?? 'No se pudieron extraer los slides.'));
    }

    return Stack(
      children: [
        // Slides en PageView horizontal con zoom
        GestureDetector(
          onTap: widget.onTap,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentSlide = i),
            itemBuilder: (_, i) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: Image.file(
                    File(_slides[i]),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),

        // Navegación inferior
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón anterior
              _NavButton(
                icon: Icons.arrow_back_ios,
                onTap: _currentSlide > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),

              // Contador
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  '${_currentSlide + 1} / ${_slides.length}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),

              // Botón siguiente
              _NavButton(
                icon: Icons.arrow_forward_ios,
                onTap: _currentSlide < _slides.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
            ],
          ),
        ),

        // Indicadores de puntos
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length.clamp(0, 12), // máx 12 puntos visibles
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentSlide ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentSlide
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.88),
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
    );
  }
}
