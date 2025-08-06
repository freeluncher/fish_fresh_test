# Performance Optimization untuk Live Camera Detection

## 1. **Camera Configuration**

### Resolution Settings
```dart
// Gunakan resolusi medium untuk balance performance vs quality
_cameraController = CameraController(
  backCamera,
  ResolutionPreset.medium, // 720p - optimal untuk real-time
  enableAudio: false,
  imageFormatGroup: ImageFormatGroup.yuv420, // Format optimal
);
```

### Frame Rate Control
```dart
// Atur detection interval untuk mengontrol FPS
static const int detectionIntervalMs = 500; // 2 FPS detection
static const bool skipFramesWhenBusy = true;
```

## 2. **Model Optimization**

### Input Size Reduction
```dart
// Resize input image untuk mengurangi processing time
int maxSize = 416; // Lebih kecil dari 640 untuk mobile
if (image.width > maxSize || image.height > maxSize) {
  double scale = maxSize / math.max(image.width, image.height);
  image = img.copyResize(image, 
    width: (image.width * scale).round(),
    height: (image.height * scale).round()
  );
}
```

### Model Quantization
- Gunakan **int8 quantized model** untuk mobile deployment
- Konversi dari float32 ke int8 untuk mengurangi ukuran dan meningkatkan speed

## 3. **Memory Management**

### Image Processing Optimization
```dart
// Reuse buffer untuk menghindari garbage collection
Float32List? _reuseBuffer;

Float32List preprocessImage(img.Image image) {
  int bufferSize = 1 * inputSize * inputSize * 3;
  _reuseBuffer ??= Float32List(bufferSize);
  
  // Process langsung ke existing buffer
  // ... preprocessing code
  
  return _reuseBuffer!;
}
```

### Dispose Resources
```dart
@override
void dispose() {
  _cameraController?.dispose();
  _detectionService.dispose();
  _reuseBuffer = null; // Clear buffer
  super.dispose();
}
```

## 4. **Threading & Isolates**

### Background Processing
```dart
// Gunakan compute() untuk heavy processing
List<DetectionResult> results = await compute(
  _runDetectionInIsolate, 
  {'image': image, 'model': model}
);
```

### Concurrent Detection Limit
```dart
// Batasi concurrent detections
static const int maxConcurrentDetections = 1;
if (_activeDetections >= maxConcurrentDetections) {
  return; // Skip frame
}
```

## 5. **UI Optimization**

### Reduce Rebuilds
```dart
//Gunakan ValueNotifier untuk state yang sering berubah
ValueNotifier<List<DetectionResult>> detectionsNotifier = 
    ValueNotifier([]);

// Dalam widget
ValueListenableBuilder<List<DetectionResult>>(
  valueListenable: detectionsNotifier,
  builder: (context, detections, child) {
    return DetectionOverlay(detections: detections);
  },
)
```

### Efficient Overlay Rendering
```dart
// Custom painter dengan shouldRepaint optimization
@override
bool shouldRepaint(DetectionOverlayPainter oldDelegate) {
  return oldDelegate.detections.length != detections.length ||
         !listEquals(oldDelegate.detections, detections);
}
```

## 6. **Battery & Thermal Management**

### Adaptive Quality
```dart
// Turunkan quality jika device panas atau battery rendah
class AdaptiveDetectionSettings {
  static int getOptimalInterval() {
    // Check battery level
    if (batteryLevel < 20) return 1000; // 1 FPS
    
    // Check thermal state
    if (thermalState == ThermalState.critical) return 2000; // 0.5 FPS
    
    return 500; // Normal 2 FPS
  }
}
```

### Background Behavior
```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.paused:
      _pauseDetection();
      break;
    case AppLifecycleState.resumed:
      _resumeDetection();
      break;
    case AppLifecycleState.inactive:
      _reduceDetectionRate();
      break;
  }
}
```

## 7. **Network & Storage Optimization**

### Model Caching
```dart
// Cache model di local storage
class ModelCache {
  static const String modelPath = 'cached_models/fish_detection.tflite';
  
  static Future<bool> isCached() async {
    return await File(modelPath).exists();
  }
  
  static Future<void> cacheModel(Uint8List modelData) async {
    await File(modelPath).writeAsBytes(modelData);
  }
}
```

## 8. **Monitoring & Analytics**

### Performance Metrics
```dart
class PerformanceMonitor {
  static int _frameCount = 0;
  static DateTime _lastCheck = DateTime.now();
  static double _avgProcessingTime = 0;
  
  static void recordFrame(int processingTimeMs) {
    _frameCount++;
    _avgProcessingTime = (_avgProcessingTime + processingTimeMs) / 2;
    
    if (DateTime.now().difference(_lastCheck).inSeconds >= 10) {
      print('FPS: ${_frameCount / 10}');
      print('Avg processing: ${_avgProcessingTime}ms');
      _resetStats();
    }
  }
}
```

## 9. **Platform-Specific Optimizations**

### Android
```gradle
// android/app/build.gradle
android {
    ...
    buildTypes {
        release {
            // Enable R8 code shrinking
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
        }
    }
}
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
</array>
```

## 10. **Testing & Profiling**

### Performance Testing
```dart
// Test dengan berbagai device dan kondisi
void testPerformance() {
  // Low-end device simulation
  // High-end device optimization
  // Battery drain testing
  // Thermal throttling testing
}
```

### Memory Profiling
- Gunakan Flutter Inspector untuk monitor memory usage
- Profile dengan `flutter profile` command
- Monitor GPU usage untuk overlay rendering

## Rekomendasi Implementasi

1. **Start Simple**: Mulai dengan detection interval 1000ms (1 FPS)
2. **Progressive Enhancement**: Tingkatkan FPS gradually berdasarkan device capability
3. **User Control**: Beri user option untuk adjust quality vs performance
4. **Monitoring**: Implement real-time performance monitoring
5. **Fallback**: Siapkan fallback ke static image detection jika live detection terlalu lambat