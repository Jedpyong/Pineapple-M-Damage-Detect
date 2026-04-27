import 'package:camera/camera.dart';
import 'package:detector/src/classifier/quality_classifier.dart';
import 'package:flutter/material.dart';
import 'package:detector/src/screens/capture.dart';

class CaptureNotice extends StatelessWidget {
  final List<CameraDescription> cameras;
  final PineappleClassifier classifier;
  const CaptureNotice({
    super.key,
    required this.cameras,
    required this.classifier,
  });

  // ── Design tokens ──────────────────────────────────────────────
  static const _bg = Color(0xFF162119);
  static const _surface = Color(0xFF1C2B21);
  static const _accent = Color(0xFFF5C842);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _divider = Color(0xFF1F3028);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: w * 0.06),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     color: _surface,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: _divider),
                  //   ),
                  // child: const Icon(
                  //   Icons.photo_camera_outlined,
                  //   color: _accent,
                  //   size: 20,
                  // ),
                  // ),
                  // const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Capture Guidelines',
                        style: TextStyle(
                          color: _cream,
                          fontSize: (w * 0.047).clamp(16.0, 22.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                      Text(
                        'For best scan accuracy',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Divider ────────────────────────────────────
            Divider(height: 1, color: _divider),

            // ── Tips list ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _TipRow(
                    number: '01',
                    icon: Icons.wb_sunny_outlined,
                    title: 'Good Lighting',
                    subtitle: 'Take the photo in a bright, evenly lit area.',
                  ),
                  _TipDivider(),
                  _TipRow(
                    number: '02',
                    icon: Icons.center_focus_strong_outlined,
                    title: 'Fill the Frame',
                    subtitle: 'Pineapple should fill at least 70% of frame.',
                  ),
                  _TipDivider(),
                  _TipRow(
                    number: '03',
                    icon: Icons.do_not_touch_outlined,
                    title: 'Hold Steady',
                    subtitle: 'Avoid motion blur for accurate detection.',
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────
            Divider(height: 1, color: _divider),

            // ── Buttons ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Start scanning
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => Capture(
                                  cameras: cameras,
                                  classifier: classifier,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: const Color(0xFF0D1A12),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Start Scanning',
                              style: TextStyle(
                                color: const Color(0xFF0D1A12),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tip row ───────────────────────────────────────────────────────
class _TipRow extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipRow({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const _accent = Color(0xFFF5C842);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _surface = Color(0xFF1C2B21);
  static const _divider = Color(0xFF1F3028);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number + icon container
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _divider),
          ),
          child: Icon(icon, color: _accent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      color: _accent.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: _cream,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tip divider ───────────────────────────────────────────────────
class _TipDivider extends StatelessWidget {
  static const _divider = Color(0xFF1F3028);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: _divider),
    );
  }
}
