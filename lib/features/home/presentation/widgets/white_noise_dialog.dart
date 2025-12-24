import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/home_cubit.dart';
import '../../../../core/themes/design_tokens.dart';

/// White Noise Dialog - Bottom Sheet
/// 
/// Hiển thị 9 tùy chọn White Noise:
/// 1. None
/// 2. Gentle Rain
/// 3. Water Stream
/// 4. Small Stream
/// 5. Bonfire
/// 6. Café Ambiance
/// 7. Clock Ticking
/// 8. Library
/// 9. Metronome
class WhiteNoiseDialog extends StatefulWidget {
  const WhiteNoiseDialog({super.key});

  /// Show bottom sheet helper method
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WhiteNoiseDialog(),
    );
  }

  @override
  State<WhiteNoiseDialog> createState() => _WhiteNoiseDialogState();
}

class _WhiteNoiseDialogState extends State<WhiteNoiseDialog> {
  String? selectedWhiteNoise; // null = None, or file name

  @override
  void initState() {
    super.initState();
    final homeState = context.read<HomeCubit>().state;
    selectedWhiteNoise = homeState.isWhiteNoiseEnabled 
        ? homeState.selectedWhiteNoise 
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : FigmaColors.white,
        borderRadius: const BorderRadius.only(
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
              'White Noise',
              style: FigmaTextStyles.h4.copyWith(
                color: isDark 
                    ? Theme.of(context).textTheme.titleLarge!.color
                    : FigmaColors.textPrimary,
              ),
            ),
          ),
          
          // Divider
          const Divider(height: 1),
          
          // Content - Scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Option: None
                  _buildWhiteNoiseOption(
                    context: context,
                    value: null,
                    title: 'None',
                    subtitle: 'Turn off white noise',
                    icon: Icons.close,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Gentle Rain
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'gentle-rain',
                    title: 'Gentle Rain',
                    subtitle: 'Soft rain sounds',
                    icon: Icons.water_drop,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Water Stream
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'water-stream',
                    title: 'Water Stream',
                    subtitle: 'Flowing water sounds',
                    icon: Icons.waves,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Small Stream
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'small-stream',
                    title: 'Small Stream',
                    subtitle: 'Babbling brook sounds',
                    icon: Icons.stream,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Bonfire
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'bonfire',
                    title: 'Bonfire',
                    subtitle: 'Crackling fire sounds',
                    icon: Icons.local_fire_department,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Café Ambiance
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'cafe',
                    title: 'Café Ambiance',
                    subtitle: 'Coffee shop atmosphere',
                    icon: Icons.coffee,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Clock Ticking
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'clock_ticking',
                    title: 'Clock Ticking',
                    subtitle: 'Steady clock sounds',
                    icon: Icons.schedule,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Library
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'library',
                    title: 'Library',
                    subtitle: 'Quiet library ambience',
                    icon: Icons.menu_book,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Option: Metronome
                  _buildWhiteNoiseOption(
                    context: context,
                    value: 'metronome',
                    title: 'Metronome',
                    subtitle: 'Steady metronome beats',
                    icon: Icons.music_note,
                    isDark: isDark,
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
  }

  /// Build individual white noise option
  Widget _buildWhiteNoiseOption({
    required BuildContext context,
    required String? value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = selectedWhiteNoise == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWhiteNoise = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? FigmaColors.primary.withOpacity(0.1)
              : (isDark ? const Color(0xFF2A2A2A) : FigmaColors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FigmaColors.primary
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? FigmaColors.primary.withOpacity(0.1)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? FigmaColors.primary
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: 12),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface
                          : FigmaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                          : FigmaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 24,
                color: FigmaColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// Handle save button
  void _handleSave() {
    final homeCubit = context.read<HomeCubit>();

    if (selectedWhiteNoise == null) {
      // Disable white noise
      homeCubit.toggleWhiteNoise(false);
    } else {
      // Enable white noise with selected sound
      homeCubit.toggleWhiteNoise(true);
      homeCubit.selectWhiteNoise(selectedWhiteNoise!);
    }

    // Close dialog
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedWhiteNoise == null
              ? 'White Noise disabled'
              : 'White Noise enabled',
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
}