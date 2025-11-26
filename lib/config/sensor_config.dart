class SensorConfig {
  // --- CONSTANTES DE CALIBRACIÓN ---

  // ESP32 ADC (12 bits)
  static const int maxAdc = 4095;

  // Sensor Luz (BH1750) - Ajustado a tu máximo
  static const int maxLux = 55000;

  // --- FÓRMULAS ---

  // Sensores lineales (Sonido)
  static double getStandardPercentage(int rawValue) {
    return (rawValue / maxAdc).clamp(0.0, 1.0);
  }

  // Sensores inversos (Lluvia - YL83)
  static double getInversePercentage(int rawValue) {
    return (1.0 - (rawValue / maxAdc)).clamp(0.0, 1.0);
  }

  // Sensor de Luz
  static double getLuxPercentage(int rawValue) {
    return (rawValue / maxLux).clamp(0.0, 1.0);
  }
}
