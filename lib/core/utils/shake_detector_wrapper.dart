import 'dart:async';
import 'package:flutter/material.dart';
import '../di/service_locator.dart';
import '../services/shake_service.dart';
import '../router/app_router.dart';

/// Widget wrapper yang mendengarkan event guncangan (shake) dan memberikan feedback.
/// Berguna untuk fitur "Shake to Report" atau feedback instan lainnya.
class ShakeDetectorWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onShake;
  final bool showDefaultDialog;

  const ShakeDetectorWrapper({
    super.key,
    required this.child,
    this.onShake,
    this.showDefaultDialog = true,
  });

  @override
  State<ShakeDetectorWrapper> createState() => _ShakeDetectorWrapperState();
}

class _ShakeDetectorWrapperState extends State<ShakeDetectorWrapper> {
  late final ShakeService _shakeService;
  StreamSubscription? _shakeSubscription;

  @override
  void initState() {
    super.initState();
    _shakeService = ServiceLocator.sl<ShakeService>();
    _shakeService.startListening();
    
    _shakeSubscription = _shakeService.onShake.listen((_) {
      if (widget.onShake != null) {
        widget.onShake!();
      }
      
      if (widget.showDefaultDialog) {
        _showShakeFeedback();
      }
    });
  }

  void _showShakeFeedback() {
    if (!mounted) return;

    final navigatorContext = AppRouter.rootNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    showDialog(
      context: navigatorContext,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon atau Animasi (Gunakan Lottie jika ada, jika tidak gunakan Icon modern)
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vibration,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Guncangan Terdeteksi!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda ingin melaporkan masalah atau memberikan masukan?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Integrasi ke fitur laporan masalah bisa ditambahkan di sini
                        ScaffoldMessenger.of(navigatorContext).showSnackBar(
                          const SnackBar(
                            content: Text('Terima kasih! Tim kami akan segera meninjau.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Laporkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    // Kita tidak menghentikan shakeService di sini karena mungkin digunakan di tempat lain 
    // atau diinisialisasi secara global. Tapi jika ingin benar-benar stop:
    // _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
