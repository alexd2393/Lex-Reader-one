import 'package:flutter/material.dart';
import '../models/document.dart';

/// Tarjeta visual para un documento en el historial reciente.
class FileCard extends StatelessWidget {
  final Document doc;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onRemove;

  const FileCard({
    super.key,
    required this.doc,
    required this.onTap,
    required this.onShare,
    required this.onRemove,
  });

  Color _typeColor(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return const Color(0xFFE84040);
      case DocumentType.epub:
        return const Color(0xFF4CAF80);
      case DocumentType.docx:
        return const Color(0xFF4080E8);
      case DocumentType.pptx:
        return const Color(0xFFE87040);
      case DocumentType.xlsx:
        return const Color(0xFF20A060);
      case DocumentType.markdown:
        return const Color(0xFF9B8FE8);
      case DocumentType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(doc.type);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Badge de tipo
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.4), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  Document.labelFromType(doc.type),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nombre y tamaño
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doc.sizeLabel,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              // Acciones
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) {
                  if (v == 'share') onShare();
                  if (v == 'remove') onRemove();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'share', child: Text('Compartir')),
                  PopupMenuItem(value: 'remove', child: Text('Quitar del historial')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
