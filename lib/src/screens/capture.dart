import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:detector/src/screens/result.dart';

class Capture extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Capture({super.key, required this.cameras});

  @override
  State<Capture> createState() => _CaptureState();
}

class _CaptureState extends State<Capture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFrontCamera = false;
  bool _isCapturing = false;
  bool _flashOn = true;
  final _flashActive = true;

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
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  Future<void> _takePhoto() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      // 1. Only turn on flash if user toggled it
      if (_flashOn) {
        await _controller.setFlashMode(FlashMode.torch);
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        await _controller.setFlashMode(FlashMode.off);
      }

      // 2. Take the photo
      final XFile photo = await _controller.takePicture();

      // 3. Ensure flash is turned OFF immediately after
      await _controller.setFlashMode(FlashMode.off);

      if (!mounted) return;

      // 4. Navigate to result screen
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Results(imagePath: photo.path)),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Keeps the rest of the screen black
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: _flashActive ? Colors.amber : Colors.white,
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
                  // 1:1 Square Camera Preview
                  Center(
                    child: AspectRatio(
                      aspectRatio: 1.0, // Forces a 1:1 square
                      child: ClipRect(
                        // Cuts off the parts of the camera feed outside the square
                        child: Transform.scale(
                          scale:
                              scale, // Zooms the feed so it covers the square entirely
                          child: Center(child: CameraPreview(_controller)),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Controls
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Camera Toggle
                        if (widget.cameras.length > 1)
                          IconButton(
                            icon: const Icon(
                              Icons.cameraswitch,
                              color: Colors.white,
                            ),
                            onPressed: _toggleCamera,
                          ),

                        // Capture Button
                        GestureDetector(
                          onTap: _takePhoto,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
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

                        // Instruction Text
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'Center the pineapple in the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
