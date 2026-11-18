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
      title:
          'smooth_signature_pad — Legal Signature Studio & Contract Stamping',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFF111827),
        ),
      ),
      home: const SignatureStudioScreen(),
    );
  }
}

class SignatureStudioScreen extends StatefulWidget {
  const SignatureStudioScreen({super.key});

  @override
  State<SignatureStudioScreen> createState() => _SignatureStudioScreenState();
}

class _SignatureStudioScreenState extends State<SignatureStudioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SignatureController _controller;

  // Customization Options
  PenStyle _penStyle = PenStyle.fountain;
  Color _selectedColor = const Color(0xFF1E40AF); // Legal Blue
  Color _canvasBg = const Color(0xFF030712);
  double _minWidth = 2.0;
  double _maxWidth = 5.0;
  bool _showGuideline = true;
  String _guidelineText = '✕ Sign Here';
  bool _copiedCommand = false;

  // Stamped Contract State
  Uint8List? _stampedPngBytes;
  SignatureAuditMetadata? _stampedAudit;

  final List<Color> _palette = const [
    Color(0xFF1E40AF), // Legal Blue (Bank Standard)
    Color(0xFF0F172A), // Deep Jet Black
    Color(0xFF047857), // Emerald Green
    Color(0xFFB91C1C), // Crimson Red
    Color(0xFF7C3AED), // Royal Purple
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initController();
  }

  void _initController() {
    _controller = SignatureController(
      penColor: _selectedColor,
      penStyle: _penStyle,
      minStrokeWidth: _minWidth,
      maxStrokeWidth: _maxWidth,
    );
  }

  void _rebuildController() {
    final currentStrokes = _controller.strokes;
    _controller.dispose();
    _controller = SignatureController(
      penColor: _selectedColor,
      penStyle: _penStyle,
      minStrokeWidth: _minWidth,
      maxStrokeWidth: _maxWidth,
    );
    for (final s in currentStrokes) {
      _controller.startStroke(s.first.offset, pressure: s.first.pressure);
      for (int i = 1; i < s.length; i++) {
        _controller.addPoint(s[i].offset, pressure: s[i].pressure);
      }
      _controller.endStroke();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    final svg = _controller.toSvg(width: 500, height: 260, trim: true);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Exported Vector SVG (Auto-Trimmed)'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(
                svg,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: svg));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SVG markup copied to clipboard!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Copy SVG'),
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

  void _showJsonDialog() {
    final jsonStr = _controller.toJson();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Vector Stroke JSON Serialization'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('JSON copied! Can be saved to database or API.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Copy JSON'),
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
      trim: true,
      backgroundColor: Colors.transparent,
    );

    if (bytes == null || !mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text('Exported High-DPI PNG (Transparent & Cropped)'),
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.memory(bytes, height: 160, fit: BoxFit.contain),
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
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.draw_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'smooth_signature_pad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Legal E-Signature Studio & Document Stamping',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'v1.3.0',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: _copyPubCommand,
            borderRadius: BorderRadius.circular(6.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: _copiedCommand
                    ? const Color(0xFF10B981).withAlpha(40)
                    : Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: _copiedCommand
                      ? const Color(0xFF10B981)
                      : Colors.white.withAlpha(40),
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
                    _copiedCommand ? 'Copied!' : 'pub add',
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
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.palette_rounded), text: 'Interactive Studio'),
            Tab(
                icon: Icon(Icons.description_rounded),
                text: 'DocuSign Contract Stamping'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudioTab(),
          _buildDocumentStampingTab(),
        ],
      ),
    );
  }

  Widget _buildStudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Canvas Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Canvas Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SIGNATURE PAD CANVAS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.grey,
                          ),
                        ),
                        // Paper selector
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Paper:',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(width: 6),
                            _buildPaperBtn('Dark', const Color(0xFF030712)),
                            _buildPaperBtn('White', Colors.white),
                            _buildPaperBtn(
                                'Parchment', const Color(0xFFFFFBEB)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // The actual Signature Canvas
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: _canvasBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF374151)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SmoothSignaturePad(
                          controller: _controller,
                          showGuideline: _showGuideline,
                          guidelineColor: _canvasBg == Colors.white ||
                                  _canvasBg == const Color(0xFFFFFBEB)
                              ? const Color(0x33000000)
                              : const Color(0x33FFFFFF),
                          guidelineSignHereText: _guidelineText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Canvas Toolbar
                    Row(
                      children: [
                        // Ink Palette
                        ..._palette.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              _selectedColor = color;
                              _rebuildController();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
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
                                  icon:
                                      const Icon(Icons.undo_rounded, size: 20),
                                  tooltip: 'Undo',
                                  onPressed: _controller.canUndo
                                      ? () => _controller.undo()
                                      : null,
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.redo_rounded, size: 20),
                                  tooltip: 'Redo',
                                  onPressed: _controller.canRedo
                                      ? () => _controller.redo()
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 20),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Studio Customization Controls Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STUDIO CONFIGURATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pen Style Selector
                    Row(
                      children: [
                        const Text('Pen Nib Style:',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        SegmentedButton<PenStyle>(
                          segments: const [
                            ButtonSegment(
                                value: PenStyle.fountain,
                                label: Text('Fountain')),
                            ButtonSegment(
                                value: PenStyle.ballpoint,
                                label: Text('Ballpoint')),
                            ButtonSegment(
                                value: PenStyle.calligraphy,
                                label: Text('Chisel')),
                          ],
                          selected: {_penStyle},
                          onSelectionChanged: (val) {
                            _penStyle = val.first;
                            _rebuildController();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sliders
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Min Stroke: ${_minWidth.toStringAsFixed(1)}px',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Slider(
                                value: _minWidth,
                                min: 1.0,
                                max: 4.0,
                                divisions: 6,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (v) {
                                  _minWidth = v;
                                  _rebuildController();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Max Stroke: ${_maxWidth.toStringAsFixed(1)}px',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Slider(
                                value: _maxWidth,
                                min: 3.0,
                                max: 10.0,
                                divisions: 14,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (v) {
                                  _maxWidth = v;
                                  _rebuildController();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        const Text('Show Baseline:',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Switch(
                          value: _showGuideline,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: (v) => setState(() => _showGuideline = v),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Guideline Prompt Text',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            controller:
                                TextEditingController(text: _guidelineText),
                            onChanged: (t) =>
                                setState(() => _guidelineText = t),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Export Actions Card
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showPngDialog,
                    icon: const Icon(Icons.image_rounded, size: 16),
                    label: const Text('Export PNG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showSvgDialog,
                    icon: const Icon(Icons.code_rounded, size: 16),
                    label: const Text('Export Vector SVG'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showJsonDialog,
                    icon: const Icon(Icons.data_object_rounded, size: 16),
                    label: const Text('Vector JSON (API/DB)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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

  Widget _buildPaperBtn(String label, Color color) {
    final isSelected = _canvasBg == color;
    return GestureDetector(
      onTap: () => setState(() => _canvasBg = color),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withAlpha(40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : Colors.grey.withAlpha(60)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF10B981) : Colors.grey)),
      ),
    );
  }

  Widget _buildDocumentStampingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Real Document Card Preview
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5), // Legal Paper
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(100), blurRadius: 20),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MASTER SERVICES AGREEMENT',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'DOC #MSA-2026-992',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFCBD5E1), height: 24),
                    const Text(
                      'This Agreement is entered into as of the Effective Date between Client and Provider. '
                      'The undersigned parties hereby certify and agree to all terms, confidentiality clauses, and delivery milestones set forth herein.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Stamped Signature Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ACCEPTED & AGREED:',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 8),
                            Container(
                              width: 260,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    color: const Color(0xFF94A3B8),
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _stampedPngBytes != null
                                  ? Image.memory(_stampedPngBytes!,
                                      fit: BoxFit.contain)
                                  : const Center(
                                      child: Text(
                                        'Awaiting Signature...',
                                        style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 12),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 6),
                            if (_stampedAudit != null) ...[
                              Text(
                                'Signer: ${_stampedAudit!.signerName ?? "Govind Tank"} • Verified',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A)),
                              ),
                              Text(
                                'Hash: ${_stampedAudit!.integrityHash ?? "cbf29ce484222325"}',
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontFamily: 'monospace',
                                    color: Color(0xFF64748B)),
                              ),
                            ] else ...[
                              const Text('Signatory: Govind Tank',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFF64748B))),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // The SignatureCaptureCard to Stamp
              SignatureCaptureCard(
                title: 'Sign Agreement Below',
                subtitle:
                    'Sign inside the box to stamp directly onto the contract above',
                signerName: 'Govind Tank',
                signerId: 'USER-84920',
                documentId: 'DOC-MSA-2026-992',
                onSignatureSaved: (pngBytes, svg, audit) {
                  setState(() {
                    _stampedPngBytes = pngBytes;
                    _stampedAudit = audit;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '✓ Signature stamped onto contract successfully!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF065F46),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
