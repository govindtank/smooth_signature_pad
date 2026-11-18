import 'dart:typed_data';
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../controllers/signature_controller.dart';
import '../models/signature_audit.dart';
import '../models/signature_point.dart';
import 'smooth_signature_pad.dart';

/// A complete, turnkey digital signature capture card designed for contracts,
/// legal KYC, enterprise paperwork, and courier delivery receipts.
class SignatureCaptureCard extends StatefulWidget {
  const SignatureCaptureCard({
    super.key,
    this.title = 'Authorized Signatory',
    this.subtitle = 'Please sign within the box above the baseline',
    this.signerName,
    this.signerId,
    this.documentId,
    this.requireLegalConsent = true,
    this.consentText =
        'I acknowledge that this digital signature is legally binding and authentic under applicable electronic signature laws.',
    this.onSignatureSaved,
    this.height = 220,
    this.showColorSelector = true,
    this.cardColor,
    this.padBackgroundColor = const Color(0xFF030712),
  });

  /// Header title for the signature block.
  final String title;

  /// Subtitle or instruction line.
  final String subtitle;

  /// Optional legal name of signatory for the audit trail.
  final String? signerName;

  /// External ID or reference for the audit trail.
  final String? signerId;

  /// Contract or transaction identifier.
  final String? documentId;

  /// Whether to require checking the legal consent agreement before saving.
  final bool requireLegalConsent;

  /// Custom legal disclaimer agreement text.
  final String consentText;

  /// Callback when user taps "Accept & Sign" with clean auto-trimmed PNG, SVG, and audit metadata.
  final void Function(
    Uint8List pngBytes,
    String svgString,
    SignatureAuditMetadata audit,
  )? onSignatureSaved;

  /// Height of the signing canvas.
  final double height;

  /// Whether to display the ink color toggle (Legal Blue vs Deep Black).
  final bool showColorSelector;

  /// Background color of the container card.
  final Color? cardColor;

  /// Canvas background color.
  final Color padBackgroundColor;

  @override
  State<SignatureCaptureCard> createState() => _SignatureCaptureCardState();
}

class _SignatureCaptureCardState extends State<SignatureCaptureCard> {
  late SignatureController _controller;
  bool _consentAgreed = false;
  bool _isSaving = false;
  Color _currentPenColor = const Color(0xFF1E40AF); // Legal Blue default

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penColor: _currentPenColor,
      penStyle: PenStyle.fountain,
      minStrokeWidth: 2.0,
      maxStrokeWidth: 4.5,
    );
    if (!widget.requireLegalConsent) {
      _consentAgreed = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changePenColor(Color color) {
    if (_currentPenColor == color) return;
    setState(() {
      _currentPenColor = color;
      _controller = SignatureController(
        penColor: _currentPenColor,
        penStyle: _controller.penStyle,
        minStrokeWidth: _controller.minStrokeWidth,
        maxStrokeWidth: _controller.maxStrokeWidth,
      );
    });
  }

  Future<void> _handleSave() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature before submitting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.requireLegalConsent && !_consentAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the legal declaration to proceed.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final pngBytes = await _controller.toPngBytes(trim: true);
      final svgString = _controller.toSvg(trim: true);

      final audit = SignatureAuditMetadata(
        signerName: widget.signerName,
        signerId: widget.signerId,
        documentId: widget.documentId,
      ).withComputedHash(_controller.strokes);

      if (pngBytes != null) {
        widget.onSignatureSaved?.call(pngBytes, svgString, audit);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(140),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.showColorSelector) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildColorChip(
                      color: const Color(0xFF1E40AF),
                      label: 'Legal Blue',
                      selected: _currentPenColor == const Color(0xFF1E40AF),
                    ),
                    const SizedBox(width: 6),
                    _buildColorChip(
                      color: const Color(0xFF0F172A),
                      label: 'Deep Black',
                      selected: _currentPenColor == const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Signing Canvas
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.padBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(70),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmoothSignaturePad(
                controller: _controller,
                showGuideline: true,
                guidelineColor: theme.colorScheme.onSurface.withAlpha(50),
                guidelineSignHereText: '✕ Sign Here',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Toolbar (Undo, Redo, Clear)
          Row(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo_rounded, size: 20),
                        tooltip: 'Undo last stroke',
                        onPressed:
                            _controller.canUndo ? _controller.undo : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo_rounded, size: 20),
                        tooltip: 'Redo stroke',
                        onPressed:
                            _controller.canRedo ? _controller.redo : null,
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline_rounded, size: 20),
                        tooltip: 'Clear signature',
                        onPressed:
                            _controller.isNotEmpty ? _controller.clear : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_controller.strokes.length} strokes',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(120),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: const Text('Accept & Sign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          // Legal Consent Agreement Checkbox
          if (widget.requireLegalConsent) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => _consentAgreed = !_consentAgreed),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _consentAgreed,
                        activeColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) =>
                            setState(() => _consentAgreed = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.consentText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorChip({
    required Color color,
    required String label,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => _changePenColor(color),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? color : Colors.grey.withAlpha(80),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
