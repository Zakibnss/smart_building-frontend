import 'package:flutter/material.dart';
import 'package:smart_residence/models/user.dart';

class ReclamationFeedbackScreen extends StatefulWidget {
  final User user;
  final int reclamationId;

  const ReclamationFeedbackScreen({
    Key? key,
    required this.user,
    required this.reclamationId,
  }) : super(key: key);

  @override
  _ReclamationFeedbackScreenState createState() => _ReclamationFeedbackScreenState();
}

class _ReclamationFeedbackScreenState extends State<ReclamationFeedbackScreen> {
  double _satisfactionRating = 3;
  final TextEditingController _commentController = TextEditingController();

  final Color _bleuFonce = Color(0xFF0D1F3C);
  final Color _vertMoyen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _bleuFonce),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ÉVALUER LA RÉSOLUTION',
          style: TextStyle(
            color: _bleuFonce,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Message de remerciement
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _vertMoyen,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Votre réclamation a été résolue !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _bleuFonce,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nous espérons que le service vous a satisfait. Votre avis nous aide à nous améliorer.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Évaluation par étoiles
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Votre satisfaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _bleuFonce,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _satisfactionRating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _satisfactionRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getSatisfactionText(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _bleuFonce,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Commentaire
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commentaire (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _bleuFonce,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Partagez votre expérience...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _vertMoyen),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Bouton d'envoi
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vertMoyen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'ENVOYER MON AVIS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSatisfactionText() {
    switch (_satisfactionRating.round()) {
      case 1:
        return 'Très insatisfait';
      case 2:
        return 'Insatisfait';
      case 3:
        return 'Satisfait';
      case 4:
        return 'Très satisfait';
      case 5:
        return 'Excellent';
      default:
        return 'Satisfait';
    }
  }

  void _submitFeedback() {
    // Ici, appel API pour soumettre le feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Icon(
          Icons.thumb_up,
          color: _vertMoyen,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Merci !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _bleuFonce,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Votre avis a bien été enregistré.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'FERMER',
              style: TextStyle(color: _vertMoyen),
            ),
          ),
        ],
      ),
    );
  }
}