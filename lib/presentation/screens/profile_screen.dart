import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import '../../core/animations/list_animations.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/auth_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import 'auth/login_screen.dart';
import 'auth/change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _imagePath;
  late ImagePicker _picker;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeImagePicker();
    _loadUserAvatar();
  }
  
  Future<void> _loadUserAvatar() async {
    final user = await ref.read(authProvider.notifier).getCurrentUser();
    if (user != null && user.avatarUrl != null && mounted) {
      setState(() {
        _imagePath = user.avatarUrl;
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
    }
  }
  
  void _initializeImagePicker() {
    try {
      _picker = ImagePicker();
    } catch (e) {
      debugPrint('Error initializing ImagePicker: $e');
    }
  }
  
  Future<void> _saveAvatarToDatabase(String? avatarPath) async {
    final result = await ref.read(authProvider.notifier).updateProfile(
      avatarUrl: avatarPath,
    );
    
    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(avatarPath != null ? 'Đã lưu ảnh đại diện' : 'Đã xóa ảnh đại diện'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu ảnh: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(authProvider.notifier).getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          
          final user = snapshot.data;
          if (user == null) {
            return _buildNotLoggedInView(context);
          }
          
          return _buildUserProfileContent(context, ref, user);
        },
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa đăng nhập',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vui lòng đăng nhập để xem thông tin cá nhân',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileContent(BuildContext context, WidgetRef ref, User user) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          AnimatedCard(
            delay: const Duration(milliseconds: 100),
            child: _buildUserProfileHeader(context, user),
          ),
          const SizedBox(height: 24),
          AnimatedCard(
            delay: const Duration(milliseconds: 200),
            child: _buildProfileSection(
              context,
              title: 'Thông tin cá nhân',
              children: _buildPersonalInfoItems(context, ref, user),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCard(
            delay: const Duration(milliseconds: 300),
            child: _buildProfileSection(
              context,
              title: 'Bảo mật',
              children: [
                _buildProfileTile(
                  icon: Icons.lock,
                  title: 'Đổi mật khẩu',
                  subtitle: 'Thay đổi mật khẩu đăng nhập',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCard(
            delay: const Duration(milliseconds: 400),
            child: _buildProfileSection(
              context,
              title: 'Khác',
              children: [
                _buildProfileTile(
                  icon: Icons.info,
                  title: 'Về ứng dụng',
                  subtitle: 'Phiên bản 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildProfileTile(
                  icon: Icons.help,
                  title: 'Trợ giúp',
                  subtitle: 'Hướng dẫn sử dụng',
                  onTap: () => _showHelpDialog(context),
                ),
                _buildProfileTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản',
                  textColor: Colors.orange,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
                _buildProfileTile(
                  icon: Icons.delete_forever,
                  title: 'Xóa tài khoản',
                  subtitle: 'Xóa tài khoản vĩnh viễn',
                  textColor: Colors.red,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildPersonalInfoItems(BuildContext context, WidgetRef ref, User user) {
    List<Widget> items = [];
    
    // Always show name
    items.add(_buildProfileTile(
      icon: Icons.person,
      title: 'Họ và tên',
      subtitle: user.fullName,
      onTap: () => _showEditNameDialog(context, ref, user),
    ));
    
    // Always show email
    items.add(_buildProfileTile(
      icon: Icons.email,
      title: 'Email',
      subtitle: user.email,
      onTap: () => _showEditEmailDialog(context, ref, user),
    ));
    
    // Only show phone if it exists
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      items.add(_buildProfileTile(
        icon: Icons.phone,
        title: 'Số điện thoại',
        subtitle: user.phoneNumber!,
        onTap: () => _showEditPhoneDialog(context, ref, user),
      ));
    } else {
      items.add(_buildProfileTile(
        icon: Icons.phone,
        title: 'Thêm số điện thoại',
        subtitle: 'Chưa có số điện thoại',
        onTap: () => _showEditPhoneDialog(context, ref, user),
      ));
    }
    
    return items;
  }

  Widget _buildUserProfileHeader(BuildContext context, User user) {
    final daysSinceJoined = DateTime.now().difference(user.createdAt).inDays + 1;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                  child: _imagePath == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _pickImage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context, 
                  'Đã tham gia', 
                  '$daysSinceJoined ngày',
                  isDarkMode
                ),
                _buildStatItem(
                  context, 
                  'Trạng thái', 
                  user.isEmailVerified ? 'Đã xác thực' : 'Chưa xác thực',
                  isDarkMode
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Xóa ảnh'),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() {
                      _imagePath = null;
                    });
                    // Remove avatar from database
                    await _saveAvatarToDatabase(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      // Try to pick image with error handling
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _showErrorSnackBar('Timeout: Không thể mở thư viện ảnh');
          return null;
        },
      );
      
      if (image != null && mounted) {
        // Verify file exists
        final file = File(image.path);
        if (await file.exists()) {
          setState(() {
            _imagePath = image.path;
          });
          // Save avatar to database
          await _saveAvatarToDatabase(image.path);
        } else {
          _showErrorSnackBar('Không thể tìm thấy file ảnh');
        }
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
      if (e.code == 'photo_access_denied') {
        _showPermissionDialog();
      } else {
        _showErrorSnackBar('Lỗi: ${e.message ?? 'Không thể chọn ảnh'}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackBar('Đã xảy ra lỗi khi chọn ảnh');
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quyền truy cập bị từ chối'),
        content: const Text(
          'Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh đại diện. '
          'Vui lòng vào Cài đặt > Quyền và cho phép truy cập.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Open app settings
              // You can use permission_handler package to open settings
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }


  Widget _buildStatItem(BuildContext context, String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDarkMode 
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(BuildContext context, {required String title, required List<Widget> children}) {
    // Only show section if it has children
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }


  void _showEditNameDialog(BuildContext context, WidgetRef ref, User user) {
    final controller = TextEditingController(text: user.fullName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa họ và tên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final result = await ref.read(authProvider.notifier).updateProfile(
                  fullName: controller.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  if (result.success) {
                    setState(() {}); // Refresh the UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message ?? 'Cập nhật thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Cập nhật thất bại'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email không thể thay đổi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email hiện tại: ${user.email}'),
            const SizedBox(height: 12),
            const Text(
              'Để bảo mật tài khoản, email không thể thay đổi sau khi đăng ký.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(BuildContext context, WidgetRef ref, User user) {
    final controller = TextEditingController(text: user.phoneNumber ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa số điện thoại'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final result = await ref.read(authProvider.notifier).updateProfile(
                phoneNumber: controller.text.isEmpty ? null : controller.text,
              );
              if (mounted) {
                Navigator.pop(context);
                if (result.success) {
                  setState(() {}); // Refresh the UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.message ?? 'Cập nhật thành công')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Cập nhật thất bại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final currencies = ['VND', 'USD', 'EUR', 'JPY'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn đơn vị tiền tệ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) => RadioListTile<String>(
            title: Text(currency),
            value: currency,
            groupValue: profile.currency,
            onChanged: (value) {
              if (value != null) {
                ref.read(userProfileControllerProvider.notifier)
                    .updateCurrency(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    final languages = [
      {'code': 'vi', 'name': 'Tiếng Việt'},
      {'code': 'en', 'name': 'English'},
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => RadioListTile<String>(
            title: Text(lang['name']!),
            value: lang['code']!,
            groupValue: profile.language,
            onChanged: (value) {
              if (value != null) {
                ref.read(userProfileControllerProvider.notifier)
                    .updateLanguage(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              final result = await ref.read(authProvider.notifier).logout();
              
              if (context.mounted) {
                if (result.success) {
                  // Navigate to login screen and clear navigation stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Đăng xuất thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Đăng xuất thất bại'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn xóa tài khoản? Hành động này sẽ:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text('• Xóa vĩnh viễn tất cả dữ liệu cá nhân'),
            const Text('• Xóa tất cả giao dịch và ngân sách'),
            const Text('• Xóa tất cả mục tiêu và thông báo'),
            const Text('• Không thể khôi phục sau khi xóa'),
            const SizedBox(height: 16),
            const Text(
              'Nhập "XOA TAI KHOAN" để xác nhận:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'XOA TAI KHOAN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (confirmController.text.trim().toUpperCase() == 'XOA TAI KHOAN') {
                Navigator.pop(context);
                
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Đang xóa tài khoản...'),
                      ],
                    ),
                  ),
                );
                
                // Delete account
                final result = await ref.read(authProvider.notifier).deleteAccount();
                
                if (mounted) {
                  Navigator.pop(context); // Close loading dialog
                  
                  if (result.success) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Tài khoản đã được xóa thành công'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.message ?? 'Không thể xóa tài khoản'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập chính xác "XOA TAI KHOAN"'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Quản Lý Chi Tiêu',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Quản Lý Chi Tiêu',
      children: const [
        Text('Ứng dụng quản lý tài chính cá nhân giúp bạn theo dõi thu chi và lập ngân sách hiệu quả.'),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trợ giúp'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Thêm giao dịch: Nhấn nút + để thêm thu/chi'),
            Text('• Tạo ngân sách: Vào mục Ngân sách và nhấn +'),
            Text('• Theo dõi mục tiêu: Sử dụng mục Mục tiêu'),
            Text('• Xem báo cáo: Kiểm tra Dashboard'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}