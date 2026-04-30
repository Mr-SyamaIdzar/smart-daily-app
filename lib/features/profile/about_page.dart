import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Halaman Tentang Aplikasi — tampilan bersih & minimalis.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.xxl),

            // App info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      child: _AnimatedLogo(),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Smart Daily Assistant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xxl),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSizes.lg),

            // Label
            const Text(
              'Dikembangkan oleh',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Developer 1
            _buildDevRow(
              name: 'Rasyid Tri Sasongko',
              nim: '123230043',
            ),
            const SizedBox(height: AppSizes.md),

            // Developer 2
            _buildDevRow(
              name: 'Muhammad Raihan Syamaidzar',
              nim: '123230072',
            ),

            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.border),
          ],
        ),
      ),
    );
  }

  Widget _buildDevRow({required String name, required String nim}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Text(
          nim,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Animated GIF Logo
// ─────────────────────────────────────────────

class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Gif(
      image: const AssetImage('assets/images/supikip-cuayo.gif'),
      controller: _controller,
      autostart: Autostart.loop,
      width: 64,
      height: 64,
      fit: BoxFit.cover,
    );
  }
}
