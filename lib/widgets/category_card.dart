import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../app/theme.dart';

class CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool canEditImage;
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.trailing,
    this.canEditImage = false,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _imageActionLoading = false;

  Future<void> _chooseImageSource() async {
    if (_imageActionLoading) return;
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
    if (source != null && mounted) await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _imageActionLoading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      final provider = context.read<CategoryProvider>();
      final success = await provider.update(
        widget.category.id,
        imageBytes: bytes,
        imageName: file.name,
      );
      if (!mounted) return;
      _showMessage(
        success
            ? 'Gambar kategori berhasil diperbarui'
            : provider.error ?? 'Gagal memperbarui gambar',
        isError: !success,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal memilih gambar: $error', isError: true);
    } finally {
      if (mounted) setState(() => _imageActionLoading = false);
    }
  }

  Future<void> _removeImage() async {
    if (_imageActionLoading) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Gambar'),
        content: const Text(
          'Hapus gambar kategori ini? Kategori tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _imageActionLoading = true);
    try {
      final provider = context.read<CategoryProvider>();
      final success = await provider.update(
        widget.category.id,
        clearImage: true,
      );
      if (!mounted) return;
      _showMessage(
        success
            ? 'Gambar kategori berhasil dihapus'
            : provider.error ?? 'Gagal menghapus gambar',
        isError: !success,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal menghapus gambar: $error', isError: true);
    } finally {
      if (mounted) setState(() => _imageActionLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : null,
      ),
    );
  }

  Widget _imageActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    Color? color,
  }) {
    return SizedBox(
      width: 26,
      height: 26,
      child: IconButton(
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: _imageActionLoading ? null : onTap,
        icon: Icon(icon, size: 15, color: color),
      ),
    );
  }

  /// Avatar 56x56. Bila user boleh mengelola gambar, avatar bisa diketuk untuk
  /// memilih gambar dan tombol hapus muncul saat gambar sudah ada. Tombol
  /// diletakkan sebagai overlay di pojok avatar, bukan di sampingnya, agar
  /// tinggi ListTile tetap 56 dan tidak overflow.
  Widget _buildLeading(bool hasImage) {
    final avatar = CircleAvatar(
      radius: 26,
      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
      backgroundImage: hasImage
          ? CachedNetworkImageProvider(widget.category.imageUrl!)
          : null,
      child: hasImage
          ? null
          : const Icon(Icons.grid_view_rounded, color: AppTheme.primary),
    );

    if (!widget.canEditImage) return avatar;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _chooseImageSource,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: avatar,
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: _imageActionButton(
              hasImage ? Icons.edit_outlined : Icons.add_a_photo_outlined,
              hasImage ? 'Ganti gambar' : 'Tambah gambar',
              _chooseImageSource,
              color: AppTheme.primary,
            ),
          ),
          if (hasImage)
            Positioned(
              right: -4,
              top: -4,
              child: _imageActionButton(
                Icons.delete_outline,
                'Hapus gambar',
                _removeImage,
                color: AppTheme.error,
              ),
            ),
          if (_imageActionLoading)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.category.imageUrl != null &&
        widget.category.imageUrl!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: widget.onTap,
        leading: _buildLeading(hasImage),
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle:
            widget.category.description != null &&
                widget.category.description!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  widget.category.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            : null,
        trailing: widget.trailing,
      ),
    );
  }
}
