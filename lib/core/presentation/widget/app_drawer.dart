import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/app_routes.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header với avatar và thông tin user - iOS style
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Menu items - iOS style
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.cloud_outlined,
                    title: 'Thời tiết',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.weatherHome);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.star_outline,
                    title: 'Địa điểm yêu thích',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.favorite);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Dự báo',
                    onTap: () {
                      Navigator.pop(context);
                      // Thêm route forecast nếu có
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Tài khoản',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.profile);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt',
                    onTap: () {
                      Navigator.pop(context);
                      // Thêm route settings nếu có
                    },
                  ),
                ],
              ),
            ),
            
            // Footer - Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Đăng xuất',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  // Xử lý logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isDestructive 
            ? Colors.red 
            : (isDark ? Colors.white70 : AppColors.onBackground),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive 
              ? Colors.red 
              : (isDark ? Colors.white : AppColors.onBackground),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white30 : Colors.black26,
          size: 20,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
