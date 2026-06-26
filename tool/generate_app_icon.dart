import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final logo = img.decodeImage(
    File('assets/images/partner_light.png').readAsBytesSync(),
  )!;
  const size = 1024;
  const scale = 0.52;

  void writeIcon(String path, {required bool whiteBackground}) {
    final canvas = img.Image(width: size, height: size);
    if (whiteBackground) {
      img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    }
    final maxSide = (size * scale).round();
    final resized = img.copyResize(
      logo,
      width: maxSide,
      height: maxSide,
      maintainAspect: true,
    );
    final x = (size - resized.width) ~/ 2;
    final y = (size - resized.height) ~/ 2;
    img.compositeImage(canvas, resized, dstX: x, dstY: y);
    File(path).writeAsBytesSync(img.encodePng(canvas));
    stdout.writeln('wrote $path');
  }

  writeIcon('assets/images/partner_app_icon.png', whiteBackground: true);
  writeIcon('assets/images/partner_app_icon_foreground.png', whiteBackground: false);
  stripNearWhiteBackground('assets/images/partner_light.png');
  stdout.writeln('stripped white background from partner_light.png');
  stripNearWhiteBackground('assets/images/partner_dark.png');
  stdout.writeln('stripped white background from partner_dark.png');
}

/// Makes near-white pixels transparent so logos blend on any surface.
void stripNearWhiteBackground(String path, {int threshold = 242}) {
  final file = File(path);
  final decoded = img.decodeImage(file.readAsBytesSync())!;
  final rgba = img.Image(
    width: decoded.width,
    height: decoded.height,
    numChannels: 4,
  );

  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final pixel = decoded.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final alpha =
          (r >= threshold && g >= threshold && b >= threshold) ? 0 : 255;
      rgba.setPixelRgba(x, y, r, g, b, alpha);
    }
  }

  file.writeAsBytesSync(img.encodePng(rgba));
}
