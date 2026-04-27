import 'dart:io';
import 'package:detector/src/classifier/quality_classifier.dart';
import 'package:flutter/material.dart';
import 'package:detector/src/widgets/capture_notice.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Results extends StatefulWidget {
  final String imagePath;
  final PineappleClassifier classifier;
  final String result;
  final double confidence;

  const Results({
    super.key,
    required this.imagePath,
    required this.classifier,
    this.result = "Unknown",
    this.confidence = 0.0,
  });

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> with SingleTickerProviderStateMixin {
  late String result = 'Analyzing…';
  late double confidence = 0.0;
  bool isLoading = true;
  late AnimationController _animController;
  late Animation<double> _barAnim;

  // ── Design tokens ──────────────────────────────────────────────
  static const _bg = Color(0xFF0D1A12);
  static const _surface = Color(0xFF162119);
  static const _accent = Color.fromARGB(255, 69, 172, 17);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _divider = Color(0xFF1F3028);
  static const _warning = Color(0xFFFB923C);
  static const _warningDim = Color(0xFF2E1A0E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _runModel();
  }

  Future<void> _runModel() async {
    final thisResult = await widget.classifier.classifyPineapple(
      File(widget.imagePath),
    );
    if (mounted) {
      setState(() {
        result = thisResult['label'];
        confidence = thisResult['score'];
        isLoading = false;
      });
      _animController.forward();
    }
  }

  bool get _isDamaged => result == 'Mechanically Damaged';
  Color get _resultColor => _isDamaged ? _warning : _accent;

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
            // Subtle glow behind image
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: w,
                height: w * 0.7,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _resultColor.withOpacity(isLoading ? 0.04 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // ── App bar ───────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _divider),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: _cream,
                            size: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Analysis Result',
                        style: TextStyle(
                          color: _cream,
                          fontSize: (w * 0.045).clamp(15.0, 20.0),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // balance
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Image card ────────────────────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: (w * 0.75).clamp(200.0, 420.0),
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                                // Gradient scrim bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 90,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.65),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Result chip
                                if (!isLoading)
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: _ResultChip(
                                      label: result,
                                      color: _resultColor,
                                    ),
                                  ),
                                // Loading indicator on image
                                if (isLoading)
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: _LoadingChip(),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        // ── Score card ────────────────────────
                        if (!isLoading) ...[
                          _ConfidenceCard(
                            confidence: confidence,
                            isDamaged: _isDamaged,
                            barAnim: _barAnim,
                            resultColor: _resultColor,
                            w: w,
                          ),
                          SizedBox(height: 14),
                        ],

                        // ── Info card ─────────────────────────
                        if (!isLoading)
                          _InfoCard(
                            isDamaged: _isDamaged,
                            resultColor: _resultColor,
                            w: w,
                          ),

                        // Loading card placeholder
                        if (isLoading)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _divider),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Running AI analysis…',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: h * 0.03),

                        // ── Rescan button ─────────────────────
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _accent.withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: _bg,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Scan Another',
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

                        SizedBox(height: h * 0.04),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}

// ── Result chip ───────────────────────────────────────────────────
class _ResultChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ResultChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        // backdropFilter: null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading chip ──────────────────────────────────────────────────
class _LoadingChip extends StatelessWidget {
  static const _muted = Color(0xFF6B8F74);
  static const _surface = Color(0xFF162119);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(_muted),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ANALYZING',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confidence card ───────────────────────────────────────────────
class _ConfidenceCard extends StatelessWidget {
  final double confidence;
  final bool isDamaged;
  final Animation<double> barAnim;
  final Color resultColor;
  final double w;

  const _ConfidenceCard({
    required this.confidence,
    required this.isDamaged,
    required this.barAnim,
    required this.resultColor,
    required this.w,
  });

  static const _surface = Color(0xFF162119);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _divider = Color(0xFF1F3028);
  static const _accent = Color.fromARGB(255, 69, 172, 17);
  static const _warning = Color(0xFFFB923C);

  String get _confidenceLabel {
    final pct = (confidence * 100).toStringAsFixed(0);
    if (confidence < 0.4) return 'Healthy — $pct% damage probability';
    if (confidence > 0.6) return 'Damaged — $pct% confidence';
    return 'Uncertain — $pct% probability';
  }

  Color get _barColor {
    if (confidence < 0.4) return _accent;
    if (confidence > 0.6) return _warning;
    return const Color(0xFFFBBF24);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Score',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _barColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: _divider,
              child: AnimatedBuilder(
                animation: barAnim,
                builder: (context, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: confidence * barAnim.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _barColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            _confidenceLabel,
            style: TextStyle(color: _cream.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final bool isDamaged;
  final Color resultColor;
  final double w;

  const _InfoCard({
    required this.isDamaged,
    required this.resultColor,
    required this.w,
  });

  static const _surface = Color(0xFF162119);
  static const _cream = Color(0xFFF5F0E8);
  static const _muted = Color(0xFF6B8F74);
  static const _divider = Color(0xFF1F3028);

  List<Map<String, String>> get _tips =>
      isDamaged
          ? [
            {
              'icon': '⚠️',
              'title': 'Use immediately or reject',
              'sub': 'Quality degrades rapidly after mechanical damage.',
            },
            {
              'icon': '🔍',
              'title': 'Inspect carefully',
              'sub': 'Check for soft spots, cuts, or visible discoloration.',
            },
            {
              'icon': '📦',
              'title': 'Separate from batch',
              'sub': 'Prevent spread of damage to nearby fruits.',
            },
          ]
          : [
            {
              'icon': '✅',
              'title': 'Fresh and healthy',
              'sub': 'No visible mechanical damage detected.',
            },
            {
              'icon': '🗓️',
              'title': 'Store for 3–5 days',
              'sub': 'Refrigerate to extend shelf life.',
            },
            {
              'icon': '🍍',
              'title': 'Ideal for consumption',
              'sub': 'Best quality for direct use or sale.',
            },
          ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          ..._tips.asMap().entries.map((entry) {
            final i = entry.key;
            final tip = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tip['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title']!,
                            style: TextStyle(
                              color: _cream,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tip['sub']!,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (i < _tips.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: _divider),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
