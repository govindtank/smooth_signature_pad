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
