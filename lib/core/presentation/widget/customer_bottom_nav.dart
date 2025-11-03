import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/routing/app_routes.dart';
import '../theme/app_colors.dart';

class CustomerBottomNav extends StatefulWidget {
  final int initialIndex;
  const CustomerBottomNav({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
  late int currentIndex;

  final List<_TabData> _tabs = [
    _TabData(Icons.cloud_outlined, Icons.cloud, 'Thời tiết', AppRoutes.weatherHome),
    _TabData(Icons.star_outline, Icons.star, 'Yêu thích', AppRoutes.favorite),
    _TabData(Icons.map_outlined, Icons.map, 'Bản đồ', AppRoutes.rainMap), // THÊM TAB MAP
    _TabData(Icons.person_outline, Icons.person, 'Tài khoản', AppRoutes.profile),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bottomNavBackgroundDark : AppColors.bottomNavBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final isSelected = currentIndex == index;
              final tab = _tabs[index];
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (currentIndex != index) {
                      setState(() {
                        currentIndex = index;
                      });
                      context.go(tab.route);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? AppColors.bottomNavUnselectedDark : AppColors.bottomNavUnselected),
                            size: isSelected ? 26 : 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: isSelected ? 12 : 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? AppColors.bottomNavUnselectedDark : AppColors.bottomNavUnselected),
                          ),
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  
  const _TabData(this.icon, this.activeIcon, this.label, this.route);
}
