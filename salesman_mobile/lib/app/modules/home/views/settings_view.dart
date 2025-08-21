import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/home/controllers/home_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 24),
        _buildSettingsSection(
          title: 'Akun',
          items: [
            _buildSettingItem(icon: Icons.person_outline, title: 'Profil Saya', onTap: () {}),
            _buildSettingItem(icon: Icons.lock_outline, title: 'Keamanan', onTap: () {}),
            _buildSettingItem(icon: Icons.notifications_none, title: 'Notifikasi', onTap: () {}),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: 'Aplikasi',
          items: [
            _buildSettingItem(icon: Icons.language, title: 'Bahasa', trailing: const Text('Indonesia'), onTap: () {}),
            _buildSettingItem(icon: Icons.dark_mode_outlined, title: 'Tema', trailing: const Text('Sistem'), onTap: () {}),
            _buildSettingItem(icon: Icons.help_outline, title: 'Bantuan', onTap: () {}),
            _buildSettingItem(icon: Icons.info_outline, title: 'Tentang Aplikasi', onTap: () {}),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              await controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('Versi 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade100,
            border: Border.all(color: Colors.blue.shade200, width: 2),
          ),
          child: const Icon(Icons.person, size: 40, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Sales Executive', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text('john.doe@example.com', style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
          ),
        ),
        Card(child: Column(children: items)),
      ],
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
