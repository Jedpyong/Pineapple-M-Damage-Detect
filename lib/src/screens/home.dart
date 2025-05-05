import 'package:camera/camera.dart';
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

class _HomeState extends State<Home> {
  late CameraController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
            builder: (context) => Results(imagePath: image.path),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pineapple Quality Scanner',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
          )),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[800],
      ),
      body: Stack(
        children: [
          // Background with pineapple pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green[50]!,
                  Colors.green[100]!,
                ],
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // App Logo/Icon
                  Image.asset(
                    'assets/images/HowPine Logo.png',
                    height: screenWidth * 0.7,
                    width: screenWidth * 0.7,
                  ),
                  const SizedBox(height: 10),
                  
                  // Title
                  Text(
                    'Detect Pineapple Damage',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  Text(
                    'Capture or upload an image to analyze pineapple quality',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Camera Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => showDialog(
                                context: context,
                                builder: (context) => CaptureNotice(cameras: widget.cameras),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Scan with Camera',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Gallery Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _pickImage(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, color: Colors.green[700]),
                          const SizedBox(width: 10),
                          Text(
                            'Choose from Gallery',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}