/// A queued operation to sync with Firestore when online.
class SyncQueueItem {
  final String id;
  final SyncAction action;
  final String collection; // Firestore collection name
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.action,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      action: SyncAction.values.firstWhere((e) => e.name == json['action']),
      collection: json['collection'] as String,
      documentId: json['document_id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: _parseDate(json['created_at']),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'collection': collection,
      'document_id': documentId,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  SyncQueueItem incrementRetry() {
    return SyncQueueItem(
      id: id,
      action: action,
      collection: collection,
      documentId: documentId,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount + 1,
    );
  }
}

enum SyncAction {
  create,
  update,
  delete,
}
