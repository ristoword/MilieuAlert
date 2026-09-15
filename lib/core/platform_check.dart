import 'package:flutter/foundation.dart' show kIsWeb;

bool get isNativePlatform => !kIsWeb;
bool get isWebPlatform => kIsWeb;
