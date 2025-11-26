import 'package:flutter/material.dart';

class WindowControlCard extends StatelessWidget {
  final bool isOpen;
  final bool isRaining;
  final VoidCallback onWindowToggle;

  final bool isSwitchOn;
  final ValueChanged<bool> onSwitchChanged;

  final bool isLocked;
  final ValueChanged<bool> onLockChanged;

  final bool isFanActive;
  final ValueChanged<bool> onFanActive;

  const WindowControlCard({
    super.key,
    required this.isOpen,
    required this.isRaining,
    required this.onWindowToggle,
    required this.isSwitchOn,
    required this.onSwitchChanged,
    required this.isLocked,
    required this.onLockChanged,
    required this.isFanActive,
    required this.onFanActive,
  });

  @override
  Widget build(BuildContext context) {
    bool systemBlocked = isLocked || isRaining;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRaining
              ? [Colors.grey.shade700, Colors.blueGrey.shade900]
              : (isOpen
                    ? [Colors.cyan.shade400, Colors.blue.shade600]
                    : [Colors.indigo.shade400, Colors.deepPurple.shade600]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // BOTONERA
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: systemBlocked ? null : onWindowToggle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRaining
                              ? "CERRADA"
                              : (isOpen ? "ABIERTA" : "CERRADA"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isRaining
                              ? "🌧️ POR LLUVIA"
                              : (isLocked
                                    ? "⛔ SISTEMA BLOQUEADO"
                                    : "Toca para accionar"),
                          style: TextStyle(
                            color: systemBlocked
                                ? Colors.orangeAccent
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: systemBlocked
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRaining
                            ? Icons.thunderstorm
                            : (isLocked
                                  ? Icons.lock
                                  : (isOpen
                                        ? Icons.sensor_window_outlined
                                        : Icons.sensor_window)),
                        color: isRaining ? Colors.grey : Colors.indigo,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),

          // SWITCHES
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                _buildSwitchRow(
                  label: "Modo Automático",
                  val: isSwitchOn,
                  onChg: onSwitchChanged,
                  icon: Icons.auto_mode,
                  disabled: systemBlocked,
                ),
                _buildSwitchRow(
                  label: "Bloqueo de Seguridad",
                  val: isLocked,
                  onChg: onLockChanged,
                  icon: isLocked ? Icons.lock : Icons.lock_open,
                  activeColor: Colors.orangeAccent,
                  disabled: isRaining,
                ),
                _buildSwitchRow(
                  label: "Ventilador",
                  val: isFanActive,
                  onChg: onFanActive,
                  icon: Icons.air,
                  disabled: systemBlocked || isSwitchOn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool val,
    required ValueChanged<bool> onChg,
    required IconData icon,
    Color activeColor = const Color(0xFF69F0AE),
    bool disabled = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: disabled ? Colors.white30 : Colors.white70,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: disabled ? Colors.white30 : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: val,
            onChanged: disabled ? null : onChg,
            activeThumbColor: activeColor,
            activeTrackColor: Colors.white24,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.black12,
          ),
        ),
      ],
    );
  }
}
