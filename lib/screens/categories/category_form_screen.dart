import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../app/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/utils/validators.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key});
  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _id;
  bool _loading = false;

  Uint8List? _imageBytes;
  String? _imageName;
  String? _existingImageUrl;
  bool _clearImage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _id == null) {
      _id = args;
      _load(args);
    }
  }

  Future<void> _load(int id) async {
    final cp = context.read<CategoryProvider>();
    await cp.fetchAll();
    final c = cp.findById(id);
    if (c != null && mounted) {
      _nameCtrl.text = c.name;
      _descCtrl.text = c.description ?? '';
      _existingImageUrl = c.imageUrl;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cp = context.read<CategoryProvider>();
    setState(() => _loading = true);
    bool ok;
    if (_id == null) {
      ok = await cp.create(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageBytes: _imageBytes,
        imageName: _imageName,
      );
    } else {
      ok = await cp.update(
        _id!,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
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
            _id == null
                ? 'Kategori berhasil dibuat'
                : 'Kategori berhasil diperbarui',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cp.error ?? 'Gagal'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text(_id == null ? 'Tambah Kategori' : 'Edit Kategori'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _chooseImageSource,
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _imageBytes != null
                            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                            : hasExisting
                            ? Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.grid_view_rounded,
                                size: 48,
                                color: AppTheme.primary,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: _imgBtn(
                        hasExisting || _imageBytes != null
                            ? Icons.edit_outlined
                            : Icons.add_a_photo_outlined,
                        _chooseImageSource,
                        color: Colors.white,
                      ),
                    ),
                    if (hasExisting || _imageBytes != null)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: _imgBtn(
                          Icons.delete_outline,
                          _removeImage,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Nama Kategori',
                prefixIcon: Icons.grid_view_rounded,
                validator: (v) =>
                    Validators.required(v, field: 'Nama kategori'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Deskripsi',
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: _id == null ? 'Simpan Kategori' : 'Perbarui Kategori',
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
