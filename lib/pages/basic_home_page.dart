import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabalho_hamburguerias/auth.dart';
import 'package:trabalho_hamburguerias/pages/details_page.dart';
import 'package:trabalho_hamburguerias/pages/login_register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BasicHomePage extends StatefulWidget {
  const BasicHomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<BasicHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Hamburguerias BelHell');
  }

  Widget _userUid() {
    return Text("Usuario Anonimo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _userUid(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Expanded(child: _buildHamburgersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHamburgersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('hamburguerias').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hamburguerias found.'));
        }

        final documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'No name';
            final description = data['description'] ?? 'No description';
            final price = data['price'] ?? 'No price';
            final ratings = data['ratings'] ?? [];
            final comments = data['comments'] ?? [];
            final number = data['number'] ?? 'No number';
            final address = data['address'] ?? 'No address';
    

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HamburgerDetailsPage(
                        name: name,
                        description: description,
                        price: price.toString(),
                        ratings: ratings,
                        number: number,
                        address: address,
                        comments: comments,
                        docId: doc.id,
                        currEmail: ""
                    ),
                  ),
                );
              },
              child: ListTile(
                title: Text(name),
                subtitle: Text(price.toString()),
              ),
            );
          },
        );
      },
    );
  }
}
