import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/note.dart';
import 'dart:io';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NoteCard({super.key, required this.note, required this.onTap, this.onLongPress});

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
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: note.imageUrl!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: note.imageUrl!,
                            placeholder: (context, url) => Container(
                              height: 80,
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
                                height: 80,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined),
                              )
                            : Container(
                                height: 80,
                                color: Colors.black.withValues(alpha: 0.05),
                                child: const Center(child: Icon(Icons.image_not_supported)),
                              )),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: contrastColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    Icon(Icons.push_pin, size: 14, color: contrastColor),
                  if (note.isFavorite)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.favorite, size: 14, color: Colors.red.shade400),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: contrastColor.withValues(alpha: 0.8),
                  ),
                  maxLines: note.imageUrl != null ? 3 : 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d').format(note.updatedAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: hintColor,
                    ),
                  ),
                  if (note.labels.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: contrastColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        note.labels.first,
                        style: TextStyle(fontSize: 9, color: contrastColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
