import 'package:flutter/material.dart';

class TagInput extends StatefulWidget {
  final List<String> tags;
  final String hintText;
  final Function(List<String>) onChanged;
  final String? Function(String)? validator;
  final int maxTags;

  const TagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.hintText = 'Add tags...',
    this.validator,
    this.maxTags = 10,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty &&
        !widget.tags.contains(trimmedTag) &&
        widget.tags.length < widget.maxTags) {
      if (widget.validator != null) {
        final error = widget.validator!(trimmedTag);
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          return;
        }
      }

      final newTags = List<String>.from(widget.tags)..add(trimmedTag);
      widget.onChanged(newTags);
      _controller.clear();
    }
  }

  void _removeTag(int index) {
    final newTags = List<String>.from(widget.tags)..removeAt(index);
    widget.onChanged(newTags);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _focusNode.hasFocus
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags display
            if (widget.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.tags.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tag = entry.value;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _removeTag(index),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Input field
            if (widget.tags.length < widget.maxTags)
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onSubmitted: _addTag,
                onChanged: (value) {
                  if (value.endsWith(',') || value.endsWith(';')) {
                    _addTag(value.substring(0, value.length - 1));
                  }
                },
              ),

            // Helper text
            if (widget.tags.length >= widget.maxTags)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Maximum ${widget.maxTags} tags allowed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Press Enter or use comma/semicolon to add tags',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
