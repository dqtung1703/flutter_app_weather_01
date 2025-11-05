import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? email;
  final VoidCallback? onLogout;

  const AppDrawer({Key? key, this.email, this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: email != null ? Text(email!) : null,
            accountName: const Text('Weather User'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Yêu thích'),
            onTap: () => Navigator.pushNamed(context, '/favorites'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Cài đặt'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất'),
              onTap: onLogout,
            ),
        ],
      ),
    );
  }
}
