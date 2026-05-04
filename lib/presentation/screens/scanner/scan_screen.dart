import 'package:flutter/material.dart';
import 'package:projeto/core/theme/app_colors.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                const Text('Scan Barcode',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: AppColors.border, size: 40),
                  _buildScannerOverlay(),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'Aponta a câmara para o código de barras do produto',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('Inserir código manualmente', style: TextStyle(fontSize: 14)),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          _corner(top: 0, left: 0, isTop: true, isLeft: true),
          _corner(top: 0, right: 0, isTop: true, isLeft: false),
          _corner(bottom: 0, left: 0, isTop: false, isLeft: true),
          _corner(bottom: 0, right: 0, isTop: false, isLeft: false),
          Center(
            child: Container(
              width: 180,
              height: 2,
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border(
            top:    isTop    ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            bottom: !isTop   ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            left:   isLeft   ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
            right:  !isLeft  ? const BorderSide(color: AppColors.secondary, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
