import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AuthProvider>().tryAutoLogin(),
      );
    }
  }

  Future<void> _pickAvatar({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
      });
    }
  }

  Future<void> _chooseAvatarSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickAvatar(source: source);
  }

  void _removeAvatar() {
    setState(() {
      _avatarBytes = null;
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = user?.isAdmin ?? false;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.brandGradient,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: _avatarBytes != null
                      ? MemoryImage(_avatarBytes!)
                      : null,
                  child: _avatarBytes == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppTheme.primary,
                        )
                      : null,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _smallBtn(Icons.edit_outlined, _chooseAvatarSource),
                  const SizedBox(width: 6),
                  if (_avatarBytes != null)
                    _smallBtn(
                      Icons.delete_outline,
                      _removeAvatar,
                      color: AppTheme.error,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? '-',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '-',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (isAdmin ? AppTheme.primary : AppTheme.textSecondary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin
                      ? Icons.verified_user_rounded
                      : Icons.person_outline_rounded,
                  size: 15,
                  color: isAdmin ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  isAdmin ? 'Admin' : 'User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isAdmin ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              _infoRow(Icons.alternate_email_rounded, 'Email', user?.email ?? '-'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _infoRow(Icons.badge_outlined, 'Peran', user?.role ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 28),
        CustomButton(
          label: 'Keluar',
          icon: Icons.logout_rounded,
          color: AppTheme.error,
          onPressed: _logout,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Contre Store • v1.0.0',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );

    if (widget.embedded) return Scaffold(body: SafeArea(child: body));
    return Scaffold(appBar: AppBar(title: const Text('Profil')), body: body);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: color ?? AppTheme.primary,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
