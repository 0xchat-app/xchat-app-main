import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:ox_common/login/account_path_helper.dart';

enum AnimalStyle {
  cat,      // 🐱
  dog,      // 🐕
  rabbit,   // 🐰
  mouse,    // 🐀
  fox,      // 🦊
  bear,     // 🐻
  panda,    // 🐼
  tiger,    // 🐯
  lion,     // 🦁
  elephant, // 🐘
  giraffe,  // 🦒
  penguin,  // 🐧
  owl,      // 🦉
  duck,     // 🦆
  fish,     // 🐠
}

class AvatarColors {
  final Color primary;
  final Color secondary;
  final Color accent;

  AvatarColors({
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}

/// Pixel art avatar generator for new accounts
///
/// Generates unique pixel-style avatars based on npub (public key)
/// Each avatar has consistent colors and patterns for the same public key
class AvatarGenerator {
  AvatarGenerator._();
  
  static final AvatarGenerator instance = AvatarGenerator._();

  Future<File?> generateAvatar({
    required String npub,
    int width = 128,
    int height = 128,
  }) async {
    final imageCacheDir = await AccountPathHelper.imageCacheDir();
    if (imageCacheDir.isEmpty) {
      assert(false, 'imageCacheDir is empty');
      return null;
    }

    final avatarDir = Directory(imageCacheDir);
    if (!await avatarDir.exists()) {
      avatarDir.create(recursive: true);
    }

    final hash = hashString(npub);
    final filename = 'avatar_${hash.abs()}.png';
    final filePath = path.join(avatarDir.path, filename);

    final file = File(filePath);
    if (file.existsSync()) return file;

    // Create image file
    final colors = generateColors(npub);
    final pattern = generatePattern(npub);
    final imageData = await _createImageData(colors, pattern, width, height);

    await file.writeAsBytes(imageData);

    return file;
  }
  
  /// Create image data from pattern and colors
  Future<Uint8List> _createImageData(AvatarColors colors, List<List<int>> pattern, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Calculate pixel size for 16x16 grid
    final pixelWidth = width / 16;
    final pixelHeight = height / 16;
    
    // Draw pixels
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        final color = _getPixelColor(colors, pattern, x, y);
        final rect = Rect.fromLTWH(
          x * pixelWidth,
          y * pixelHeight,
          pixelWidth,
          pixelHeight,
        );
        
        final paint = Paint()..color = color;
        canvas.drawRect(rect, paint);
      }
    }
    
    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Generate consistent colors based on npub
  AvatarColors generateColors(String npub) {
    final hash = hashString(npub);
    final random = Random(hash);
    
    // Generate primary color (main background)
    final primaryHue = random.nextDouble() * 360;
    final primarySaturation = 0.3 + random.nextDouble() * 0.4; // 30-70%
    final primaryValue = 0.7 + random.nextDouble() * 0.3; // 70-100%
    
    // Generate secondary color (pattern color)
    final secondaryHue = (primaryHue + 180 + random.nextDouble() * 60 - 30) % 360;
    final secondarySaturation = 0.4 + random.nextDouble() * 0.5; // 40-90%
    final secondaryValue = 0.6 + random.nextDouble() * 0.4; // 60-100%
    
    // Generate accent color (highlight color)
    final accentHue = (primaryHue + 120 + random.nextDouble() * 60 - 30) % 360;
    final accentSaturation = 0.5 + random.nextDouble() * 0.5; // 50-100%
    final accentValue = 0.8 + random.nextDouble() * 0.2; // 80-100%
    
    return AvatarColors(
      primary: HSVColor.fromAHSV(1.0, primaryHue, primarySaturation, primaryValue).toColor(),
      secondary: HSVColor.fromAHSV(1.0, secondaryHue, secondarySaturation, secondaryValue).toColor(),
      accent: HSVColor.fromAHSV(1.0, accentHue, accentSaturation, accentValue).toColor(),
    );
  }
  
  /// Generate consistent pattern based on npub
  List<List<int>> generatePattern(String npub) {
    final hash = hashString(npub);
    final random = Random(hash);
    
    // Create 16x16 grid pattern
    final pattern = List.generate(16, (i) => List.filled(16, 0));
    
    // Select animal style based on npub hash
    final animalStyle = getAnimalStyle(hash);
    
    return _generateAnimalPattern(pattern, random, animalStyle);
  }
  
  /// Get animal style based on hash
  AnimalStyle getAnimalStyle(int hash) {
    final styles = AnimalStyle.values;
    return styles[hash % styles.length];
  }

  /// Generate animal pattern based on style
  List<List<int>> _generateAnimalPattern(List<List<int>> pattern, Random random, AnimalStyle style) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0; // Background color
      }
    }
    
    switch (style) {
      case AnimalStyle.cat:
        return _generateCatPattern(pattern, random);
      case AnimalStyle.dog:
        return _generateDogPattern(pattern, random);
      case AnimalStyle.rabbit:
        return _generateRabbitPattern(pattern, random);
      case AnimalStyle.mouse:
        return _generateMousePattern(pattern, random);
      case AnimalStyle.fox:
        return _generateFoxPattern(pattern, random);
      case AnimalStyle.bear:
        return _generateBearPattern(pattern, random);
      case AnimalStyle.panda:
        return _generatePandaPattern(pattern, random);
      case AnimalStyle.tiger:
        return _generateTigerPattern(pattern, random);
      case AnimalStyle.lion:
        return _generateLionPattern(pattern, random);
      case AnimalStyle.elephant:
        return _generateElephantPattern(pattern, random);
      case AnimalStyle.giraffe:
        return _generateGiraffePattern(pattern, random);
      case AnimalStyle.penguin:
        return _generatePenguinPattern(pattern, random);
      case AnimalStyle.owl:
        return _generateOwlPattern(pattern, random);
      case AnimalStyle.duck:
        return _generateDuckPattern(pattern, random);
      case AnimalStyle.fish:
        return _generateFishPattern(pattern, random);
    }
  }

  /// Get color for specific pixel based on pattern
  Color _getPixelColor(AvatarColors colors, List<List<int>> pattern, int gridX, int gridY) {
    if (gridX < 0 || gridX >= 16 || gridY < 0 || gridY >= 16) {
      return colors.primary;
    }
    
    final patternValue = pattern[gridY][gridX];
    
    switch (patternValue) {
      case 0:
        return colors.primary;
      case 1:
        return colors.secondary;
      case 2:
        return colors.accent;
      case 3:
        return _blendColors(colors.primary, colors.secondary, 0.5);
      default:
        return colors.primary;
    }
  }

  /// Blend two colors
  Color _blendColors(Color color1, Color color2, double ratio) {
    return Color.fromARGB(
      ((color1.a * (1 - ratio) + color2.a * ratio) * 255).round(),
      ((color1.r * (1 - ratio) + color2.r * ratio) * 255 / 255).round(),
      ((color1.g * (1 - ratio) + color2.g * ratio) * 255 / 255).round(),
      ((color1.b * (1 - ratio) + color2.b * ratio) * 255 / 255).round(),
    );
  }
  
  /// Simple hash function for consistent random generation
  int hashString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash;
  }
  
  /// Get animal style name for debugging
  String getAnimalStyleName(String npub) {
    final hash = hashString(npub);
    final style = getAnimalStyle(hash);
    switch (style) {
      case AnimalStyle.cat:
        return '🐱 Cat';
      case AnimalStyle.dog:
        return '🐕 Dog';
      case AnimalStyle.rabbit:
        return '🐰 Rabbit';
      case AnimalStyle.mouse:
        return '🐀 Mouse';
      case AnimalStyle.fox:
        return '🦊 Fox';
      case AnimalStyle.bear:
        return '🐻 Bear';
      case AnimalStyle.panda:
        return '🐼 Panda';
      case AnimalStyle.tiger:
        return '🐯 Tiger';
      case AnimalStyle.lion:
        return '🦁 Lion';
      case AnimalStyle.elephant:
        return '🐘 Elephant';
      case AnimalStyle.giraffe:
        return '🦒 Giraffe';
      case AnimalStyle.penguin:
        return '🐧 Penguin';
      case AnimalStyle.owl:
        return '🦉 Owl';
      case AnimalStyle.duck:
        return '🦆 Duck';
      case AnimalStyle.fish:
        return '🐠 Fish';
    }
  }
  
  // Animal pattern generators
  List<List<int>> _generateCatPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Cat body (oval)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Cat ears (triangles)
    pattern[2][6] = 2; pattern[2][7] = 2; pattern[3][6] = 2; // Left ear
    pattern[2][9] = 2; pattern[2][10] = 2; pattern[3][10] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; // Left eye
    pattern[6][11] = 3; // Right eye
    
    // Nose
    pattern[8][8] = 3;
    
    // Whiskers
    pattern[7][4] = 2; pattern[7][12] = 2; // Horizontal whiskers
    pattern[6][3] = 2; pattern[6][13] = 2; // Diagonal whiskers
    
    return pattern;
  }
  
  List<List<int>> _generateDogPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Dog body (round)
    for (int y = 3; y < 13; y++) {
      for (int x = 3; x < 13; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 5;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Dog ears (floppy)
    pattern[2][5] = 2; pattern[2][6] = 2; pattern[3][5] = 2; pattern[3][6] = 2; // Left ear
    pattern[2][10] = 2; pattern[2][11] = 2; pattern[3][10] = 2; pattern[3][11] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; // Left eye
    pattern[6][11] = 3; // Right eye
    
    // Nose
    pattern[8][8] = 3;
    
    // Tongue
    pattern[9][7] = 2; pattern[9][8] = 2; pattern[9][9] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateRabbitPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Rabbit body (oval)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Long ears
    pattern[1][7] = 2; pattern[2][7] = 2; pattern[3][7] = 2; // Left ear
    pattern[1][9] = 2; pattern[2][9] = 2; pattern[3][9] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; // Left eye
    pattern[6][11] = 3; // Right eye
    
    // Nose
    pattern[8][8] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generateMousePattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Mouse body (small round)
    for (int y = 5; y < 11; y++) {
      for (int x = 5; x < 11; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 3;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Small ears
    pattern[3][6] = 2; pattern[3][10] = 2;
    
    // Eyes
    pattern[6][6] = 3; pattern[6][10] = 3;
    
    // Nose
    pattern[8][8] = 3;
    
    // Tail
    pattern[9][4] = 2; pattern[10][3] = 2; pattern[11][2] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateFoxPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Fox body (oval)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Pointed ears
    pattern[2][6] = 2; pattern[1][7] = 2; // Left ear
    pattern[2][10] = 2; pattern[1][9] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; pattern[6][11] = 3;
    
    // Nose
    pattern[8][8] = 3;
    
    // Bushy tail
    pattern[9][2] = 2; pattern[10][2] = 2; pattern[11][2] = 2;
    pattern[9][3] = 2; pattern[10][3] = 2; pattern[11][3] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateBearPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Bear body (large round)
    for (int y = 3; y < 13; y++) {
      for (int x = 3; x < 13; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 5;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Round ears
    pattern[2][6] = 2; pattern[2][7] = 2; pattern[3][6] = 2; pattern[3][7] = 2; // Left ear
    pattern[2][9] = 2; pattern[2][10] = 2; pattern[3][9] = 2; pattern[3][10] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; pattern[6][11] = 3;
    
    // Nose
    pattern[8][8] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generatePandaPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Panda body (white)
    for (int y = 3; y < 13; y++) {
      for (int x = 3; x < 13; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 5;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          pattern[y][x] = 1; // White body
        }
      }
    }
    
    // Black ears
    pattern[2][6] = 2; pattern[2][7] = 2; pattern[3][6] = 2; pattern[3][7] = 2; // Left ear
    pattern[2][9] = 2; pattern[2][10] = 2; pattern[3][9] = 2; pattern[3][10] = 2; // Right ear
    
    // Black eyes
    pattern[6][5] = 2; pattern[6][6] = 2; pattern[6][11] = 2; pattern[6][12] = 2;
    pattern[7][5] = 2; pattern[7][6] = 2; pattern[7][11] = 2; pattern[7][12] = 2;
    
    // Black nose
    pattern[8][7] = 2; pattern[8][8] = 2; pattern[8][9] = 2;
    pattern[9][8] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateTigerPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Tiger body (orange)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Orange body
        }
      }
    }
    
    // Stripes
    pattern[5][4] = 2; pattern[5][12] = 2; // Vertical stripes
    pattern[7][4] = 2; pattern[7][12] = 2;
    pattern[9][4] = 2; pattern[9][12] = 2;
    
    // Eyes
    pattern[6][5] = 3; pattern[6][11] = 3;
    
    // Nose
    pattern[8][8] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generateLionPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Lion body (golden)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Golden body
        }
      }
    }
    
    // Mane (around head)
    for (int y = 2; y < 8; y++) {
      for (int x = 3; x < 13; x++) {
        if (y == 2 || y == 3 || x == 3 || x == 12) {
          pattern[y][x] = 2; // Mane color
        }
      }
    }
    
    // Eyes
    pattern[6][5] = 3; pattern[6][11] = 3;
    
    // Nose
    pattern[8][8] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generateElephantPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Elephant body (gray)
    for (int y = 5; y < 11; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 3;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Gray body
        }
      }
    }
    
    // Trunk
    pattern[9][8] = 2; pattern[10][8] = 2; pattern[11][8] = 2;
    
    // Ears (large)
    pattern[3][4] = 2; pattern[3][5] = 2; pattern[4][4] = 2; pattern[4][5] = 2; // Left ear
    pattern[3][11] = 2; pattern[3][12] = 2; pattern[4][11] = 2; pattern[4][12] = 2; // Right ear
    
    // Eyes
    pattern[6][5] = 3; pattern[6][11] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generateGiraffePattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Giraffe body (yellow with spots)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Yellow body
        }
      }
    }
    
    // Spots
    pattern[5][6] = 2; pattern[5][10] = 2;
    pattern[7][6] = 2; pattern[7][10] = 2;
    pattern[9][6] = 2; pattern[9][10] = 2;
    
    // Long neck
    for (int y = 2; y < 6; y++) {
      pattern[y][8] = 1;
    }
    
    // Eyes
    pattern[4][7] = 3; pattern[4][9] = 3;
    
    return pattern;
  }
  
  List<List<int>> _generatePenguinPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Penguin body (black and white)
    for (int y = 3; y < 13; y++) {
      for (int x = 3; x < 13; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 5;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          if (y < 8) {
            pattern[y][x] = 2; // Black top
          } else {
            pattern[y][x] = 1; // White bottom
          }
        }
      }
    }
    
    // Eyes
    pattern[5][5] = 3; pattern[5][11] = 3;
    
    // Beak
    pattern[6][8] = 2;
    
    // Wings
    pattern[7][4] = 2; pattern[7][12] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateOwlPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Owl body (round)
    for (int y = 3; y < 13; y++) {
      for (int x = 3; x < 13; x++) {
        final centerX = 8;
        final centerY = 8;
        final radius = 5;
        
        final distance = sqrt((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
        
        if (distance <= radius) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Large eyes
    pattern[5][4] = 3; pattern[5][5] = 3; pattern[5][11] = 3; pattern[5][12] = 3;
    pattern[6][4] = 3; pattern[6][5] = 3; pattern[6][11] = 3; pattern[6][12] = 3;
    
    // Beak
    pattern[7][8] = 2;
    
    // Wings
    pattern[8][2] = 2; pattern[8][14] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateDuckPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Duck body (oval)
    for (int y = 4; y < 12; y++) {
      for (int x = 4; x < 12; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 4;
        final radiusY = 4;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Bill
    pattern[6][7] = 2; pattern[6][8] = 2; pattern[6][9] = 2;
    pattern[7][7] = 2; pattern[7][8] = 2; pattern[7][9] = 2;
    
    // Eyes
    pattern[5][6] = 3; pattern[5][10] = 3;
    
    // Wings
    pattern[7][4] = 2; pattern[7][12] = 2;
    
    return pattern;
  }
  
  List<List<int>> _generateFishPattern(List<List<int>> pattern, Random random) {
    // Background
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        pattern[y][x] = 0;
      }
    }
    
    // Fish body (oval)
    for (int y = 6; y < 10; y++) {
      for (int x = 5; x < 11; x++) {
        final centerX = 8;
        final centerY = 8;
        final radiusX = 3;
        final radiusY = 2;
        
        final distance = ((x - centerX) * (x - centerX)) / (radiusX * radiusX) + 
                        ((y - centerY) * (y - centerY)) / (radiusY * radiusY);
        
        if (distance <= 1.0) {
          pattern[y][x] = 1; // Body color
        }
      }
    }
    
    // Tail
    pattern[7][4] = 2; pattern[8][4] = 2; pattern[9][4] = 2;
    
    // Eye
    pattern[7][9] = 3;
    
    // Fins
    pattern[6][6] = 2; pattern[6][10] = 2;
    
    return pattern;
  }
}
