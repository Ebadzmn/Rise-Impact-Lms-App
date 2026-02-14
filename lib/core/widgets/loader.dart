import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const Loader({super.key, this.size = 40, this.color, this.strokeWidth = 3});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// Full screen loader with semi-transparent overlay
  static Widget fullScreen({String? message}) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
