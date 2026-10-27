# smooth_signature_pad

<p align="center">
  <a href="https://pub.dev/packages/smooth_signature_pad"><img src="https://img.shields.io/pub/v/smooth_signature_pad.svg?style=flat-square&color=blue" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/smooth_signature_pad/score"><img src="https://img.shields.io/pub/points/smooth_signature_pad?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://govindtank.github.io/smooth_signature_pad/"><img src="https://img.shields.io/badge/Live%20Demo-Try%20In%20Browser-00ff88?style=flat-square&logo=flutter" alt="Live Demo"></a>
  <a href="https://pub.dev/packages/smooth_signature_pad"><img src="https://img.shields.io/pub/likes/smooth_signature_pad?style=flat-square" alt="Pub Likes"></a>
  <a href="https://github.com/govindtank/smooth_signature_pad/actions"><img src="https://github.com/govindtank/smooth_signature_pad/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=flat-square" alt="License"></a>
</p>

A smooth digital signature and drawing pad for Flutter. Features **fountain pen velocity-sensitive pressure simulation, Catmull-Rom cubic Bézier curve smoothing, and vector SVG & high-DPI raster PNG export**.

---

## ⚡ Why `smooth_signature_pad`?

Most Flutter signature packages suffer from noticeable limitations when used in commercial document-signing workflows:

* 🚫 **Jagged Straight Line Segments**: Connecting raw touch events with straight lines creates ugly, pixelated polygonal angles during rapid signatures.
* 🚫 **No Pen Pressure Dynamics**: Real ink reacts to speed — rapid strokes taper to sharp, thin lines, while slow deliberate strokes form weighted ink lines. Standard packages produce uniform, artificial monoline widths.
* 🚫 **No Lossless Vector SVG Export**: Stamping signatures onto legal PDF contracts or responsive web previews requires crisp, scale-independent vector SVG paths, not just compressed low-res bitmaps.

`smooth_signature_pad` solves this with an ultra-lightweight, 120 FPS pure Canvas rendering engine.

---

## 🚀 Features

| Feature | Description |
|---|---|
| **✒️ Fountain Pen Velocity Pressure** | Dynamic stroke width calculation based on touch speed (thin on rapid flourishes, thick on slow curves). |
| **➰ Catmull-Rom Bézier Splines** | Smooth cubic spline interpolation eliminating polygonal corner artifacts. |
| **📐 Vector SVG Export** | Generates clean, resolution-independent XML `<svg>` markup with `<path d="...">` vectors. |
| **🖼️ High-DPI PNG Export** | Generates transparent or background-filled raster PNG image bytes with customizable pixel ratio. |
| **↩️ Full Undo / Redo History** | Intuitive stroke management with undo, redo, and clear methods. |
| **📏 Legal Guideline Baseline** | Built-in customizable signing line and "X Sign Here" prompt indicator. |
| **🌐 Multi-Platform** | 100% pure Dart & Flutter with zero native dependencies. Works on iOS, Android, Web, macOS, Windows, and Linux. |

---

## 📦 Installation

Add `smooth_signature_pad` to your `pubspec.yaml`:

```bash
flutter pub add smooth_signature_pad
```

---

## 💡 Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:smooth_signature_pad/smooth_signature_pad.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penColor: const Color(0xFF0F172A),
    minStrokeWidth: 1.5,
    maxStrokeWidth: 4.5,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 420,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          clipBehavior: Clip.antiAlias,
          child: SmoothSignaturePad(
            controller: _controller,
            showGuideline: true,
            guidelineSignHereText: 'X Sign Here',
          ),
        ),
      ),
    );
  }
}
```

---

## 📐 Exporting Signatures

### Vector SVG
```dart
// Export vector SVG string
final String svgString = _controller.toSvg(
  width: 500,
  height: 260,
  strokeColor: Colors.black,
);
```

### High-DPI PNG
```dart
// Export 3x retina PNG bytes
final Uint8List? pngBytes = await _controller.toPngBytes(
  width: 500,
  height: 260,
  pixelRatio: 3.0,
  backgroundColor: Colors.transparent,
);
```

---

## 🔗 Related Packages by Author

* **[flutter_privacy_vault](https://pub.dev/packages/flutter_privacy_vault)** — App-switcher privacy shield, inactivity auto-lock with biometrics, and balance masking.
* **[ai_stream_bubble](https://pub.dev/packages/ai_stream_bubble)** — High-performance streaming AI message bubble with DeepSeek/Claude reasoning accordions.
* **[flutter_sonner](https://pub.dev/packages/flutter_sonner)** — Opinionated stacked action toast & notification HUD with spring physics.
* **[spatial_card](https://pub.dev/packages/spatial_card)** — 3D tactile interactive cards & multi-plane parallax surfaces.

---

## 💖 Support the Project

If you find this project useful, consider supporting its active maintenance and future development:

<p align="left">
  <a href="https://buymeacoffee.com/govindtanko"><img src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
  <a href="https://github.com/sponsors/govindtank"><img src="https://img.shields.io/badge/GitHub%20Sponsors-EA4AAA?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Sponsors" /></a>
  <a href="https://www.patreon.com/govindtank"><img src="https://img.shields.io/badge/Patreon-F96854?style=for-the-badge&logo=patreon&logoColor=white" alt="Patreon" /></a>
</p>

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

*Maintained with ❤️ by [Govind Tank](https://github.com/govindtank).*
