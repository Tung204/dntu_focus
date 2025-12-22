import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatBubbleWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final VoidCallback? onTap;
  final bool showAnimation;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Màu sắc cho bubble
    final bubbleColor = isUser
        ? colors.primary.withOpacity(0.15)
        : colors.surface;
    final textColor = isUser
        ? colors.onPrimary
        : textTheme.bodyMedium?.color;
    
    // Icon tương ứng
    final icon = isUser
        ? Icons.person
        : Icons.smart_toy_outlined;
    final iconColor = isUser
        ? colors.primary
        : colors.secondary;

    final bubbleWidget = Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      topRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                      if (timestamp != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(timestamp!),
                          style: textTheme.labelSmall?.copyWith(
                            color: textColor?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
          ],
        ],
      ),
    );

    // Áp dụng animation nếu được yêu cầu
    if (!showAnimation) {
      return bubbleWidget;
    }

    return bubbleWidget
        .animate(
          onPlay: (controller) => controller.repeat(reverse: false),
        )
        .fadeIn(
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .slide(
          begin: Offset(isUser ? 0.2 : -0.2, 0),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua, ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}