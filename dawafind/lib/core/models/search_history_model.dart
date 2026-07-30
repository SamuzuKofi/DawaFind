import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SearchHistoryModel extends Equatable {
  const SearchHistoryModel({
    required this.id,
    required this.queryText,
    required this.searchedAt,
  });

  final String id;
  final String queryText;
  final DateTime searchedAt;

  factory SearchHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final searchedAt = data['searchedAt'];
    return SearchHistoryModel(
      id: doc.id,
      queryText: data['queryText'] as String? ?? '',
      searchedAt: searchedAt is Timestamp
          ? searchedAt.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'queryText': queryText,
    'searchedAt': Timestamp.fromDate(searchedAt),
  };

  @override
  List<Object?> get props => [id, queryText, searchedAt];
}
