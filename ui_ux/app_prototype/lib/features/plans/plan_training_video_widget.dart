import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlanTrainingVideoWidget extends StatefulWidget {
  final String assetPath;

  // Der Key sorgt dafür, dass das Widget merkt, wenn sich die Exercise ändert!
  const PlanTrainingVideoWidget({required this.assetPath, super.key});

  @override
  State<PlanTrainingVideoWidget> createState() => _PlanTrainingVideoWidgetState();
}

class _PlanTrainingVideoWidgetState extends State<PlanTrainingVideoWidget> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  // Falls sich die Exercise auf derselben Seite ändert (z.B. Nächste Übung),
  // müssen wir das alte Video stoppen und das neue laden.
  @override
  void didUpdateWidget(covariant PlanTrainingVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _controller?.dispose();
      _initVideo();
    }
  }

  void _initVideo() {
    _controller = VideoPlayerController.asset(widget.assetPath);
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      _controller!.setLooping(true);
      setState(() {});
    }).catchError((error) {
      print("Video-Fehler: $error");
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeVideoPlayerFuture == null) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () {
              // Hier steuern wir das Abspielen per Klick auf das Video
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            },
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Der eigentliche Video-Player
                  VideoPlayer(_controller!),

                  // Zeige ein Play-Icon an, wenn das Video pausiert ist
                  if (!_controller!.value.isPlaying)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                    ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}