import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? _id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _id == null) {
      _id = args;
      context.read<ProductProvider>().fetchById(args);
    }
  }

  Future<void> _confirmDelete() async {
    final pp = context.read<ProductProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Yakin ingin menghapus produk ini?'),
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
    if (ok == true && _id != null) {
      final success = await pp.delete(_id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pp.error ?? 'Gagal menghapus'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
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
    final pp = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;
    final p = pp.selected;

    if (pp.loading && p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final hasImage = p.imageUrl != null && p.imageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Edit produk',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.productForm,
                arguments: p.id,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: p.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppTheme.background,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.background,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    )
                  : Container(
                      color: AppTheme.primary.withValues(alpha: 0.06),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 56,
                        color: AppTheme.primaryLight,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (p.categoryName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.categoryName!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              const Spacer(),
              _stockBadge(p.stock),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatPrice(p.price)}',
            style: const TextStyle(
              fontSize: 24,
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (p.description != null && p.description!.isNotEmpty) ...[
            _sectionTitle('Deskripsi'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                p.description!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _sectionTitle('Informasi'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _infoRow(Icons.inventory_2_outlined, 'Stok', p.stock.toString()),
                if (p.categoryName != null) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoRow(
                    Icons.grid_view_rounded,
                    'Kategori',
                    p.categoryName!,
                  ),
                ],
                if (p.createdAt != null) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _infoRow(Icons.calendar_today_outlined, 'Dibuat', p.createdAt!),
                ],
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productForm,
                      arguments: p.id,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _stockBadge(int stock) {
    final depleted = stock <= 0;
    final color = depleted ? AppTheme.error : AppTheme.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        depleted ? 'Stok habis' : 'Stok tersedia',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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
}
