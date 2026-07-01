import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/scheduling_provider.dart';
import '../../core/state/ga_controller.dart';

// Notification state (simple in-memory for now)
final _unreadNotificationCountProvider = StateProvider<int>((ref) => 2);

class AppTopBar extends ConsumerWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(_unreadNotificationCountProvider);
    final gaState = ref.watch(gaControllerProvider);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          // App brand
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/logo.jpg', width: 28, height: 28, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('app_name_short'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Live GA status indicator (when running)
          if (gaState.isRunning && workspaceId != null) ...[
            _LiveGaIndicator(gaState: gaState),
            const SizedBox(width: 16),
          ],

          const Spacer(),

          // Language switcher button
          Consumer(builder: (context, ref, _) {
            final loc = ref.watch(localeProvider);
            final isAr = loc.languageCode == 'ar';
            return OutlinedButton.icon(
              onPressed: () {
                ref.read(localeProvider.notifier).state = isAr ? const Locale('en', '') : const Locale('ar', '');
              },
              icon: const Icon(Icons.language, size: 16),
              label: Text(
                isAr ? 'English' : 'العربية',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }),

          const SizedBox(width: 12),

          // Notifications button
          _NotificationBell(count: unreadCount, onTap: () => _showNotifications(context, ref)),

          const SizedBox(width: 8),

          // Settings button
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            tooltip: 'Settings',
          ),

          const SizedBox(width: 12),

          // User avatar
          _UserAvatar(),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('notifications')),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationItem(
                icon: Icons.check_circle,
                color: Colors.green,
                title: ctx.tr('ga_optimization_complete'),
                body: ctx.tr('ga_complete_body'),
                time: ctx.tr('time_2min_ago'),
              ),
              const Divider(),
              _NotificationItem(
                icon: Icons.upload_file,
                color: AppColors.primary,
                title: ctx.tr('import_successful'),
                body: ctx.tr('import_success_body'),
                time: ctx.tr('time_1hr_ago'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(_unreadNotificationCountProvider.notifier).state = 0;
              Navigator.pop(ctx);
            },
            child: Text(ctx.tr('mark_all_read')),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('close'))),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('settings')),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: ctx.tr('appearance'),
                subtitle: ctx.tr('light_mode_default'),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: ctx.tr('notifications_settings'),
                subtitle: ctx.tr('all_enabled'),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: ctx.tr('database'),
                subtitle: ctx.tr('sqlite_storage'),
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: ctx.tr('about'),
                subtitle: ctx.tr('version'),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('close'))),
        ],
      ),
    );
  }
}

class _LiveGaIndicator extends StatelessWidget {
  final GaRunState gaState;

  const _LiveGaIndicator({required this.gaState});

  @override
  Widget build(BuildContext context) {
    final progress = gaState.config.generationLimit > 0
        ? gaState.currentGeneration / gaState.config.generationLimit
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              color: Colors.green,
              backgroundColor: Colors.green.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.trArgs('gen_progress', [gaState.currentGeneration.toString(), gaState.config.generationLimit.toString()]),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.trArgs('percent_value', [(progress * 100).toStringAsFixed(0)]),
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUserMenu(context),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Center(
          child: Text(
            'O',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.tr('user_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('O', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text(ctx.tr('user_name'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(ctx.tr('user_email'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ctx.tr('close'))),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(body, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
