import 'package:finance_tracker/core/animations/list_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khác'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh any necessary data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Summary Card
              AnimatedListItem(
                index: 0,
                child: _buildProfileSummaryCard(context),
              ),
              const SizedBox(height: 20),
              
              // Reports & Analytics Section
              _buildSectionHeader(context, 'Báo cáo & Phân tích'),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 1,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.analytics_rounded,
                  title: 'Báo cáo chi tiết',
                  subtitle: 'Phân tích thu chi theo thời gian',
                  onTap: () => _showComingSoonDialog(context, 'Báo cáo chi tiết'),
                ),
              ),
              AnimatedListItem(
                index: 2,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.insights_rounded,
                  title: 'Thống kê nâng cao',
                  subtitle: 'Insights và xu hướng chi tiêu',
                  onTap: () => _showComingSoonDialog(context, 'Thống kê nâng cao'),
                ),
              ),
              AnimatedListItem(
                index: 3,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.download_rounded,
                  title: 'Xuất dữ liệu',
                  subtitle: 'Tải về Excel, PDF, CSV',
                  onTap: () => _showComingSoonDialog(context, 'Xuất dữ liệu'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Accounts & Wallets Section
              _buildSectionHeader(context, 'Tài khoản & Ví'),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 4,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.account_balance_rounded,
                  title: 'Quản lý tài khoản',
                  subtitle: 'Ngân hàng, ví điện tử, tiền mặt',
                  onTap: () => _showComingSoonDialog(context, 'Quản lý tài khoản'),
                ),
              ),
              AnimatedListItem(
                index: 5,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'Thẻ tín dụng',
                  subtitle: 'Theo dõi limit và chu kỳ thanh toán',
                  onTap: () => _showComingSoonDialog(context, 'Thẻ tín dụng'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tools & Settings Section  
              _buildSectionHeader(context, 'Công cụ & Cài đặt'),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 6,
                child: _buildThemeTile(context, ref),
              ),
              AnimatedListItem(
                index: 7,
                child: _buildLanguageTile(context, ref),
              ),
              AnimatedListItem(
                index: 8,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.repeat_rounded,
                  title: 'Giao dịch định kỳ',
                  subtitle: 'Lương, hóa đơn tự động',
                  onTap: () => _showComingSoonDialog(context, 'Giao dịch định kỳ'),
                ),
              ),
              AnimatedListItem(
                index: 9,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.sync_rounded,
                  title: 'Sync & Backup',
                  subtitle: 'Đồng bộ dữ liệu và sao lưu',
                  onTap: () => _showComingSoonDialog(context, 'Sync & Backup'),
                ),
              ),
              AnimatedListItem(
                index: 10,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Thông báo',
                  subtitle: 'Cài đặt nhắc nhở và cảnh báo',
                  onTap: () => _showComingSoonDialog(context, 'Thông báo'),
                ),
              ),
              AnimatedListItem(
                index: 11,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Bảo mật',
                  subtitle: 'PIN, sinh trắc học, mã hóa',
                  onTap: () => _showComingSoonDialog(context, 'Bảo mật'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Support Section
              _buildSectionHeader(context, 'Hỗ trợ'),
              const SizedBox(height: 12),
              AnimatedListItem(
                index: 12,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.help_rounded,
                  title: 'Trợ giúp',
                  subtitle: 'FAQ và hướng dẫn sử dụng',
                  onTap: () => _showComingSoonDialog(context, 'Trợ giúp'),
                ),
              ),
              AnimatedListItem(
                index: 13,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.feedback_rounded,
                  title: 'Phản hồi',
                  subtitle: 'Góp ý để cải thiện ứng dụng',
                  onTap: () => _showComingSoonDialog(context, 'Phản hồi'),
                ),
              ),
              AnimatedListItem(
                index: 14,
                child: _buildFeatureTile(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Về ứng dụng',
                  subtitle: 'Phiên bản 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: const Text('Tài khoản cá nhân'),
        subtitle: const Text('Xem và chỉnh sửa thông tin'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.construction_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Sắp ra mắt'),
        content: Text('Tính năng "$feature" đang được phát triển và sẽ có trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Quản Lý Chi Tiêu',
        applicationVersion: '1.0.0',
        applicationIcon: Icon(
          Icons.account_balance_wallet,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        children: [
          const Text('Ứng dụng quản lý tài chính cá nhân toàn diện.'),
          const SizedBox(height: 8),
          const Text('Giúp bạn theo dõi thu chi, lập ngân sách, và đạt được các mục tiêu tài chính.'),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    String getThemeModeText(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return 'Theo hệ thống';
        case ThemeMode.light:
          return 'Sáng';
        case ThemeMode.dark:
          return 'Tối';
      }
    }
    
    IconData getThemeModeIcon(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return Icons.brightness_auto;
        case ThemeMode.light:
          return Icons.light_mode;
        case ThemeMode.dark:
          return Icons.dark_mode;
      }
    }
    
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getThemeModeIcon(themeMode),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Giao diện'),
        subtitle: Text(getThemeModeText(themeMode)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(context, ref),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Theo hệ thống'),
              subtitle: const Text('Tự động theo cài đặt thiết bị'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sáng'),
              subtitle: const Text('Giao diện nền sáng'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Tối'),
              subtitle: const Text('Giao diện nền tối'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Ngôn ngữ'),
        subtitle: const Text('Tiếng Việt'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLanguageDialog(context, ref),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              subtitle: const Text('Vietnamese'),
              value: 'vi',
              groupValue: 'vi',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ngôn ngữ đã được đặt thành Tiếng Việt'),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('Tiếng Anh'),
              value: 'en',
              groupValue: 'vi',
              onChanged: (value) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng đa ngôn ngữ sẽ có trong phiên bản tiếp theo'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}