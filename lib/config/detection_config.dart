class DetectionConfig {
  // Konfigurasi yang dapat diubah
  static double bandengDetectionThreshold =
      0.3; // threshold deteksi ikan bandeng
  static double freshnessClassificationThreshold =
      0.1; // threshold klasifikasi kesegaran
  static double nmsThreshold = 0.5;
  static int maxDetections = 10;
  static bool showOnlyTopDetection = false;
  static bool enableNMS = true;

  // Metode untuk mengatur mode deteksi
  static void setTopDetectionMode(bool enabled) {
    showOnlyTopDetection = enabled;
    if (enabled) {
      maxDetections = 1;
    } else {
      maxDetections = 10;
    }
  }

  // Metode untuk mengatur threshold deteksi bandeng
  static void setBandengDetectionThreshold(double threshold) {
    bandengDetectionThreshold = threshold.clamp(0.1, 0.9);
  }

  // Metode untuk mengatur threshold klasifikasi kesegaran
  static void setFreshnessClassificationThreshold(double threshold) {
    freshnessClassificationThreshold = threshold.clamp(0.05, 0.5);
  }

  // Metode untuk mengatur NMS threshold
  static void setNMSThreshold(double threshold) {
    nmsThreshold = threshold.clamp(0.1, 0.9);
  }

  // Preset konfigurasi
  static void setHighPrecisionMode() {
    bandengDetectionThreshold = 0.7;
    freshnessClassificationThreshold = 0.2;
    nmsThreshold = 0.3;
    maxDetections = 5;
    showOnlyTopDetection = false;
    enableNMS = true;
  }

  static void setBalancedMode() {
    bandengDetectionThreshold = 0.5;
    freshnessClassificationThreshold = 0.1;
    nmsThreshold = 0.5;
    maxDetections = 10;
    showOnlyTopDetection = false;
    enableNMS = true;
  }

  static void setHighSensitivityMode() {
    bandengDetectionThreshold = 0.3;
    freshnessClassificationThreshold = 0.05;
    nmsThreshold = 0.7;
    maxDetections = 15;
    showOnlyTopDetection = false;
    enableNMS = true;
  }

  static void setSingleDetectionMode() {
    bandengDetectionThreshold = 0.3;
    freshnessClassificationThreshold = 0.1;
    nmsThreshold = 0.5;
    maxDetections = 1;
    showOnlyTopDetection = true;
    enableNMS = true;
  }
}
