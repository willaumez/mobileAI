import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Redirige vers la page de connexion et empêche le retour en arrière
            (route) => false,
      );
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      // Gérez l'erreur de déconnexion ici
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String userEmail = user != null ? user.email ?? 'Email non disponible' : 'Email non disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Logo similaire à celui de la page de connexion
                  const Icon(
                    Icons.person,
                    size: 150,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Email: $userEmail',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Ajoutez d'autres informations de l'utilisateur si nécessaire

                  const SizedBox(height: 20),

                  // Bouton pour déconnexion
                  ElevatedButton(
                    onPressed: () => signOut(context), // Appelle la méthode de déconnexion
                    child: const Text('Déconnexion'),
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
