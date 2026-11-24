import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';

import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';

class ProductListScreen extends StatefulWidget {
  final bool embedded;
  const ProductListScreen({super.key, this.embedded = false});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductProvider>().fetchAll();
      });
    }
  }

  List<ProductModel> _filtered(ProductProvider pp) {
    var list = pp.items;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.description ?? '').toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final canManage = auth.isAdmin;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search_rounded, size: 21),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => _query = ''),
                      icon: const Icon(Icons.close_rounded, size: 19),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: pp.loading
              ? const LoadingWidget()
              : pp.error != null
              ? ErrorState(message: pp.error!, onRetry: () => pp.fetchAll())
              : _filtered(pp).isEmpty
              ? EmptyState(
                  message: _query.isEmpty
                      ? 'Belum ada produk'
                      : 'Produk tidak ditemukan',
                  subtitle: _query.isEmpty
                      ? 'Tambahkan produk pertama Anda untuk mulai berjualan.'
                      : 'Coba kata kunci lain atau periksa ejaan.',
                  icon: _query.isEmpty
                      ? Icons.shopping_bag_outlined
                      : Icons.search_off_rounded,
                )
              : RefreshIndicator(
                  onRefresh: () => pp.fetchAll(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    itemCount: _filtered(pp).length,
                    itemBuilder: (ctx, i) {
                      final p = _filtered(pp)[i];
                      return ProductCard(
                        product: p,
                        canEditImage: canManage,
                        onTap: () => Navigator.pushNamed(
                          ctx,
                          AppRoutes.productDetail,
                          arguments: p.id,
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );

    if (widget.embedded) return Scaffold(body: SafeArea(child: body));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
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
                    Navigator.pushNamed(context, AppRoutes.productForm),
              ),
            ),
        ],
      ),
      body: body,
    );
  }
}
