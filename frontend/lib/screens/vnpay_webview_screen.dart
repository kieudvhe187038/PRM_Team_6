import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../utils/app_theme.dart';

/// Mở URL thanh toán VNPay. Dùng WebView nhúng trên Android/iOS — nền tảng
/// chính của đồ án, được `webview_flutter` hỗ trợ đầy đủ (kể cả bắt điều
/// hướng qua `NavigationDelegate` để nhận biết lúc thanh toán xong).
/// Trên Web/Windows (chưa được hỗ trợ đầy đủ hoặc thiếu NavigationDelegate)
/// thì mở bằng trình duyệt ngoài — trả về `null` vì không bắt được kết quả,
/// nhưng đơn hàng vẫn được cập nhật đúng qua `vnp_ReturnUrl` phía backend.
Future<bool?> openVnPayPayment(BuildContext context, String paymentUrl) async {
  final useEmbeddedWebView = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (!useEmbeddedWebView) {
    await launchUrl(
      Uri.parse(paymentUrl),
      mode: LaunchMode.externalApplication,
    );
    return null;
  }
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => VnPayWebViewScreen(paymentUrl: paymentUrl),
    ),
  );
}

/// Màn hình WebView hiển thị trang thanh toán VNPay, tự động đóng khi
/// VNPay chuyển hướng về backend (`/api/payment/vnpay-return`).
class VnPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  const VnPayWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<VnPayWebViewScreen> createState() => _VnPayWebViewScreenState();
}

class _VnPayWebViewScreenState extends State<VnPayWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _finished = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Bật debug để soi được nội dung thật của WebView qua chrome://inspect
    // trên máy host khi gặp màn hình trắng không rõ nguyên nhân.
    if (!kIsWeb && Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true);
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _checkReturn,
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            _checkReturn(url);
          },
          // Không xử lý lỗi thì trang lỗi (mất mạng, DNS, timeout...) sẽ
          // hiển thị màn hình trắng không rõ nguyên nhân cho người dùng.
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _error = '${error.description} (mã ${error.errorCode})';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _controller.loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkReturn(String url) {
    if (_finished || !mounted || !url.contains('/api/payment/vnpay-return'))
      return;
    _finished = true;
    final success = Uri.parse(url).queryParameters['vnp_ResponseCode'] == '00';
    Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    // Trong WebView nhúng, mọi cách thoát màn hình trước khi VNPay redirect
    // về vnpay-return (nút back cứng, back của AppBar, huỷ giao dịch trên
    // trang VNPay rồi thoát...) phải trả về false (thất bại) — không được
    // để rơi vào null, vì null chỉ dành riêng cho trường hợp mở bằng trình
    // duyệt ngoài (không có gì để bắt điều hướng).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Stack(
          children: [
            if (_error == null) WebViewWidget(controller: _controller),
            if (_loading)
              const Center(child: CircularProgressIndicator(color: kPrimary)),
            if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Không tải được trang thanh toán VNPay',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _retry,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
