import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import '../components/tlite_model_ai.dart';
import '../main.dart';

class AjouterPage extends StatelessWidget {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  final TextEditingController lieuController = TextEditingController();
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nbminController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  TfliteModel tfliteModel = TfliteModel();
  File? imageSave;


  Future<String?> uploadImageToFirebase(File? imageFile) async {
    if (imageFile != null) {
      String imageName = 'image_${Random().nextInt(10000)}.jpg';
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(imageName);
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } else {
      return null;
    }
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    final File image=File(pickedFile!.path);
    await tfliteModel.loadModel();
    String? category = await tfliteModel.getCategoryFromImage(image);
    print("category:   $category");
    if (category != null) {
      categorieController.text = category;
    } else {
      // Gérer le cas où la catégorie n'a pas pu être prédite
      categorieController.text = "Autres";
    }
    imageSave = image;
  }



  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        dateTimeController.text = selectedDateTime.toString();
      }
    }
  }

  Future<void> ajouterActivite(BuildContext context) async {

    if (dateTimeController.text.isNotEmpty &&
        categorieController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        lieuController.text.isNotEmpty &&
        prixController.text.isNotEmpty &&
        nbminController.text.isNotEmpty &&
        titreController.text.isNotEmpty) {

      ProgressDialog progressDialog = ProgressDialog(context);
      progressDialog.style(message: 'Chargement...');

      progressDialog.show();

      String? imageUrl = await uploadImageToFirebase(imageSave);
      if (imageUrl != null) {
        imageUrlController.text = imageUrl;
      } else {
        imageUrlController.text =
        "https://firebasestorage.googleapis.com/v0/b/activities-9f73f.appspot.com/o/images%2Ferror.png?alt=media&token=b7b09261-99a7-438f-b273-54446acf82ff";
      }


      FirebaseFirestore.instance.collection('activities').add({
        'Date': dateTimeController.text,
        'categorie': categorieController.text,
        'description': descriptionController.text,
        'lieu': lieuController.text,
        'titre': titreController.text,
        'prix': prixController.text,
        'nbmin': nbminController.text,
        'imageUrl': imageUrlController.text,
      }).then((_) {
        progressDialog.hide();
        verifierAjoutAvecSucces(context);
      }).catchError((error) {
        progressDialog.hide();
        gererErreurAjout(context, error);
      });
    } else {
      afficherSnackBar(context, 'Tous les champs sont requis');
    }
  }


  void verifierAjoutAvecSucces(BuildContext context) {
    FirebaseFirestore.instance.collection('activities').get().then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        reinitialiserChamps();
        naviguerVersPage(context);
        afficherSnackBar(context, 'Activité ajoutée avec succès');
      } else {
        afficherSnackBar(context, 'Erreur lors de l\'ajout');
      }
    });
  }

  void reinitialiserChamps() {
    dateTimeController.clear();
    categorieController.clear();
    descriptionController.clear();
    lieuController.clear();
    titreController.clear();
    prixController.clear();
    nbminController.clear();
    imageUrlController.clear();
    imageSave = null;
  }

  void naviguerVersPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  void afficherSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void gererErreurAjout(BuildContext context, dynamic error) {
    print('Erreur lors de l\'ajout : $error');
    afficherSnackBar(context, 'Erreur lors de l\'ajout');
  }

  @override
  Widget build(BuildContext context) {
    reinitialiserChamps();
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.grey,
          ),
          child: const Text('Ajouter une activité',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'activité',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: categorieController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Met la valeur en gras
                ),
              ),

              TextField(
                controller: prixController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix',
                ),
              ),
              TextField(
                controller: nbminController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre minimum de personne',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: dateTimeController,
                decoration: const InputDecoration(
                  labelText: 'Date et heure',
                ),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ajouterActivite(context);
                },
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Image",
        child: const Icon(Icons.image),
      ),
    );
  }


}
