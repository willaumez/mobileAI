import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Activite.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String _selectedCategory = 'Toutes les activités';

  Widget _buildTableCell(String value) {
    return Container(
      child: Text(value),
    );
  }

  void afficherSnackBar(BuildContext context, String message) {
    if (context != null && ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }


  void supprimerActivite(BuildContext context, String activityId, String imageUrl) {
    if (context != null && mounted) {
      FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .delete()
          .then((_) {
        print('Élément supprimé avec succès');
        if (imageUrl != null &&
            imageUrl.isNotEmpty &&
            imageUrl !=
                'https://firebasestorage.googleapis.com/v0/b/activities-9f73f.appspot.com/o/images%2Ferror.png?alt=media&token=b7b09261-99a7-438f-b273-54446acf82ff') {
          Reference storageReference = FirebaseStorage.instance.refFromURL(imageUrl);
          storageReference.delete().then((_) {
            print('Élément supprimée avec succès');
            afficherSnackBar(context, 'Élément supprimée avec succès');
            Navigator.of(context).pop();
          }).catchError((error) {
            print('Erreur lors de la suppression de l\'image : $error');
          });
        } else {
          afficherSnackBar(context, 'Élément supprimé avec succès');
          Navigator.of(context).pop();
        }
      }).catchError((error) {
        print('Erreur lors de la suppression : $error');
        afficherSnackBar(context, 'Erreur lors de la suppression : $error');
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            items: [
              'Toutes les activités', // Option pour afficher toutes les catégories
              'Sport',
              'Fitness',
              'Shopping',
              'Autres',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('activities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des données'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null || data.docs.isEmpty) {
            return const Center(child: Text('Aucune activité trouvée'));
          }

          List<QueryDocumentSnapshot> filteredActivities = _selectedCategory == 'Toutes les activités'
              ? data.docs.toList() // Afficher toutes les activités si "Toutes" est sélectionné
              : data.docs.where((activity) => activity['categorie'] == _selectedCategory).toList();

          return ListView.builder(
            itemCount: filteredActivities.length,
            itemBuilder: (context, index) {
              final activity = filteredActivities[index];
              return GestureDetector(
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivitePage(
                      titre: activity['titre'],
                      imageUrl: activity['imageUrl'],
                      categorie: activity['categorie'],
                      description: activity['description'],
                      lieu: activity['lieu'],
                      Date: activity['Date'].toString(),
                      prix: activity['prix'].toString(),
                      nbmin: activity['nbmin'].toString(),
                      // Ajoutez d'autres attributs si nécessaire
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 100,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            imageUrl: activity['imageUrl'],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTableCell(activity['titre']),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                supprimerActivite(context, activity.id, activity['imageUrl']);
                                              },
                                              child: const Text('Confirmer'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildTableCell(activity['categorie']),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
    );
  }
}
