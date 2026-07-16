import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_notification.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/order_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatter.dart';
import '../utils/validators.dart';
import 'order_success_screen.dart';
import 'vnpay_webview_screen.dart';

/// Màn hình thanh toán: nhập thông tin nhận hàng (có validation) + chọn
/// phương thức thanh toán, sau đó tạo đơn hàng lưu vào CSDL.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _payment = 'COD (Thanh toán khi nhận hàng)';
  bool _placing = false;

  static const _shippingFee = 30000.0;

  @override
  void initState() {
    super.initState();
    // Điền sẵn từ tài khoản đang đăng nhập cho tiện.
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    final notis = context.read<NotificationProvider>();

    try {
      // Gọi API tạo đơn hàng trên backend .NET.
      final order = await orders.placeOrder(
        items: cart.items,
        receiverName: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        paymentMethod: _payment,
      );

      // null = không xác định được kết quả (ví dụ mở bằng trình duyệt ngoài
      // trên Web/Windows) -> vẫn coi như đơn đã tạo bình thường, do backend
      // cập nhật trạng thái độc lập qua vnp_ReturnUrl/IPN.
      bool? vnpaySuccess;
      if (_payment == 'VNPay') {
        try {
          final url = await ApiService.instance.createVnPayUrl(order.dbId);
          if (!mounted) return;
          vnpaySuccess = await openVnPayPayment(context, url);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Không mở được cổng thanh toán VNPay, đơn vẫn đã được tạo.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      if (!mounted) return;

      // Thanh toán thất bại/bị hủy rõ ràng -> hủy đơn tạm, giữ nguyên giỏ hàng
      // để khách quay lại giỏ/checkout thử lại, không tính là đã đặt hàng.
      if (vnpaySuccess == false) {
        await orders.cancelOrder(order.dbId);
        if (!mounted) return;
        setState(() => _placing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thanh toán không thành công, đơn đã được hủy. Vui lòng thử lại.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // VNPay mà không xác nhận được kết quả (mở bằng trình duyệt ngoài trên
      // Web/Windows) -> KHÔNG được báo "thành công", vì lúc này người dùng
      // còn chưa thao tác gì trên tab thanh toán vừa mở. Đơn hàng vẫn được
      // tạo (unpaid), chỉ khác cách thông báo cho khách.
      final vnpayPending = _payment == 'VNPay' && vnpaySuccess == null;

      notis.push(
        AppNotification(
          title: vnpayPending
              ? 'Đơn hàng đã được tạo'
              : 'Đặt hàng thành công 🎉',
          body: vnpayPending
              ? 'Đơn ${order.id}: vui lòng hoàn tất thanh toán VNPay trên trình duyệt vừa mở.'
              : 'Đơn ${order.id} trị giá ${formatVnd(order.total)} đang được xử lý.',
          time: DateTime.now(),
          icon: vnpayPending ? Icons.hourglass_top : Icons.check_circle,
        ),
      );
      cart.clear();

      if (!mounted) return;
      setState(() => _placing = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              OrderSuccessScreen(order: order, paymentPending: vnpayPending),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không kết nối được máy chủ.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.totalPrice + _shippingFee;
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      backgroundColor: kBg,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionCard(
              title: 'Thông tin nhận hàng',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tên người nhận',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => Validators.required(v, 'tên người nhận'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ giao hàng',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (v) => Validators.required(v, 'địa chỉ'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Phương thức thanh toán',
              icon: Icons.payments_outlined,
              child: RadioGroup<String>(
                groupValue: _payment,
                onChanged: (v) => setState(() => _payment = v!),
                child: Column(
                  children: [
                    for (final method in const [
                      'COD (Thanh toán khi nhận hàng)',
                      'Chuyển khoản ngân hàng',
                      'VNPay',
                    ])
                      _paymentTile(method),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'Chi tiết thanh toán',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _row('Tạm tính', formatVnd(cart.totalPrice)),
                  const SizedBox(height: 8),
                  _row('Phí vận chuyển', formatVnd(_shippingFee)),
                  const Divider(height: 24),
                  _row('Tổng thanh toán', formatVnd(total), highlight: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: kSoftShadow,
          ),
          child: ElevatedButton(
            onPressed: _placing ? null : _placeOrder,
            child: _placing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Đặt hàng • ${formatVnd(total)}'),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: kCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _paymentTile(String method) {
    final selected = _payment == method;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _payment = method),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? kPrimary.withValues(alpha: 0.06) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? kPrimary.withValues(alpha: 0.4)
                  : Colors.grey.shade200,
            ),
          ),
          child: RadioListTile<String>(
            value: method,
            title: Text(
              method,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            activeColor: kPrimary,
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            color: highlight ? Colors.black87 : Colors.black54,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 19 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? kPrimary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
