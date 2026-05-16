import 'package:camera/camera.dart';
import 'package:detector/src/classifier/quality_classifier.dart';
import 'package:detector/src/screens/result.dart';
import 'package:detector/src/widgets/capture_notice.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Home({super.key, required this.cameras});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final PineappleClassifier _classifier = PineappleClassifier();

  // ── Design tokens ──────────────────────────────────────────────
  static const _bg = Color(0xFF0D1A12); // deep forest
  static const _surface = Color(0xFF162119); // card surface
  static const _accent = Color(0xFFF5C842); // golden pineapple yellow
  static const _accentDim = Color(0xFF26200A); // dark amber tint
  static const _cream = Color(0xFFF5F0E8); // warm cream text
  static const _muted = Color(0xFF6B8F74); // muted body text
  static const _divider = Color(0xFF1F3028); // subtle divider

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _classifier.loadModel();
    _initializeCamera();
    _fadeController.forward();
  }

  Future<void> _initializeCamera() async {
    setState(() => _isLoading = true);
    try {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
      await _controller.initialize();
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.description}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    Results(imagePath: image.path, classifier: _classifier),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Subtle radial glow top-right
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: w * 0.7,
                height: w * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_accent.withOpacity(0.08), Colors.transparent],
                  ),
                ),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: h * 0.055),

                      // ── Top bar ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Brand mark
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: _divider),
                              borderRadius: BorderRadius.circular(20),
                              color: _surface,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _accent,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'HowPine',
                                  style: TextStyle(
                                    color: _cream,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Version badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _accentDim,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'v1.0',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.06),

                      // ── Hero logo ─────────────────────────────
                      Center(
                        child: Container(
                          width: w * 0.42,
                          height: w * 0.42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // Cream background so the light-mode logo looks native
                            color: const Color(0xFFF0EFDE),
                            border: Border.all(
                              color: _accent.withOpacity(0.35),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withOpacity(0.22),
                                blurRadius: 36,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.asset(
                              'assets/images/HowPine Logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.045),

                      // ── Headline ──────────────────────────────
                      Text(
                        'Pineapple\nQuality Scanner',
                        style: TextStyle(
                          fontSize: (w * 0.09).clamp(30.0, 48.0),
                          fontWeight: FontWeight.w800,
                          color: _cream,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'AI-powered damage detection\nin seconds.',
                        style: TextStyle(
                          fontSize: (w * 0.04).clamp(14.0, 18.0),
                          color: _muted,
                          height: 1.6,
                          letterSpacing: 0.1,
                        ),
                      ),

                      SizedBox(height: h * 0.055),

                      // ── Stats row ─────────────────────────────
                      _StatsRow(w: w),

                      SizedBox(height: h * 0.05),

                      // ── Primary CTA: Camera ───────────────────
                      _PrimaryButton(
                        label: 'Scan with Camera',
                        icon: Icons.photo_camera_outlined,
                        disabled: _isLoading,
                        onTap:
                            () => showDialog(
                              context: context,
                              builder:
                                  (context) => CaptureNotice(
                                    cameras: widget.cameras,
                                    classifier: _classifier,
                                  ),
                            ),
                      ),

                      SizedBox(height: 12),

                      // ── Secondary CTA: Gallery ────────────────
                      _SecondaryButton(
                        label: 'Upload from Gallery',
                        icon: Icons.photo_library_outlined,
                        disabled: _isLoading,
                        onTap: () => _pickImage(context),
                      ),

                      SizedBox(height: h * 0.04),

                      // ── Footer note ───────────────────────────
                      Center(
                        child: Text(
                          'For best results, use a good light source\nand keep the pineapple centered.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted.withOpacity(0.6),
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.04),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(_accent),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading…',
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.dispose();
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// ── Stats row widget ──────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double w;
  const _StatsRow({required this.w});

  static const _bg = Color(0xFF162119);
  static const _accent = Color(0xFFF5C842);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _divider = Color(0xFF1F3028);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('2', 'Categories'),
          _dividerLine(),
          _stat('<2s', 'Scan Time'),
          _dividerLine(),
          _stat('AI', 'Powered'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: (w * 0.055).clamp(18.0, 26.0),
            fontWeight: FontWeight.w800,
            color: _accent,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: _muted, letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _dividerLine() => Container(width: 1, height: 32, color: _divider);
}

// ── Primary button ────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.disabled,
    required this.onTap,
  });

  static const _accent = Color(0xFFF5C842);
  static const _bg = Color(0xFF0D1A12);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _bg, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: _bg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Secondary button ──────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.disabled,
    required this.onTap,
  });

  static const _accent = Color(0xFFF5C842);
  static const _accentDim = Color(0xFF26200A);
  static const _divider = Color(0xFF1F3028);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: _accentDim,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _accent, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: _accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
