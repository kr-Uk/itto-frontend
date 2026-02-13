import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../models/settings_models.dart';
import '../providers/settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadNotificationSettings();
    });
  }

  void _updateSetting({
    bool? chatNotification,
    bool? relationshipNotification,
    bool? statsNotification,
    bool? marketingNotification,
  }) {
    final provider = context.read<SettingsProvider>();
    final current = provider.notificationSettings;

    if (current == null) return;

    final updated = NotificationSettings(
      chatNotification: chatNotification ?? current.chatNotification,
      relationshipNotification:
          relationshipNotification ?? current.relationshipNotification,
      statsNotification: statsNotification ?? current.statsNotification,
      marketingNotification:
          marketingNotification ?? current.marketingNotification,
    );

    provider.updateNotificationSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '알림 설정'),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          if (settingsProvider.isLoading &&
              settingsProvider.notificationSettings == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final settings = settingsProvider.notificationSettings;

          if (settings == null) {
            return const Center(
              child: Text(
                '알림 설정을 불러올 수 없습니다.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                const Text(
                  '받고 싶은 알림을 선택해주세요',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Notification toggles
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _NotificationToggleRow(
                        title: '채팅 알림',
                        value: settings.chatNotification,
                        onChanged: (value) => _updateSetting(
                          chatNotification: value,
                        ),
                        isFirst: true,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.divider,
                        ),
                      ),
                      _NotificationToggleRow(
                        title: '인연 알림',
                        value: settings.relationshipNotification,
                        onChanged: (value) => _updateSetting(
                          relationshipNotification: value,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.divider,
                        ),
                      ),
                      _NotificationToggleRow(
                        title: '통계 알림',
                        value: settings.statsNotification,
                        onChanged: (value) => _updateSetting(
                          statsNotification: value,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: AppColors.divider,
                        ),
                      ),
                      _NotificationToggleRow(
                        title: '마케팅 알림',
                        value: settings.marketingNotification,
                        onChanged: (value) => _updateSetting(
                          marketingNotification: value,
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification toggle row
// ---------------------------------------------------------------------------

class _NotificationToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isFirst;
  final bool isLast;

  const _NotificationToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
