import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_mobile/components/my_button.dart';
import 'package:projet_mobile/components/my_textfield.dart';

import '../main.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );

      // L'utilisateur est connecté avec succès
      User? user = userCredential.user;
      if (user != null) {
        // Naviguer vers la page suivante après la connexion réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } catch (e) {
      // Une erreur s'est produite lors de la connexion
      print('Erreur de connexion : $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur d\'authentification'),
            content: Text('Veuillez vérifier vos identifiants.'),
            actions: [
              Center( // Encapsulation dans un Center pour centrer le TextButton
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la boîte de dialogue
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Mes Activités',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        centerTitle: true, // Centre le titre dans la barre d'en-tête
        backgroundColor: Colors.grey[300],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 50),
                  // logo
                  const Icon(
                    Icons.person,
                    size: 100,
                  ),

                  // welcome back, you've been missed!
                  Text(
                    'Authentication',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // username textfield
                  MyTextField(
                    controller: usernameController,
                    hintText: 'login',
                    obscureText: false,
                  ),

                  const SizedBox(height: 25),

                  // password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: 'password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // sign in button
                  MyButton(
                    onTap: () => signInWithEmailAndPassword(context), // Appelle la méthode de connexion
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
