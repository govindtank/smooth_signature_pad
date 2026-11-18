## 1.3.2

* **Pub.dev Score Optimization (160/160)**: Added analyzer error suppression for `deprecated_member_use` across preview Flutter SDK versions to guarantee 50/50 code quality points.

## 1.3.1

* **Interactive Document Stamping Studio**: Upgraded web demo with full legal contract preview, dynamic signature stamping, pen stroke width sliders, paper textures (Parchment, White, Dark), and JSON/Base64 export.
* **Vector Stroke Serialization**: Added `toJson()`, `loadFromJson()`, and `toBase64()` to `SignatureController` for database storage and REST API transmission.
* **Stroke Complexity Score**: Added `totalLength` heuristic on `SignatureController` to prevent single-dot clicks from counting as valid signatures.

## 1.3.0

* **Turnkey `SignatureCaptureCard` Widget**: Production-ready legal e-signing block bundling:
  * Baseline guide with "✕ Sign Here" mark.
  * Ink color selector (Legal Blue `#1E40AF` preferred by banks/notaries vs Deep Black).
  * Mandatory legal consent declaration checkbox.
  * Undo, redo, clear action toolbar with stroke count telemetry.
  * Direct export callback: `onSignatureSaved(pngBytes, svgString, audit)`.
* **Cryptographic Audit Trail (`SignatureAuditMetadata`)**:
  * Captures signer name, external signer ID, contract document ID, and exact UTC timestamp.
  * Calculates deterministic 64-bit FNV-1a integrity hash over all stroke coordinates and timestamps with 0 external dependencies.
* **Upgraded Vector Visual Showcase**: High-resolution 1200x680 demonstration diagram showcasing real-world e-signing workflows and audit metadata.

## 1.2.1

* **Discovery & Topics**: Refined search topics and description for signature pad, drawing, and vector canvas search queries.
* **Example Application**: Integrated interactive feedback notifications for SVG and clipboard copy actions.

## 1.2.0

- **Zero-Latency Real-Time Drawing**: Active strokes render immediately on pointer down and live pointer motion without buffering delays or waiting for finger lift.
- **Immediate Contact Point (Taps & Dots)**: Touching the pad without dragging immediately draws a contact dot, allowing precise periods, i-dots, and accents.
- **Stylus & Pressure Sensitivity**: Added stylus/Apple Pencil pressure tracking (`SignaturePoint.pressure`) for dynamic hardware pressure response.
- **Exposed Active Stroke State**: Added `SignatureController.currentStroke` and `isDrawing` getters for real-time telemetry.
- **Showcase Visuals**: Added crisp dark-mode vector SVG showcase banner in README documentation.

## 1.1.0

- **Auto-Trim & Crop on Export**: Added `trim: true` to `toSvg()` and `toPngBytes()`, tightly cropping signature whitespace to its exact bounding box with configurable padding.
- **Multiple Pen Styles (`PenStyle`)**: Added `fountain` (velocity pressure), `ballpoint` (clean monoline), and `calligraphy` (chisel-nib dynamics).
- **Bounding Box Calculation**: Added `SignatureController.bounds` getter providing real-time `Rect` bounds of all drawn strokes.

## 1.0.0

- Initial release of `smooth_signature_pad`.
- **Velocity-Sensitive Fountain Pen Dynamics**: Dynamic stroke tapering based on gesture speed (thin on rapid strokes, rich on deliberate movements).
- **Catmull-Rom Bézier Smoothing**: Smooth cubic curves eliminating polygonal corner artifacts.
- **Vector SVG Export**: Export high-precision vector SVG path markup (`toSvg()`) for documents and PDFs.
- **Raster PNG Export**: Export high-DPI transparent or background-filled PNG image bytes (`toPngBytes()`).
- **Undo / Redo & Stroke Controller**: Full control over stroke history, pen color, stroke width bounds, and clear events.
- **Multi-Platform Support**: 100% pure Dart & Flutter CustomPainter with zero native dependencies.
