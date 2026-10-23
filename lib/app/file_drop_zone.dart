import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

/// Windows'ta dosya sürükle-bırak alanı. Klasörler desteklenmez (atlanır).
class FileDropZone extends StatefulWidget {
  const FileDropZone({super.key, required this.onPaths, required this.child});

  final void Function(List<String> paths) onPaths;
  final Widget child;

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) => setState(() => _dragging = true),
      onDragExited: (details) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        widget.onPaths(details.files.map((f) => f.path).toList());
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_dragging)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  key: const Key('drop_overlay'),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha(0x33),
                  alignment: Alignment.center,
                  child: Text(
                    'Müzik dosyalarını bırakın',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
