import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/design_tokens.dart';
import '../../domain/home_cubit.dart';
import '../../domain/home_state.dart';

/// Strict Mode Dialog theo Figma Design
///
/// Hiển thị 5 tùy chọn Strict Mode:
/// 1. Block All Notifications
/// 2. Block Phone Calls (disabled - coming soon)
/// 3. Block Other Apps
/// 4. Lock Phone
/// 5. Prohibit to Exit
class StrictModeDialog extends StatefulWidget {
  const StrictModeDialog({super.key});

  /// Show bottom sheet helper method
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StrictModeDialog(),
    );
  }

  @override
  State<StrictModeDialog> createState() => _StrictModeDialogState();
}

class _StrictModeDialogState extends State<StrictModeDialog> {
  // Local state for switches (temporary until user clicks OK)
  late bool _blockNotifications;
  late bool _blockPhoneCalls;
  late bool _blockOtherApps;
  late bool _lockPhone;
  late bool _prohibitExit;

  @override
  void initState() {
    super.initState();
    // Initialize with current state from HomeCubit
    final currentState = context.read<HomeCubit>().state;
    _blockNotifications = currentState.isBlockNotificationsEnabled;
    _blockPhoneCalls = currentState.isBlockPhoneCallsEnabled;
    _blockOtherApps = currentState.isAppBlockingEnabled;
    _lockPhone = currentState.isLockPhoneEnabled;
    _prohibitExit = currentState.isExitBlockingEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, currentState) {
        return Container(
          decoration: const BoxDecoration(
            color: FigmaColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Text(
                  'Strict Mode',
                  style: FigmaTextStyles.h4.copyWith(
                    color: FigmaColors.textPrimary,
                  ),
                ),
              ),
              
              // Divider
              const Divider(height: 1),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Block Notifications - REQUIRES PERMISSION
                      _buildSwitchTile(
                        title: 'Block Notifications',
                        value: _blockNotifications,
                        onChanged: (value) => _handleToggle(
                          newValue: value,
                          feature: StrictModeFeature.blockNotifications,
                          onSuccess: (v) => setState(() => _blockNotifications = v),
                        ),
                        subtitle: currentState.hasDNDPermission
                            ? 'Disable all notifications while focusing'
                            : 'Requires Do Not Disturb permission',
                        requiresPermission: true,
                        hasPermission: currentState.hasDNDPermission,
                      ),
                      
                      // Block Phone Calls - DISABLED
                      _buildSwitchTile(
                        title: 'Block Phone Calls',
                        value: _blockPhoneCalls,
                        onChanged: null, // Still disabled
                        subtitle: 'Feature under development',
                      ),
                      
                      // Block Other Apps - REQUIRES PERMISSION
                      _buildSwitchTile(
                        title: 'Block Other Apps',
                        value: _blockOtherApps,
                        onChanged: (value) => _handleToggle(
                          newValue: value,
                          feature: StrictModeFeature.blockOtherApps,
                          onSuccess: (v) => setState(() => _blockOtherApps = v),
                        ),
                        subtitle: currentState.hasAccessibilityPermission
                            ? 'Prevent opening distracting apps'
                            : 'Requires Accessibility Service',
                        requiresPermission: true,
                        hasPermission: currentState.hasAccessibilityPermission,
                      ),
                      
                      // Lock Phone - NO PERMISSION NEEDED
                      _buildSwitchTile(
                        title: 'Keep Screen On',
                        value: _lockPhone,
                        onChanged: (value) => setState(() => _lockPhone = value),
                        subtitle: 'Screen stays on while focusing',
                      ),
                      
                      // Prohibit Exit - NO PERMISSION NEEDED
                      _buildSwitchTile(
                        title: 'Prohibit Exit',
                        value: _prohibitExit,
                        onChanged: (value) => setState(() => _prohibitExit = value),
                        subtitle: 'Cannot exit app while focusing',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Divider
              const Divider(height: 1),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: FigmaTextStyles.labelMedium.copyWith(
                            color: FigmaColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // OK Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FigmaColors.primary,
                          foregroundColor: FigmaColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: FigmaTextStyles.labelMedium.copyWith(
                            color: FigmaColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual switch tile
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? subtitle,
    bool requiresPermission = false,
    bool hasPermission = true,
  }) {
    final isEnabled = onChanged != null;
    final showWarning = requiresPermission && !hasPermission;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: FigmaTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                              isEnabled
                                  ? FigmaColors.textPrimary
                                  : FigmaColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showWarning) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: FigmaColors.warning,
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: FigmaTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      height: 1.3,
                      color: showWarning
                          ? FigmaColors.warning
                          : FigmaColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Custom Switch
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: FigmaColors.primary,
              activeTrackColor: FigmaColors.primary.withOpacity(0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle toggle với permission check
  Future<void> _handleToggle({
    required bool newValue,
    required StrictModeFeature feature,
    required ValueChanged<bool> onSuccess,
  }) async {
    if (!newValue) {
      // Turning OFF - không cần permission
      onSuccess(newValue);
      return;
    }
    
    // Turning ON - kiểm tra permission trước (KHÔNG request ngay)
    final homeCubit = context.read<HomeCubit>();
    final hasPermission = homeCubit.checkPermissionOnly(feature);
    
    if (!hasPermission && mounted) {
      // Chưa có permission → Hiện dialog yêu cầu
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => _PermissionRequestDialog(
          featureName: _getFeatureName(feature),
          permissionName: _getPermissionName(feature),
          onGrantPermission: () => Navigator.of(context).pop(true),
          onCancel: () => Navigator.of(context).pop(false),
        ),
      );
      
      if (shouldRequest == true && mounted) {
        // User muốn cấp quyền → BÂY GIỜ MỚI gọi request
        await homeCubit.checkAndRequestPermissionFor(feature);
        
        // Hiện thông báo hướng dẫn
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please grant permission in settings, then return and try again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: FigmaColors.warning,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
              ),
            ),
          );
        }
      }
      return; // KHÔNG toggle switch
    }
    
    // Có permission → Cho phép toggle
    onSuccess(newValue);
  }

  /// Lấy tên tính năng để hiển thị
  String _getFeatureName(StrictModeFeature feature) {
    switch (feature) {
      case StrictModeFeature.blockNotifications:
        return 'Block Notifications';
      case StrictModeFeature.blockOtherApps:
        return 'Block Other Apps';
      case StrictModeFeature.blockPhoneCalls:
        return 'Block Phone Calls';
      case StrictModeFeature.lockPhone:
        return 'Keep Screen On';
      case StrictModeFeature.prohibitExit:
        return 'Prohibit Exit';
    }
  }

  /// Lấy tên permission để hiển thị
  String _getPermissionName(StrictModeFeature feature) {
    switch (feature) {
      case StrictModeFeature.blockNotifications:
        return 'Do Not Disturb';
      case StrictModeFeature.blockOtherApps:
        return 'Accessibility Service';
      default:
        return 'Unknown';
    }
  }

  /// Handle save button - update HomeCubit state
  void _handleSave() {
    final homeCubit = context.read<HomeCubit>();

    // Check if timer is running
    if (homeCubit.state.isTimerRunning && !homeCubit.state.isPaused) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Cannot change Strict Mode while timer is running',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: FigmaColors.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
          ),
        ),
      );
      return;
    }

    // Update Strict Mode settings
    homeCubit.updateStrictMode(
      isBlockNotificationsEnabled: _blockNotifications,
      isBlockPhoneCallsEnabled: _blockPhoneCalls,
      isAppBlockingEnabled: _blockOtherApps,
      isLockPhoneEnabled: _lockPhone,
      isExitBlockingEnabled: _prohibitExit,
    );

    // Close dialog
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAnyStrictModeEnabled()
              ? 'Strict Mode enabled'
              : 'Strict Mode disabled',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FigmaColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
      ),
    );
  }

  /// Check if any strict mode option is enabled
  bool _isAnyStrictModeEnabled() {
    return _blockNotifications ||
        _blockPhoneCalls ||
        _blockOtherApps ||
        _lockPhone ||
        _prohibitExit;
  }
}

/// Dialog yêu cầu người dùng cấp quyền
class _PermissionRequestDialog extends StatelessWidget {
  final String featureName;
  final String permissionName;
  final VoidCallback onGrantPermission;
  final VoidCallback onCancel;

  const _PermissionRequestDialog({
    required this.featureName,
    required this.permissionName,
    required this.onGrantPermission,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusLg),
      ),
      backgroundColor: FigmaColors.white,
      title: Row(
        children: [
          Icon(Icons.security, color: FigmaColors.warning, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Permission Required',
              style: FigmaTextStyles.h4.copyWith(
                color: FigmaColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'To use "$featureName" feature, you need to grant "$permissionName" permission to the app.\n\nDo you want to open settings to grant permission?',
        style: FigmaTextStyles.bodyMedium.copyWith(
          fontSize: 14,
          color: FigmaColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: FigmaTextStyles.labelMedium.copyWith(
              color: FigmaColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onGrantPermission,
          style: ElevatedButton.styleFrom(
            backgroundColor: FigmaColors.primary,
            foregroundColor: FigmaColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
            ),
          ),
          child: Text(
            'Open Settings',
            style: FigmaTextStyles.labelMedium.copyWith(
              color: FigmaColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
