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
