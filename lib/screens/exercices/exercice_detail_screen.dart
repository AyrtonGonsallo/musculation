import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
            const Text('Description et conseils :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              conseilsText,
              textAlign: TextAlign.left, // si tu veux le texte centré aussi
            ),

            const SizedBox(height: 16),

            // Bouton vidéo
            if (widget.exercice.lienVideo.isNotEmpty)
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

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _openEditExercicePopup,
                  child: const Text("Modifier l'exercice"),
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.brown), foregroundColor: WidgetStateProperty.all(Colors.white)),
                ),
              ],
            ),

          ],
        ),
      )
      ,
    );


  }


  void _openEditExercicePopup() {
    // Controllers
    final titreController = TextEditingController(text: widget.exercice.titre);
    final videoController = TextEditingController(text: widget.exercice.lienVideo);
    final conseilsController =
    TextEditingController(text: widget.exercice.conseils);

    // GIF local
    String gifLocalPath = widget.exercice.gif_local;

    Future<void> pickGif(StateSetter setStateDialog) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gif'],
      );

      if (result != null && result.files.single.path != null) {
        setStateDialog(() {
          gifLocalPath = result.files.single.path!;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Modifier l'exercice"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    TextFormField(
                      controller: titreController,
                      decoration: const InputDecoration(
                        labelText: "Titre",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lien vidéo
                    TextFormField(
                      controller: videoController,
                      decoration: const InputDecoration(
                        labelText: "Lien vidéo",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Conseils (TEXT AREA)
                    const Text("Conseils :"),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: conseilsController,
                      minLines: 5,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: "Conseils d'exécution...",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // GIF local
                    const Text("GIF local :"),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickGif(setStateDialog),
                          child: const Text("Sélectionner un GIF"),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            gifLocalPath.isNotEmpty
                                ? gifLocalPath.split('/').last
                                : 'Aucun GIF sélectionné',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Sauvegarde Hive
                    widget.exercice.titre = titreController.text;
                    widget.exercice.lienVideo = videoController.text;
                    widget.exercice.conseils = conseilsController.text;
                    widget.exercice.gif_local = gifLocalPath;

                    widget.exercice.save();
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text("Sauvegarder"),
                ),
              ],
            );
          },
        );
      },
    );
  }





}
