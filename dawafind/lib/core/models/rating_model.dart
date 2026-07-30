import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  const RatingModel({
    required this.userId,
    required this.score,
    required this.createdAt,
  });

  final String userId;
  final double score;
  final DateTime createdAt;

  factory RatingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'];
    return RatingModel(
      userId: doc.id,
      score: (data['score'] as num?)?.toDouble() ?? 0,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'score': score,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [userId, score, createdAt];
}
