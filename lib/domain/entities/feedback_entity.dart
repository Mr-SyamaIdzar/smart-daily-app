class FeedbackEntity {
  final int? id;
  final String kesan;
  final String pesan;
  final DateTime createdAt;

  const FeedbackEntity({
    this.id,
    required this.kesan,
    required this.pesan,
    required this.createdAt,
  });

  @override
  String toString() =>
      'FeedbackEntity(id: $id, kesan: $kesan, pesan: $pesan, createdAt: $createdAt)';
}
