import 'package:firebase_auth/firebase_auth.dart';
import 'package:trabalho_hamburguerias/auth.dart';
import 'package:trabalho_hamburguerias/pages/details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isFormVisible = false;
  String? _editingHamburgueriaId;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _addOrUpdateHamburger() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final address = _addressController.text.trim();
    final number = _numberController.text.trim();
    final price = _priceController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty && address.isNotEmpty && number.isNotEmpty && price.isNotEmpty) {
      try {
        final existingHamburgueria = await _firestore
            .collection('hamburguerias')
            .where('name', isEqualTo: name)
            .get();

        if (existingHamburgueria.docs.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Registro não único'),
                content: const Text('Altere o nome da sua hamburgueria por algo mais original'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        if (_editingHamburgueriaId == null) {
          await _firestore.collection('hamburguerias').add({
            'name': name,
            'description': description,
            'address': address,
            'number': number,
            'price': int.parse(price),
            'ratings': [],
            'comments': [],
            'owner': user?.email,
          });
        } else {
          await _firestore.collection('hamburguerias').doc(_editingHamburgueriaId).update({
            'name': name,
            'description': description,
            'address': address,
            'number': number,
            'price': int.parse(price),
          });
          _editingHamburgueriaId = null;
        }

        _nameController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _numberController.clear();
        _priceController.clear();
        setState(() {
          _isFormVisible = false;
        });
      } catch (e) {
        print('Error adding/updating hamburger: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Informação incompleta'),
            content: const Text('Favor completar todos os campos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _setEditingHamburgueria(Map<String, dynamic> data, String id) {
    _nameController.text = data['name'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _addressController.text = data['address'] ?? '';
    _numberController.text = data['number'] ?? '';
    _priceController.text = data['price'].toString() ?? '';
    _editingHamburgueriaId = id;
    setState(() {
      _isFormVisible = true;
    });
  }

  double _calculateAverageRating(List<dynamic> ratings) {
  if (ratings.isEmpty) {
    return 0.0;
  }
  double total = 0.0;
  int count = 0;
  for (var rating in ratings) {
    if (rating is num) {
      total += rating;
      count++;
    }
  }
  return count > 0 ? total / count : 0.0;
}


  Widget _title() {
    return const Text('Hamburguerias BelHell');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  void _toggleFormVisibility() {
    setState(() {
      _isFormVisible = !_isFormVisible;
      if (!_isFormVisible) {
        _editingHamburgueriaId = null;
        _nameController.clear();
        _descriptionController.clear();
        _addressController.clear();
        _numberController.clear();
        _priceController.clear();
      }
    });
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
            _signOutButton(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleFormVisibility,
              child: Text(_isFormVisible ? 'Hide Form' : 'Show Form'),
            ),
            SizedBox(height: 20),
            if (_isFormVisible) _buildAddHamburgerForm(),
            SizedBox(height: 20),
            Expanded(child: _buildHamburgersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAddHamburgerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_editingHamburgueriaId == null ? 'Registre uma hamburgueria:' : 'Edite sua hamburgueria:', style: TextStyle(fontSize: 18)),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nome da sua hamburgueria',
          ),
        ),
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Descreva sua hamburgueria',
          ),
        ),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Endereço da sua hamburgueria',
          ),
        ),
        TextField(
          controller: _numberController,
          decoration: InputDecoration(
            labelText: 'Telefone da sua hamburgueria',
          ),
        ),
        TextField(
          controller: _priceController,
          decoration: InputDecoration(
            labelText: 'Preço médio da sua hamburgueria',
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addOrUpdateHamburger,
          child: Text(_editingHamburgueriaId == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
  String _getAverageRating(List<dynamic> ratings) {
    if (ratings.isEmpty) return 'Sem avaliações no momento';
    double totalRating = 0.0;
    for (var rating in ratings) {
      totalRating += rating['rating'];
    }
    double averageRating = totalRating / ratings.length;
    return averageRating.toStringAsFixed(2);
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
          final owner = data['owner'] ?? 'No owner';

          final averageRating = _getAverageRating(ratings);

          return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
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
                            currEmail: user?.email ?? ''
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$name (Rating: $averageRating)'),
                        Text(price.toString()),
                      ],
                    ),
                  ),
                ),
                if (owner == user?.email)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _setEditingHamburgueria(data, doc.id);
                    },
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

}
