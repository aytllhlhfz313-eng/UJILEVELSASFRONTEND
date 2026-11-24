import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../app/theme.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool canEditImage;
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.canEditImage = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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

      final provider = context.read<ProductProvider>();
      final success = await provider.update(
        widget.product.id,
        imageBytes: bytes,
        imageName: file.name,
      );
      if (!mounted) return;
      _showMessage(
        success
            ? 'Gambar produk berhasil diperbarui'
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
        content: const Text('Hapus gambar produk ini? Produk tetap tersimpan.'),
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
      final provider = context.read<ProductProvider>();
      final success = await provider.update(
        widget.product.id,
        clearImage: true,
      );
      if (!mounted) return;
      _showMessage(
        success
            ? 'Gambar produk berhasil dihapus'
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
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _imageActionLoading ? null : onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 17, color: color ?? Colors.white),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.25,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.canEditImage ? _chooseImageSource : null,
                      child:
                          product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: AppTheme.background,
                                child: const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryLight,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: AppTheme.background,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.primary.withValues(alpha: 0.06),
                              child: widget.canEditImage
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppTheme.primary,
                                          size: 30,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Tambah gambar',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppTheme.primaryLight,
                                      size: 34,
                                    ),
                            ),
                    ),
                    if (widget.canEditImage)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          children: [
                            _imageActionButton(
                              Icons.edit_outlined,
                              'Edit gambar',
                              _chooseImageSource,
                            ),
                            if (product.imageUrl != null &&
                                product.imageUrl!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _imageActionButton(
                                Icons.delete_outline,
                                'Hapus gambar',
                                _removeImage,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (product.stock <= 0)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Stok habis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (_imageActionLoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: const Center(
                          child: SizedBox(
                            height: 26,
                            width: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${_formatPrice(product.price)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (product.categoryName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        product.categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
