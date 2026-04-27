import 'package:camera/camera.dart';
import 'package:detector/src/classifier/quality_classifier.dart';
import 'package:flutter/material.dart';
import 'package:detector/src/screens/result.dart';

class Capture extends StatefulWidget {
  final List<CameraDescription> cameras;
  final PineappleClassifier classifier;
  const Capture({super.key, required this.cameras, required this.classifier});

  @override
  State<Capture> createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFrontCamera = false;
  bool _isCapturing = false;
  bool _flashOn = false;
  final _flashActive = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(widget.cameras[0]);
  }

  Future<void> _initializeCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _toggleCamera() async {
    if (widget.cameras.length < 2) return;
    setState(() => _isFrontCamera = !_isFrontCamera);
    await _controller.dispose();
    _initializeCamera(_isFrontCamera ? widget.cameras[1] : widget.cameras[0]);
  }

  Future<void> _toggleFlash() async {
    setState(() => _flashOn = !_flashOn);
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      if (_flashOn) {
        await _controller.setFlashMode(FlashMode.torch);
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        await _controller.setFlashMode(FlashMode.off);
      }

      final XFile photo = await _controller.takePicture();
      await _controller.setFlashMode(FlashMode.off);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  Results(imagePath: photo.path, classifier: widget.classifier),
        ),
      );
    } catch (e) {
      debugPrint("Error capturing photo: $e");
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller.setFlashMode(FlashMode.off);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;

    // Responsive values
    final captureButtonSize = (screenWidth * 0.175).clamp(60.0, 90.0);
    final captureButtonBorder = (captureButtonSize * 0.08).clamp(3.0, 5.0);
    final captureButtonInnerPadding = (captureButtonSize * 0.06).clamp(
      3.0,
      6.0,
    );
    final instructionFontSize = (screenWidth * 0.04).clamp(13.0, 18.0);
    final bottomPadding = (screenHeight * 0.05).clamp(24.0, 60.0);
    final switchIconSize = (screenWidth * 0.07).clamp(24.0, 36.0);
    final appBarIconSize = (screenWidth * 0.065).clamp(22.0, 32.0);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: appBarIconSize,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: _flashActive ? Colors.amber : Colors.white,
                size: appBarIconSize,
              ),
              onPressed: _toggleFlash,
            ),
          ],
        ),
        body: FutureBuilder(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final double cameraAspectRatio = _controller.value.aspectRatio;
              final double scale =
                  cameraAspectRatio < 1.0
                      ? 1.0 / cameraAspectRatio
                      : cameraAspectRatio;

              return Stack(
                children: [
                  // Square camera preview
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRect(
                        child: Transform.scale(
                          scale: scale,
                          child: Center(child: CameraPreview(_controller)),
                        ),
                      ),
                    ),
                  ),

                  // Bottom controls
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Camera switch toggle
                        if (widget.cameras.length > 1)
                          IconButton(
                            icon: Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                              size: switchIconSize,
                            ),
                            onPressed: _toggleCamera,
                          ),

                        // Capture button
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: captureButtonSize,
                            height: captureButtonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: captureButtonBorder,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                captureButtonInnerPadding,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _isCapturing
                                          ? Colors.white.withOpacity(0.5)
                                          : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Instruction text
                        Padding(
                          padding: EdgeInsets.only(
                            top: (screenHeight * 0.025).clamp(12.0, 28.0),
                          ),
                          child: Text(
                            'Center the pineapple in the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: instructionFontSize,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
