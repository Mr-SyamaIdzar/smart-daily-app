import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Service untuk mendeteksi gerakan "Shake" (guncangan) menggunakan akselerometer.
/// Menggunakan UserAccelerometerEvents untuk mengabaikan gravitasi.
class ShakeService {
  final double threshold;
  final Duration cooldown;

  StreamSubscription<UserAccelerometerEvent>? _subscription;
  final _shakeController = StreamController<void>.broadcast();

  /// Stream yang akan memancarkan event setiap kali guncangan terdeteksi.
  Stream<void> get onShake => _shakeController.stream;

  DateTime? _lastShakeTime;

  ShakeService({
    this.threshold = 12.0,
    this.cooldown = const Duration(seconds: 1),
  });

  /// Mulai mendengarkan sensor akselerometer.
  void startListening() {
    if (_subscription != null) return;

    _subscription = userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      // Hitung magnitudo percepatan (sqrt(x^2 + y^2 + z^2))
      final double acceleration = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Debug print untuk melihat nilai percepatan (Opsional: bisa dihapus setelah debug)
      // print('Acceleration: $acceleration');

      if (acceleration > threshold) {
        final now = DateTime.now();
        
        // Cek apakah sudah melewati masa cooldown
        if (_lastShakeTime == null || 
            now.difference(_lastShakeTime!) > cooldown) {
          _lastShakeTime = now;
          print('Shake detected! Magnitude: $acceleration');
          _shakeController.add(null);
        }
      }
    });
  }

  /// Berhenti mendengarkan sensor akselerometer.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Membersihkan resource.
  void dispose() {
    stopListening();
    _shakeController.close();
  }
}
