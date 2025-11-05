import 'package:flutter/material.dart';

class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const CustomerBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Thời tiết'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
      onTap: onTap,
    );
  }
}
