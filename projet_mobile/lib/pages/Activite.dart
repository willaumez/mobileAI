import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ActivitePage extends StatelessWidget {
  final String titre;
  final String categorie;
  final String imageUrl;
  final String description;
  final String lieu;
  final String prix;
  final String nbmin;
  final String Date;

  const ActivitePage({
    Key? key,
    required this.titre,
    required this.categorie,
    required this.imageUrl,
    required this.description,
    required this.lieu,
    required this.prix,
    required this.nbmin,
    required this.Date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'activité'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                margin: EdgeInsets.all(10.0),
                constraints: BoxConstraints(
                  minWidth: 100, // Largeur minimale du conteneur
                  minHeight: 500, // Hauteur minimale du conteneur
                  maxHeight: double.infinity, // Hauteur maximale automatique du conteneur
                ),
                decoration: BoxDecoration(
                  //color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),



            Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  buildDetailRow('Titre', titre),
                  Divider(), // Barre de séparation
                  buildDetailRow('Catégorie', categorie),
                  Divider(), // Barre de séparation
                  buildDetailRow('Nombre minimun', nbmin),
                  Divider(), // Barre de séparation
                  buildDetailRow('Description', description),
                  Divider(), // Barre de séparation
                  buildDetailRow('Prix ', prix + '    Dhs'),
                  Divider(), // Barre de séparation
                  buildDetailRow('Lieu', lieu),
                  Divider(), // Barre de séparation
                  buildDetailRow('Date', Date),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ActivitePage(
        titre: 'Titre de l\'activité',
        categorie: 'Catégorie de l\'activité',
        imageUrl: 'URL_de_votre_image',
        description: 'Description de l\'activité',
        lieu: 'Lieu de l\'activité',
        prix: 'Prix de l\'activité',
        nbmin: 'Nombre minimum',
        Date: 'Date de l\'activité',
      ),
    ),
  );
}
