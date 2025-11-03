import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameController = TextEditingController();
  bool _loading = false;

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await user.updateDisplayName(_displayNameController.text.trim());
      await user.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công 🎉')),
      );
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Bạn chưa đăng nhập')));
    }

    _displayNameController.text = user.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 60, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu thay đổi'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('UID người dùng'),
                subtitle: Text(user.uid),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Ngày tạo tài khoản'),
                subtitle: Text(user.metadata.creationTime?.toString() ?? ''),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Lần đăng nhập gần nhất'),
                subtitle: Text(user.metadata.lastSignInTime?.toString() ?? ''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
