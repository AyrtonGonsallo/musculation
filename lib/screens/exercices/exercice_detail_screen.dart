import 'dart:io';

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
    final gifPath = widget.exercice.gif_local;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.exercice.titre),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Conseils
            Text(widget.exercice.titre,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            const SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(widget.exercice.section!.titre,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  Text(widget.exercice.partie!.titre,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                  ]

            ),

            const SizedBox(height: 8),
            // GIF centré
            if (gifPath.isNotEmpty)
              Center(
                child: Image.file(
                  File(gifPath),
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            // Conseils
            const Text('Conseils:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              conseilsText,
              textAlign: TextAlign.center, // si tu veux le texte centré aussi
            ),

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
                Center(
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.red,
                  ),
                ),
          ],
        ),
      )
      ,
    );
  }
}
