import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'widgets/window_card.dart';
import 'widgets/sensor_cards.dart';
import 'widgets/sound_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Window',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      home: const MainDashboardPage(),
    );
  }
}

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  // CORRECCIÓN 1: Apuntamos directo al nodo 'ventana'
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('ventana');

  // Variables de Estado
  bool _isWindowOpen = false;
  bool _isFanActive = false;
  bool _isAutoMode = false;
  bool _isLocked = false;

  // Variables de Sensores
  double _tempExt = 0.0;
  double _tempInt = 0.0;
  int _lluviaRaw = 4095;
  int _humedadVal = 0;
  int _luzRaw = 0;
  int _sonidoExt = 0;
  int _sonidoInt = 0;

  // Anti-Spam
  DateTime? _lastActionTime;

  StreamSubscription<DatabaseEvent>? _globalSub;

  @override
  void initState() {
    super.initState();
    _initListeners();
  }

  void _initListeners() {
    _globalSub = _dbRef.onValue.listen((event) {
      final data = event.snapshot.value;

      // Verificamos que data no sea null y sea un Mapa
      if (data != null && data is Map) {
        if (mounted) {
          setState(() {
            // --- CORRECCIÓN 2: MAPEO EXACTO A TU JSON ---

            // 1. Datos que están "sueltos" en la raíz de 'ventana'
            _lluviaRaw = (data['lluvia'] as num?)?.toInt() ?? 4095;
            _luzRaw = (data['luminosidad'] as num?)?.toInt() ?? 0;
            _humedadVal = (data['humedad_interior'] as num?)?.toInt() ?? 0;

            // 2. Carpeta "posicion"
            if (data['posicion'] is Map) {
              final pos = data['posicion'] as Map;
              _isWindowOpen = (pos['is_open'] as bool?) ?? false;
            }

            // 3. Carpeta "sistema"
            if (data['sistema'] is Map) {
              final sys = data['sistema'] as Map;
              _isLocked = (sys['is_lock'] as bool?) ?? false;
              _isFanActive = (sys['fan_active'] as bool?) ?? false;

              // Modo (puede venir como String "AUTO" o bool)
              final modoVal = sys['modo'];
              if (modoVal is String) {
                _isAutoMode = (modoVal.toUpperCase() == "AUTO");
              } else {
                _isAutoMode = false;
              }
            }

            // 4. Carpeta "temperatura"
            if (data['temperatura'] is Map) {
              final temp = data['temperatura'] as Map;
              _tempInt = (temp['interior'] as num?)?.toDouble() ?? 0.0;
              _tempExt = (temp['exterior'] as num?)?.toDouble() ?? 0.0;
            }

            // 5. Carpeta "sonido"
            if (data['sonido'] is Map) {
              final sound = data['sonido'] as Map;
              _sonidoInt = (sound['interior'] as num?)?.toInt() ?? 0;
              _sonidoExt = (sound['exterior'] as num?)?.toInt() ?? 0;
            }
          });
        }
      }
    });
  }

  bool _canAct() {
    if (_lastActionTime == null) {
      _lastActionTime = DateTime.now();
      return true;
    }
    if (DateTime.now().difference(_lastActionTime!) <
        const Duration(seconds: 2)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⏳ Espera un momento..."),
          duration: Duration(milliseconds: 500),
        ),
      );
      return false;
    }
    _lastActionTime = DateTime.now();
    return true;
  }

  @override
  void dispose() {
    _globalSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isHot = _tempInt > 25.0;
    bool isRaining = _lluviaRaw < 1800;
    bool isDaytime = _luzRaw > 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Window Control",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!_canAct()) return;

          if (isRaining) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🚫 Bloqueado por LLUVIA")),
            );
            return;
          }
          if (_isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🔒 Sistema BLOQUEADO")),
            );
            return;
          }
          if (_isAutoMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🤖 Cambia a MANUAL para operar")),
            );
            return;
          }

          // CORRECCIÓN 3: Ruta de escritura correcta
          _dbRef.child('posicion/is_open').set(!_isWindowOpen);
        },
        backgroundColor: (isRaining || _isLocked)
            ? Colors.grey
            : (_isWindowOpen ? Colors.indigo : Colors.blue),
        icon: Icon(
          (isRaining || _isLocked)
              ? Icons.lock
              : (_isWindowOpen ? Icons.close : Icons.open_in_browser),
          color: Colors.white,
        ),
        label: Text(
          _isWindowOpen ? "CERRAR" : "ABRIR",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SystemHeader(
              isHot: isHot,
              isRaining: isRaining,
              isDaytime: isDaytime,
              luzRaw: _luzRaw,
              ishumid: _humedadVal,
            ),
            const SizedBox(height: 25),

            _sectionTitle("CONTROL PRINCIPAL"),
            WindowControlCard(
              isOpen: _isWindowOpen,
              isRaining: isRaining,
              onWindowToggle: () {
                if (!_canAct()) return;
                if (isRaining || _isLocked || _isAutoMode) return;
                // Ruta correcta
                _dbRef.child('posicion/is_open').set(!_isWindowOpen);
              },

              isSwitchOn: _isAutoMode,
              onSwitchChanged: (val) {
                if (isRaining || _isLocked) return;
                // Ruta correcta
                _dbRef.child('sistema/modo').set(val ? "AUTO" : "MANUAL");
              },

              isLocked: _isLocked,
              onLockChanged: (val) {
                if (val == true && _isWindowOpen) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⚠️ Por seguridad, CIERRA la ventana antes de bloquear.",
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (isRaining && !val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "🚫 Lluvia detectada: No se puede desbloquear.",
                      ),
                    ),
                  );
                  return;
                }
                // Ruta correcta
                _dbRef.child('sistema/is_lock').set(val);
              },

              isFanActive: _isFanActive,
              onFanActive: (val) {
                if (isRaining || _isLocked || _isAutoMode) return;
                // Ruta correcta
                _dbRef.child('sistema/fan_active').set(val);
              },
            ),

            const SizedBox(height: 25),
            _sectionTitle("CLIMATIZACIÓN"),
            Row(
              children: [
                Expanded(
                  child: TempSensorTile(
                    title: "Interior",
                    value: _tempInt,
                    icon: Icons.home,
                    color: isHot ? Colors.orange : Colors.blue,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TempSensorTile(
                    title: "Exterior",
                    value: _tempExt,
                    icon: Icons.wb_sunny,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TempSensorTile(
                    title: "Humedad",
                    value: _humedadVal.toDouble(),
                    icon: Icons.water_drop,
                    color: Colors.cyan,
                    unit: "%",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            _sectionTitle("AMBIENTE EXTERIOR"),
            RainSensorCard(rawValue: _lluviaRaw),
            const SizedBox(height: 15),
            LightSensorCard(luzRaw: _luzRaw, isDaytime: isDaytime),

            const SizedBox(height: 25),
            _sectionTitle("NIVEL DE RUIDO"),
            SoundSensorCard(
              title: "Ruido Exterior",
              rawValue: _sonidoExt,
              color: Colors.purple,
            ),
            const SizedBox(height: 10),
            SoundSensorCard(
              title: "Ruido Interior",
              rawValue: _sonidoInt,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
