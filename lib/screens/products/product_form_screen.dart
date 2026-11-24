import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');

  int? _id;
  int? _categoryId;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _existingImageUrl;
  bool _clearImage = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _id == null) {
      _id = args;
      _loadProduct(args);
    }
    context.read<CategoryProvider>().fetchAll();
  }

  Future<void> _loadProduct(int id) async {
    final pp = context.read<ProductProvider>();
    await pp.fetchById(id);
    final p = pp.selected;
    if (p != null && mounted) {
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description ?? '';
      _priceCtrl.text = p.price.toString();
      _stockCtrl.text = p.stock.toString();
      _categoryId = p.categoryId;
      _existingImageUrl = p.imageUrl;
      _clearImage = false;
      setState(() {});
    }
  }

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _clearImage = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _existingImageUrl = null;
      _clearImage = true;
    });
  }

  Future<void> _chooseImageSource() async {
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
    if (source != null) await _pickImage(source: source);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori wajib dipilih')),
      );
      return;
    }
    final pp = context.read<ProductProvider>();
    setState(() => _loading = true);
    bool ok;
    if (_id == null) {
      ok = await pp.create(
        name: _nameCtrl.text.trim(),
        categoryId: _categoryId!,
        price: double.parse(_priceCtrl.text.trim()),
        description: _descCtrl.text.trim(),
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        imageBytes: _imageBytes,
        imageName: _imageName,
      );
    } else {
      ok = await pp.update(
        _id!,
        name: _nameCtrl.text.trim(),
        categoryId: _categoryId!,
        price: double.parse(_priceCtrl.text.trim()),
        description: _descCtrl.text.trim(),
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
        imageBytes: _imageBytes,
        imageName: _imageName,
        clearImage: _clearImage,
      );
    }
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _id == null ? 'Produk berhasil dibuat' : 'Produk berhasil diperbarui',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pp.error ?? 'Gagal'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _imgBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 17, color: color ?? Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CategoryProvider>();
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Akses ditolak')),
      );
    }

    final hasExisting =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(_id == null ? 'Tambah Produk' : 'Edit Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _chooseImageSource,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppTheme.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _imageBytes != null
                          ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                          : hasExisting
                          ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: AppTheme.primary,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pilih Gambar Produk',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_imageBytes != null || hasExisting)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _imgBtn(Icons.edit_outlined, _chooseImageSource),
                          const SizedBox(width: 8),
                          _imgBtn(
                            Icons.delete_outline,
                            _removeImage,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Nama Produk',
                validator: (v) =>
                    Validators.required(v, field: 'Nama produk'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.grid_view_rounded, size: 20),
                ),
                items: cp.items
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceCtrl,
                      label: 'Harga',
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: Validators.price,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockCtrl,
                      label: 'Stok',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Deskripsi',
                maxLines: 4,
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: _id == null ? 'Simpan Produk' : 'Perbarui Produk',
                icon: _id == null ? Icons.check_rounded : Icons.save_outlined,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
