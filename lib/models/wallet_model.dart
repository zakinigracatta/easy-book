enum TransactionType { credit, debit }

class WalletTransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;

  WalletTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Transaction',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] == 'debit'
          ? TransactionType.debit
          : TransactionType.credit,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
