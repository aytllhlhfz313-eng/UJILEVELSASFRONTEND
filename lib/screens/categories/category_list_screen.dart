import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../widgets/category_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class CategoryListScreen extends StatefulWidget {
  final bool embedded;
  const CategoryListScreen({super.key, this.embedded = false});
  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CategoryProvider>().fetchAll(),
      );
    }
  }

  Future<void> _delete(int id) async {
    final cp = context.read<CategoryProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: const Text('Yakin ingin menghapus kategori ini?'),
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
    if (ok == true) {
      final success = await cp.delete(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cp.error ?? 'Gagal menghapus'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CategoryProvider>();
    final auth = context.watch<AuthProvider>();
    final canManage = auth.isLoggedIn;

    final body = cp.loading
        ? const LoadingWidget()
        : cp.error != null
        ? ErrorState(message: cp.error!, onRetry: () => cp.fetchAll())
        : cp.items.isEmpty
        ? const EmptyState(
            message: 'Belum ada kategori',
            subtitle: 'Buat kategori untuk mengelompokkan produk Anda.',
            icon: Icons.grid_view_rounded,
          )
        : RefreshIndicator(
            onRefresh: () => cp.fetchAll(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: cp.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final c = cp.items[i];
                return CategoryCard(
                  category: c,
                  canEditImage: canManage,
                  onTap: canManage
                      ? () => Navigator.pushNamed(
                          ctx,
                          AppRoutes.categoryForm,
                          arguments: c.id,
                        )
                      : null,
                  trailing: canManage
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 19,
                              ),
                              onPressed: () => Navigator.pushNamed(
                                ctx,
                                AppRoutes.categoryForm,
                                arguments: c.id,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 19,
                                color: AppTheme.error,
                              ),
                              onPressed: () => _delete(c.id),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          if (canManage)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add_rounded),
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.categoryForm),
              ),
            ),
        ],
      ),
      body: body,
    );
  }
}
