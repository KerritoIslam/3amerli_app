import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:amerli_app/features/notifications/domain/entities/notification.dart';

class NotificationListCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  const NotificationListCard(
      {super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(notification.createdAt);
    return InkWell(
      onTap: null, // Clickability disabled as requested
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                // slightly wider and taller thumbnail
                width: 56,
                height: 64,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icons/notifications.svg',
                    width: 36,
                    height: 36,
                    color: Colors.grey.shade600,
                    placeholderBuilder: (context) => Icon(Icons.notifications,
                        color: Colors.grey.shade600, size: 36)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF333333)))),
                      const SizedBox(width: 8),
                      Text(timeText,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: const Color(0xFF888888))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(notification.body,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return hm;
  }
}
