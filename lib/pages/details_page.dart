import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HamburgerDetailsPage extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final List ratings;
  final String number;
  final String address;
  final List comments;
  final String docId;
  final String currEmail;

  const HamburgerDetailsPage({
    required this.name,
    required this.description,
    required this.price,
    required this.ratings,
    required this.number,
    required this.address,
    required this.comments,
    required this.docId,
    required this.currEmail,
  });

  @override
  _HamburgerDetailsPageState createState() => _HamburgerDetailsPageState();
}

class _HamburgerDetailsPageState extends State<HamburgerDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addComment(String author, String message) async {
    if (message.isNotEmpty) {
      try {
        final updatedComments = List.from(widget.comments)
          ..add({'author': author, 'message': message});
        await _firestore.collection('hamburguerias').doc(widget.docId).update({
          'comments': updatedComments,
        });
        setState(() {
          widget.comments.add({'author': author, 'message': message});
          _commentController.clear();
        });
      } catch (e) {
        print('Error adding comment: $e');
      }
    }
  }

  Future<void> _updateRating(double rating) async {
    try {
      final updatedRatings = List.from(widget.ratings);
      final userRatingIndex = updatedRatings.indexWhere((rating) =>
          rating['author'] == widget.currEmail); // Find user's existing rating
      if (userRatingIndex != -1) {
        
        updatedRatings[userRatingIndex]['rating'] = rating;
      } else {
        
        updatedRatings.add({'author': widget.currEmail, 'rating': rating});
      }
      await _firestore.collection('hamburguerias').doc(widget.docId).update({
        'ratings': updatedRatings,
      });
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hamburgueria: ${widget.name}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Descricao: ${widget.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Display ratings
            Text(
              'Ratings: ${_getAverageRating()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Preco Medio: ${widget.price}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Telefone: ${widget.number}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Endereco: ${widget.address}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildCommentsSection()),
            SizedBox(height: 10),
            widget.currEmail.isNotEmpty ? _buildRatingInput() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments:',
          style: TextStyle(fontSize: 18),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              final comment = widget.comments[index];
              final author = comment['author'] ?? 'Anonymous';
              final message = comment['message'] ?? '';

              return ListTile(
                title: Text(author),
                subtitle: Text(message),
              );
            },
          ),
        ),
        widget.currEmail.isNotEmpty
            ? TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      final author = widget.currEmail; 
                      final message = _commentController.text.trim();
                      _addComment(author, message);
                    },
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget _buildRatingInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ratingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Your Rating',
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            final rating = double.tryParse(_ratingController.text) ?? 0.0;
            _updateRating(rating);
          },
        ),
      ],
    );
  }

  String _getAverageRating() {
    if (widget.ratings.isEmpty) return 'No ratings yet';
    double totalRating = 0.0;
    for (var rating in widget.ratings) {
      totalRating += rating['rating'];
    }
    double averageRating = totalRating / widget.ratings.length;
    return averageRating.toStringAsFixed(2);
  }
}
