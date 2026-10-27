import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_signature_pad/smooth_signature_pad.dart';

void main() {
  runApp(const SmoothSignaturePadDemoApp());
}

class SmoothSignaturePadDemoApp extends StatelessWidget {
  const SmoothSignaturePadDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smooth_signature_pad — Interactive Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const SignatureDemoScreen(),
    );
  }
}

class SignatureDemoScreen extends StatefulWidget {
  const SignatureDemoScreen({super.key});

  @override
  State<SignatureDemoScreen> createState() => _SignatureDemoScreenState();
}

class _SignatureDemoScreenState extends State<SignatureDemoScreen> {
  late SignatureController _controller;
  Color _selectedColor = const Color(0xFF0F172A);
  bool _copiedCommand = false;

  final List<Color> _palette = const [
    Color(0xFF0F172A), // Jet Slate
    Color(0xFF1E3A8A), // Royal Midnight Blue
    Color(0xFF047857), // Forest Emerald
    Color(0xFFB91C1C), // Crimson Red
    Color(0xFF7C3AED), // Royal Purple
  ];

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = SignatureController(
      penColor: _selectedColor,
      minStrokeWidth: 1.5,
      maxStrokeWidth: 4.8,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyPubCommand() async {
    await Clipboard.setData(
      const ClipboardData(text: 'flutter pub add smooth_signature_pad'),
    );
    HapticFeedback.lightImpact();
    setState(() => _copiedCommand = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedCommand = false);
    });
  }

  void _showSvgDialog() {
    final svg = _controller.toSvg(width: 500, height: 260);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exported Vector SVG'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: SelectableText(
                svg,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: svg));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SVG markup copied to clipboard!'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy SVG'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPngDialog() async {
    final bytes = await _controller.toPngBytes(
      width: 500,
      height: 260,
      pixelRatio: 3.0,
      backgroundColor: Colors.white,
    );

    if (!mounted || bytes == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('High-Resolution PNG Preview'),
          content: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Image.memory(bytes),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.draw_rounded, color: Color(0xFF38BDF8), size: 20),
            const SizedBox(width: 8),
            const Text(
              'smooth_signature_pad',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 1-Tap Copy Install Button
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _copiedCommand ? Icons.check : Icons.terminal_rounded,
                    size: 14,
                    color: _copiedCommand
                        ? const Color(0xFF10B981)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _copiedCommand ? 'Copied pub add!' : 'pub add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _copiedCommand
                          ? const Color(0xFF10B981)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Fountain Pen Velocity Dynamics',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Draw with natural stroke tapering, Catmull-Rom cubic Bézier curves, and instant vector SVG / PNG export.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                const SizedBox(height: 20.0),

                // Signature Canvas Container
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 18.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SmoothSignaturePad(
                    controller: _controller,
                    backgroundColor: Colors.white,
                    showGuideline: true,
                    guidelineColor: const Color(0x330F172A),
                    guidelinePosition: 0.82,
                    guidelineSignHereText: 'X  Sign Here',
                  ),
                ),
                const SizedBox(height: 18.0),

                // Palette & Action Bar
                Row(
                  children: [
                    const Text(
                      'Ink: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    ..._palette.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                            final currentStrokes = _controller.strokes;
                            _controller.dispose();
                            _controller = SignatureController(
                              penColor: color,
                              minStrokeWidth: 1.5,
                              maxStrokeWidth: 4.8,
                            );
                            for (final s in currentStrokes) {
                              _controller.startStroke(s.first.offset);
                              for (int i = 1; i < s.length; i++) {
                                _controller.addPoint(s[i].offset);
                              }
                              _controller.endStroke();
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo),
                              tooltip: 'Undo',
                              onPressed: _controller.canUndo
                                  ? () => _controller.undo()
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.redo),
                              tooltip: 'Redo',
                              onPressed: _controller.canRedo
                                  ? () => _controller.redo()
                                  : null,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Clear',
                              onPressed: _controller.isNotEmpty
                                  ? () => _controller.clear()
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Export Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showSvgDialog,
                        icon: const Icon(Icons.code_rounded, size: 18),
                        label: const Text('Export Vector SVG'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showPngDialog,
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: const Text('Export High-DPI PNG'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
