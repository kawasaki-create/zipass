import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewManager {
  static const String _zipCountKey = 'zip_creation_count';
  static const String _lastReviewRequestKey = 'last_review_request';
  static const String _hasRequestedReviewKey = 'has_requested_review';
  
  static const int _firstReviewThreshold = 3;
  static const int _subsequentReviewThreshold = 10;
  static const int _daysBetweenRequests = 30;

  static Future<void> onZipCreated() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ZIP作成回数をインクリメント
    final currentCount = prefs.getInt(_zipCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_zipCountKey, newCount);
    
    // レビューリクエストの条件をチェック
    if (await _shouldRequestReview(prefs, newCount)) {
      await _requestReview(prefs);
    }
  }

  static Future<bool> _shouldRequestReview(SharedPreferences prefs, int zipCount) async {
    // 初回レビューリクエスト（3回目のZIP作成）
    final hasRequestedBefore = prefs.getBool(_hasRequestedReviewKey) ?? false;
    if (!hasRequestedBefore && zipCount >= _firstReviewThreshold) {
      return true;
    }
    
    // 2回目以降のレビューリクエスト（10回ごと）
    if (hasRequestedBefore && zipCount % _subsequentReviewThreshold == 0) {
      final lastRequestTime = prefs.getInt(_lastReviewRequestKey) ?? 0;
      final daysSinceLastRequest = 
          (DateTime.now().millisecondsSinceEpoch - lastRequestTime) / 
          (1000 * 60 * 60 * 24);
      
      if (daysSinceLastRequest >= _daysBetweenRequests) {
        return true;
      }
    }
    
    return false;
  }

  static Future<void> _requestReview(SharedPreferences prefs) async {
    final InAppReview inAppReview = InAppReview.instance;
    
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      
      // レビューリクエスト記録を更新
      await prefs.setBool(_hasRequestedReviewKey, true);
      await prefs.setInt(_lastReviewRequestKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  // デバッグ用: カウンターをリセット
  static Future<void> resetCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_zipCountKey);
    await prefs.remove(_lastReviewRequestKey);
    await prefs.remove(_hasRequestedReviewKey);
  }
  
  // デバッグ用: 現在の状態を取得
  static Future<Map<String, dynamic>> getDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'zipCount': prefs.getInt(_zipCountKey) ?? 0,
      'hasRequestedReview': prefs.getBool(_hasRequestedReviewKey) ?? false,
      'lastReviewRequest': prefs.getInt(_lastReviewRequestKey) ?? 0,
    };
  }
}