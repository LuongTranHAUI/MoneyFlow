import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      title: 'Chào mừng đến với Quản Lý Chi Tiêu',
      subtitle: 'Quản lý tài chính cá nhân thông minh và hiệu quả',
      image: '💰',
      description: 'Theo dõi thu chi hàng ngày, lập ngân sách và đạt được mục tiêu tài chính của bạn.',
    ),
    WelcomePageData(
      title: 'Theo dõi Thu Chi',
      subtitle: 'Ghi lại mọi giao dịch một cách dễ dàng',
      image: '📊',
      description: 'Thêm các giao dịch thu nhập và chi tiêu, phân loại theo danh mục để dễ quản lý.',
    ),
    WelcomePageData(
      title: 'Lập Ngân Sách',
      subtitle: 'Kiểm soát chi tiêu với ngân sách thông minh',
      image: '🎯',
      description: 'Đặt giới hạn chi tiêu cho từng danh mục và nhận thông báo khi sắp vượt ngân sách.',
    ),
    WelcomePageData(
      title: 'Đặt Mục Tiêu',
      subtitle: 'Tiết kiệm để đạt được các mục tiêu tài chính',
      image: '🚀',
      description: 'Tạo các mục tiêu tiết kiệm và theo dõi tiến độ để thực hiện ước mơ của bạn.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToAuth(),
                child: const Text(
                  'Bỏ qua',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  if (_currentPage < _pages.length - 1)
                    ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: _navigateToAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Bắt đầu',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(WelcomePageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Text(
                page.image,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _markNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
  }

  void _navigateToAuth() async {
    await _markNotFirstTime();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Chọn tùy chọn để tiếp tục',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Login button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                child: const Text(
                  'Đã có tài khoản? Đăng nhập',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class WelcomePageData {
  final String title;
  final String subtitle;
  final String image;
  final String description;

  WelcomePageData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
  });
}