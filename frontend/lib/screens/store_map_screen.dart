import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_theme.dart';

/// Thông tin một cửa hàng (kèm tọa độ thật để mở Google Maps).
class _Store {
  final String name;
  final String address;
  final String hours;
  final double lat;
  final double lng;
  const _Store(this.name, this.address, this.hours, this.lat, this.lng);
}

/// Màn hình vị trí cửa hàng.
///
/// Bấm "Chỉ đường" sẽ mở **Google Maps** dẫn đường tới cửa hàng
/// (dùng url_launcher với tọa độ thật). Nếu chưa cài app Google Maps,
/// hệ thống mở bằng trình duyệt.
class StoreMapScreen extends StatelessWidget {
  const StoreMapScreen({super.key});

  static const _stores = [
    _Store(
      'BearShop Quận 1',
      '227 Nguyễn Văn Cừ, Q.5, TP.HCM',
      '08:00 - 22:00',
      10.762622,
      106.682172,
    ),
    _Store(
      'BearShop Hà Nội',
      '08 Tôn Thất Thuyết, Cầu Giấy, Hà Nội',
      '08:30 - 21:30',
      21.030653,
      105.782316,
    ),
    _Store(
      'BearShop Đà Nẵng',
      '470 Trần Đại Nghĩa, Ngũ Hành Sơn, Đà Nẵng',
      '09:00 - 21:00',
      16.032,
      108.230,
    ),
  ];

  /// Mở Google Maps chỉ đường tới cửa hàng.
  Future<void> _openDirections(BuildContext context, _Store s) async {
    // API URL của Google Maps: ưu tiên mở app, fallback trình duyệt.
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được Google Maps.')),
      );
    }
  }

  /// Mở Google Maps xem vị trí cửa hàng (khi bấm vào ảnh bản đồ).
  Future<void> _openLocation(BuildContext context, _Store s) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${s.lat},${s.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(title: const Text('Cửa hàng gần bạn')),
      body: Column(
        children: [
          // Ảnh bản đồ tĩnh — bấm để mở Google Maps cửa hàng chính.
          InkWell(
            onTap: () => _openLocation(context, _stores.first),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.map, size: 60),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: kSoftShadow,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, color: kPrimary),
                        SizedBox(width: 6),
                        Text(
                          'Mở Google Maps',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _stores.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = _stores[i];
                return Container(
                  decoration: kCardDecoration(radius: 14),
                  child: ListTile(
                    onTap: () => _openLocation(context, s),
                    leading: const CircleAvatar(
                      backgroundColor: kPrimary,
                      child: Icon(Icons.store, color: Colors.white),
                    ),
                    title: Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.address),
                        Text(
                          'Giờ mở cửa: ${s.hours}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      tooltip: 'Chỉ đường',
                      icon: const Icon(Icons.directions, color: kPrimary),
                      onPressed: () => _openDirections(context, s),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
