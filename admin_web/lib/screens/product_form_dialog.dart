import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/admin_provider.dart';
import '../utils/validators.dart';

/// Dialog tạo mới hoặc chỉnh sửa sản phẩm.
Future<void> showProductFormDialog(BuildContext context, {Product? product}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _ProductForm(product: product),
      ),
    ),
  );
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  const _ProductForm({this.product});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _descCtrl;
  late String _category;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '');
    _imageCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _category = p?.category ?? kCategories.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final body = {
      'name': _nameCtrl.text.trim(),
      'category': _category,
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
      'imageUrl': _imageCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
    };

    final admin = context.read<AdminProvider>();
    final error = _isEdit
        ? await admin.updateProduct(widget.product!.id, body)
        : await admin.createProduct(body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const Divider(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                        prefixIcon: Icon(Icons.card_giftcard_outlined),
                      ),
                      validator: (v) => Validators.required(v, 'tên sản phẩm'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Danh mục',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Giá (đ)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, 'giá'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tồn kho',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, 'tồn kho'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Link ảnh sản phẩm',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      validator: (v) => Validators.required(v, 'link ảnh'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(_isEdit ? 'Lưu thay đổi' : 'Thêm sản phẩm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
