import 'dart:io';
import 'dart:typed_data';
import 'package:detector/src/classifier/quality_classifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

import 'package:detector/src/widgets/capture_notice.dart';

class Results extends StatefulWidget {
  final String imagePath;
  final String result;
  final double confidence;

  const Results({
    super.key,
    required this.imagePath,
    this.result = "Unknown",
    this.confidence = 0.0,
  });

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  late String result = 'Analyzing...';
  late double confidence = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _runModel();
  }

  Future<void> _runModel() async {
    final thisResult = await classifyPineapple(File(widget.imagePath), 'mobileNet');
    setState(() {
      result = thisResult['label'];
      confidence = thisResult['score'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color healthyColor = Colors.green[700]!;
    final Color damagedColor = Colors.orange[700]!;
    
    // Dynamic colors based on confidence
    final Color resultColor = result == "Healthy" ? healthyColor : damagedColor;
    final Color confidenceColor = confidence < 0.5 
        ? damagedColor.withOpacity(0.7)
        : healthyColor.withOpacity(0.7);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quality Analysis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green[800],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
          children: [
            // Image + Tag
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Analysis Card
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ANALYSIS REPORT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      isLoading
                          ? const LinearProgressIndicator(
                              color: Colors.green,
                            )
                          : Text(
                              "Pineapple is $result",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: result == 'Healthy'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                      const SizedBox(height: 16),
                      
                      // Confidence Level Section
                      if (!isLoading) ...[
                        //  const Text(
                        //     "Prediction Confidence",
                        //     style: TextStyle(
                        //     fontSize: 16,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        Column(
                          children: [
                            // Labels
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(
                            //       "Mechanical Damage",
                            //       style: TextStyle(
                            //         color: damagedColor,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //     Text(
                            //       "Healthy",
                            //       style: TextStyle(
                            //         color: healthyColor,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 4),
                            
                            // Meter
                            Container(
                              height: 30,
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[200],
                              ),
                              child: LayoutBuilder(builder: (context, constraints){
                                return Stack(
                                children: [
                                  // Background
                                  Positioned.fill(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 50,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: damagedColor.withOpacity(0.1),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                bottomLeft: Radius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 50,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: healthyColor.withOpacity(0.1),
                                              borderRadius: const BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                bottomRight: Radius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Indicator
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    left: confidence*(constraints.maxWidth - 30),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: confidence < 0.4
                                            ? damagedColor
                                            : confidence > 0.6
                                                ? healthyColor
                                                : Colors.amber, // Amber for uncertain
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        confidence < 0.4
                                            ? Icons.warning_amber_outlined
                                            : confidence > 0.6
                                                ? Icons.check_outlined
                                                : Icons.help_outline,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                              })
                            ),
                            const SizedBox(height: 4),
                            
                            // Confidence Text
                            Text(
                              confidence == 0.5
                                  ? "Highly uncertain (50%)"
                                  : confidence < 0.4
                                      ? "Certainly Damaged (${(100-(confidence * 100)).toStringAsFixed(0)}%)"
                                      : confidence > 0.6
                                          ? "Certainly Healthy (${(confidence * 100).toStringAsFixed(0)}%)"
                                          : "More Likely (${(confidence * 100).toStringAsFixed(0)}%)",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: confidence < 0.4
                                    ? damagedColor
                                    : confidence > 0.6
                                        ? healthyColor
                                        : Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Quality Tips Section
                      if (!isLoading) ...[
                        const Text(
                          "Quality Tips:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result == "Mechanically Damaged"
                              ? "• This pineapple shows signs of damage\n"
                                "• Best used immediately\n"
                                "• Check for soft spots or discoloration"
                              : "• This pineapple is fresh and healthy\n"
                                "• Can be stored for 3-5 days\n"
                                "• Ideal for direct consumption",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text("RESCAN"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10)
          ],
          ),
        ),
      ),
    );
  }
}