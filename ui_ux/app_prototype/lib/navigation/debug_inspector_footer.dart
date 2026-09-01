import 'package:app_prototype/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebugInspectorFooter extends StatelessWidget {
  const DebugInspectorFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Im Release-Build gar nichts rendern
    if (!kDebugMode) return const SizedBox.shrink();

    return ValueListenableBuilder<String?>(
      valueListenable: isarInspectorUrlNotifier,
      builder: (context, url, child) {
        if (url == null) return const SizedBox.shrink();

        return Container(
          color: Colors.black87,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Isar Inspector Link kopiert!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'DEBUG MODE - ISAR INSPECTOR:',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}