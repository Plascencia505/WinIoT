import 'package:flutter/material.dart';
import '../config/sensor_config.dart';

// --- HEADER DEL SISTEMA (INTEGRADO CON ALERTA) ---
class SystemHeader extends StatelessWidget {
  final bool isHot;
  final bool isRaining;
  final bool isDaytime;
  final int luzRaw;
  final int ishumid;
  final String alertMessage; // Mensaje de Firebase

  const SystemHeader({
    super.key,
    required this.isHot,
    required this.isRaining,
    required this.isDaytime,
    required this.luzRaw,
    required this.ishumid,
    required this.alertMessage,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    // Lógica de color basada en la Alerta o Sensores
    if (isRaining || alertMessage.contains("LLUVIA")) {
      statusColor = Colors.red;
      statusIcon = Icons.thunderstorm;
    } else if (isHot ||
        alertMessage.contains("CONFORT") ||
        alertMessage.contains("SOFOCO")) {
      statusColor = Colors.orange;
      statusIcon = Icons.thermostat;
    } else if (alertMessage.contains("NOCHE")) {
      statusColor = Colors.indigo;
      statusIcon = Icons.nightlight_round;
    } else if (alertMessage.contains("BLOQUEO") ||
        alertMessage.contains("RUIDO")) {
      statusColor = Colors.grey;
      statusIcon = Icons.lock;
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Estado del Sistema",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  alertMessage.toUpperCase(), // Muestra el mensaje de Firebase
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- TEMP ---
class TempSensorTile extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String unit;

  const TempSensorTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.unit = "°C",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          Text(
            "${value.toStringAsFixed(1)}$unit",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// --- LLUVIA ---
class RainSensorCard extends StatelessWidget {
  final int rawValue;
  const RainSensorCard({super.key, required this.rawValue});

  @override
  Widget build(BuildContext context) {
    double percentage = SensorConfig.getInversePercentage(rawValue);
    String status;
    Color color;

    if (percentage < 0.15) {
      status = "Seco";
      color = Colors.grey;
    } else if (percentage < 0.45) {
      status = "Rocío / Húmedo";
      color = Colors.blue.shade300;
    } else if (rawValue > 2000) {
      status = "Lluvia Ligera";
      color = Colors.blue;
    } else {
      status = "PELIGRO - LLUVIA";
      color = Colors.red;
    }

    return _BaseEnvCard(
      icon: Icons.water_drop,
      color: color,
      title: "Lluvia",
      status: status,
      percentage: percentage,
      rawVal: rawValue,
    );
  }
}

// --- LUZ ---
class LightSensorCard extends StatelessWidget {
  final bool isDaytime;
  final int luzRaw;
  const LightSensorCard({
    super.key,
    required this.isDaytime,
    required this.luzRaw,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = SensorConfig.getLuxPercentage(luzRaw);
    return _BaseEnvCard(
      icon: (isDaytime ? Icons.light_mode : Icons.nightlight_round),
      color: (isDaytime ? Colors.amber : Colors.indigo),
      title: "Luminosidad",
      status: "$luzRaw lux",
      percentage: percentage,
      rawVal: luzRaw,
    );
  }
}

// --- BASE ---
class _BaseEnvCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String status;
  final double percentage;
  final int rawVal;
  const _BaseEnvCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.status,
    required this.percentage,
    required this.rawVal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade100,
                  color: color,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(5),
                ),
                Text(
                  "Raw: $rawVal",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
