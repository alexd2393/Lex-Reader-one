import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Apariencia ---
          _SectionHeader(label: 'APARIENCIA'),
          _SettingCard(
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modo oscuro',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        isDark ? 'Activado' : 'Desactivado',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isDark,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (_) => settings.toggleDarkMode(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Filtro de luz azul ---
          _SectionHeader(label: 'FILTRO DE LUZ AZUL'),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.nightlight_outlined,
                        color: const Color(0xFFE8A838)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Intensidad',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            settings.blueLightIntensity == 0
                                ? 'Desactivado'
                                : '${(settings.blueLightIntensity * 100).round()}%',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.blueLightEnabled,
                      activeColor: const Color(0xFFE8A838),
                      onChanged: (v) => settings.setBlueLightIntensity(
                        v ? 0.4 : 0.0,
                      ),
                    ),
                  ],
                ),
                if (settings.blueLightEnabled) ...[
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFE8A838),
                      thumbColor: const Color(0xFFE8A838),
                      inactiveTrackColor: theme.dividerColor,
                    ),
                    child: Slider(
                      value: settings.blueLightIntensity,
                      min: 0.05,
                      max: 1.0,
                      divisions: 19,
                      onChanged: settings.setBlueLightIntensity,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Suave', style: theme.textTheme.labelSmall),
                      Text('Intenso', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Info ---
          _SectionHeader(label: 'ACERCA DE'),
          _SettingCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lex Reader',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Lector personal — PDF, EPUB, DOCX, PPTX, XLSX, Markdown.\nUso privado. Sin anuncios. Sin servidores.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text('v1.0.0', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}
