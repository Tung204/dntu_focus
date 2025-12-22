import 'package:cloud_firestore/cloud_firestore.dart';

class AITrainingLog {
  final String? id;
  final String? userId;
  final String? userMessage;
  final String? aiResponse;
  final String? commandType;
  final Map<String, dynamic>? commandResult;
  final bool? isHelpful;
  final DateTime? timestamp;
  final String? feedback;

  AITrainingLog({
    this.id,
    this.userId,
    this.userMessage,
    this.aiResponse,
    this.commandType,
    this.commandResult,
    this.isHelpful,
    this.timestamp,
    this.feedback,
  });

  factory AITrainingLog.fromJson(Map<String, dynamic> json, {String? docId}) {
    return AITrainingLog(
      id: docId ?? json['id'] as String?,
      userId: json['userId'] as String?,
      userMessage: json['userMessage'] as String?,
      aiResponse: json['aiResponse'] as String?,
      commandType: json['commandType'] as String?,
      commandResult: json['commandResult'] as Map<String, dynamic>?,
      isHelpful: json['isHelpful'] as bool?,
      timestamp: json['timestamp'] != null ? (json['timestamp'] as Timestamp).toDate() : null,
      feedback: json['feedback'] as String?,
    );
  }

  static AITrainingLog fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document does not exist');
    }
    return AITrainingLog.fromJson(data as Map<String, dynamic>, docId: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'commandType': commandType,
      'commandResult': commandResult,
      'isHelpful': isHelpful,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'feedback': feedback,
    };
  }
}