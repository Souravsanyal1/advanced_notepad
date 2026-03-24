import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/note.dart';
import 'dart:io';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color contrastColor = Color(note.color).computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final Color hintColor = Color(note.color).computeLuminance() > 0.5
        ? Colors.black54
        : Colors.white70;

    return Card(
      elevation: 0.5,
      color: Color(note.color).withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: note.imageUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: note.imageUrl!,
                            placeholder: (context, url) => Container(
                              height: 120,
                              color: Colors.black.withValues(alpha: 0.05),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image_outlined),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : (File(note.imageUrl!).existsSync()
                            ? Image.file(
                                File(note.imageUrl!),
                                height: 120,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined),
                              )
                            : Container(
                                height: 120,
                                color: Colors.black.withValues(alpha: 0.05),
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              )),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (note.title.isNotEmpty)
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: contrastColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 16, color: contrastColor),
                ],
              ),
              const SizedBox(height: 8),
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: contrastColor,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(note.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: hintColor,
                    ),
                  ),
                  if (note.labels.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.label_outline, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${note.labels.length} labels',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
              if (note.labels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.labels.take(3).map((label) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: contrastColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: contrastColor.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 10, color: contrastColor, fontWeight: FontWeight.w500),
                    ),
                  )).toList(),
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
}
