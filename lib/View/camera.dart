import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  String camera1Url = 'http://YOUR_ESP32_IP_ADDRESS/stream';
  String camera2Url = 'http://YOUR_ESP32_IP_ADDRESS/stream';
  String selectedCamera = 'Camera 1'; // Default selection

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(camera1Url); // Initialize with Camera 1 URL by default
  }

  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.network(videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.black,
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Remove the title from app bar
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the AppBar shadow
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[800]!, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: -50,
            right: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: selectedCamera,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCamera = newValue!;
                      if (selectedCamera == 'Camera 1') {
                        _initializeVideoPlayer(camera1Url);
                      } else if (selectedCamera == 'Camera 2') {
                        _initializeVideoPlayer(camera2Url);
                      }
                    });
                  },
                  items: <String>['Camera 1', 'Camera 2'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.blueGrey[800]!, // Adjusted text color
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.tealAccent, // Dropdown background color
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _chewieController != null &&
                        _chewieController.videoPlayerController.value.isInitialized
                        ? Chewie(
                      controller: _chewieController,
                    )
                        : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
