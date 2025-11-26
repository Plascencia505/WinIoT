class SensorConfig {
  // --- CONSTANTES DE CALIBRACIÓN ---

  // ESP32 ADC (12 bits): Valor máximo que entregan tus sensores análogos
  static const int maxAdc = 4095;

  // Sensor Luz (BH1750): Ajustado a tu máximo detectado (54,612 aprox)
  static const int maxLux = 55000;

  // --- FÓRMULAS DE CÁLCULO ---

  /// Para sensores lineales (Sonido, Potenciómetros)
  /// 0 es 0%, 4095 es 100%
  static double getStandardPercentage(int rawValue) {
    return (rawValue / maxAdc).clamp(0.0, 1.0);
  }

  /// Para sensores INVERSOS (Lluvia, Humedad de suelo)
  /// 4095 es 0% (Seco), 0 es 100% (Mojado)
  static double getInversePercentage(int rawValue) {
    return (1.0 - (rawValue / maxAdc)).clamp(0.0, 1.0);
  }

  /// Para sensor de Luz (Lux)
  static double getLuxPercentage(int rawValue) {
    return (rawValue / maxLux).clamp(0.0, 1.0);
  }
}
