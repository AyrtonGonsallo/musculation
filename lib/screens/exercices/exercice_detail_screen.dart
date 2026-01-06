import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/exercice.dart';


class ExerciceDetailScreen extends StatefulWidget {
  final Exercice exercice;

  const ExerciceDetailScreen({super.key, required this.exercice});

  @override
  State<ExerciceDetailScreen> createState() => _ExerciceDetailScreenState();
}

class _ExerciceDetailScreenState extends State<ExerciceDetailScreen> {
  bool showVideo = false;



  // Pour YouTube
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _toggleVideo() {
    if (!showVideo) {
      if (widget.exercice.lienVideo.contains('youtube.com') ||
          widget.exercice.lienVideo.contains('youtu.be')) {
        final videoId = YoutubePlayer.convertUrlToId(widget.exercice.lienVideo);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: true),
          );
        }
      }
      setState(() {
        showVideo = true;
      });
    } else {
      setState(() {
        showVideo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conseilsText = widget.exercice.conseils;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercice.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GIF
            if (widget.exercice.gif.isNotEmpty)
              Image.network(widget.exercice.gif, height: 200, fit: BoxFit.cover),

            const SizedBox(height: 16),

            // Conseils
            const Text('Conseils:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(conseilsText),

            const SizedBox(height: 16),

            // Bouton vidéo
            ElevatedButton(
              onPressed: _toggleVideo,
              child: Text(showVideo ? 'Masquer la vidéo' : 'Voir la vidéo'),
            ),

            const SizedBox(height: 16),

            // Player vidéo
            if (showVideo)
              if (_youtubeController != null)
                YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                )

          ],
        ),
      ),
    );
  }
}
