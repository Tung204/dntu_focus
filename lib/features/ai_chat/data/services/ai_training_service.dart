import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_training_log_model.dart';
import '../../../core/services/firebase_service.dart';

class AITrainingService {
  final FirebaseService _firebaseService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AITrainingService(this._firebaseService);

  // Lưu log tương tác AI vào Firestore
  Future<void> logInteraction({
    required String userMessage,
    required String aiResponse,
    required String commandType,
    Map<String, dynamic>? commandResult,
    bool? isHelpful,
    String? feedback,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not logged in, skipping AI training log');
        return;
      }

      final log = AITrainingLog(
        userId: userId,
        userMessage: userMessage,
        aiResponse: aiResponse,
        commandType: commandType,
        commandResult: commandResult,
        isHelpful: isHelpful,
        timestamp: DateTime.now(),
        feedback: feedback,
      );

      final collection = _firebaseService.getUserSubCollection(userId!, 'ai_training_logs');
      await collection.add(log.toJson());
      print('AI training log saved successfully');
    } catch (e) {
      print('Error saving AI training log: $e');
    }
  }

  // Cập nhật đánh giá của người dùng cho log
  Future<void> updateFeedback({
    required String logId,
    required bool isHelpful,
    String? feedback,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('User not logged in, skipping feedback update');
        return;
      }

      final collection = _firebaseService.getUserSubCollection(userId!, 'ai_training_logs');
      await collection.doc(logId).update({
        'isHelpful': isHelpful,
        'feedback': feedback,
      });
      print('AI training feedback updated successfully');
    } catch (e) {
      print('Error updating AI training feedback: $e');
    }
  }

  // Lấy danh sách logs của người dùng hiện tại
  Future<List<AITrainingLog>> getUserLogs({int limit = 50}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final collection = _firebaseService.getUserSubCollection(userId!, 'ai_training_logs');
      final snapshot = await collection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AITrainingLog.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting AI training logs: $e');
      return [];
    }
  }

  // Xóa log cũ để tiết kiệm không gian lưu trữ
  Future<void> cleanupOldLogs({int daysToKeep = 30}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final collection = _firebaseService.getUserSubCollection(userId!, 'ai_training_logs');
      
      final snapshot = await collection
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cleaned up ${snapshot.docs.length} old AI training logs');
    } catch (e) {
      print('Error cleaning up AI training logs: $e');
    }
  }
}