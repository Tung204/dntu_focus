import 'package:flutter/services.dart';

/// Service quản lý tất cả permission checks và requests cho app
/// Centralize permission logic để dễ maintain và test
class PermissionService {
  static const MethodChannel _channel =
      MethodChannel('com.example.moji_todo/permissions');

  /// Check DND (Do Not Disturb) permission for Block Notifications feature
  /// 
  /// Returns true if app has permission to modify DND settings
  /// Returns false if permission not granted or on unsupported Android version
  Future<bool> checkDNDPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkDNDPermission');
      return result ?? false;
    } catch (e) {
      print('Error checking DND permission: $e');
      return false;
    }
  }

  /// Request DND permission by opening system settings
  /// 
  /// Opens Android's Notification Policy Access Settings screen
  /// User must manually grant permission there
  Future<void> requestDNDPermission() async {
    try {
      await _channel.invokeMethod('requestDNDPermission');
    } catch (e) {
      print('Error requesting DND permission: $e');
    }
  }

  /// Check Accessibility Service status for Block Other Apps feature
  /// 
  /// Returns true if AppBlockService is enabled in Accessibility Settings
  /// Returns false if service is disabled
  Future<bool> checkAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAccessibilityPermissionEnabled',
      );
      return result ?? false;
    } catch (e) {
      print('Error checking Accessibility permission: $e');
      return false;
    }
  }

  /// Request Accessibility permission by opening system settings
  /// 
  /// Opens Android's Accessibility Settings screen
  /// User must manually enable AppBlockService there
  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      print('Error requesting Accessibility permission: $e');
    }
  }

  /// Check if app is ignoring battery optimizations
  /// 
  /// Required for reliable foreground service operation
  /// Returns true if app is whitelisted from battery optimization
  Future<bool> checkIgnoreBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'checkIgnoreBatteryOptimizations',
      );
      return result ?? false;
    } catch (e) {
      print('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to ignore battery optimizations
  /// 
  /// Opens system dialog asking user to whitelist the app
  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print('Error requesting ignore battery optimizations: $e');
    }
  }

  /// Refresh all permission states at once
  /// 
  /// Useful when app resumes from background after user grants permissions
  /// Returns map of permission name to status
  Future<Map<String, bool>> refreshAllPermissions() async {
    final dnd = await checkDNDPermission();
    final accessibility = await checkAccessibilityPermission();
    final battery = await checkIgnoreBatteryOptimizations();

    return {
      'dnd': dnd,
      'accessibility': accessibility,
      'battery': battery,
    };
  }
}