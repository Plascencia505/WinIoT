import 'package:flutter/material.dart';
import '../config/sensor_config.dart';

class SoundSensorCard extends StatelessWidget {
  final String title;
  final int rawValue;
  final Color color;

  const SoundSensorCard({
    super.key,
    required this.title,
    required this.rawValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = SensorConfig.getStandardPercentage(rawValue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                "${(percentage * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
