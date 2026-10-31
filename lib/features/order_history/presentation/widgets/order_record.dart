import 'package:flutter/material.dart';

enum OrderStatus { pending, visited, skipped, confirmed }

extension OrderStatusStyling on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.visited => 'Visited',
    OrderStatus.skipped => 'Skipped',
    OrderStatus.confirmed => 'Confirmed',
  };

  Color get color => switch (this) {
    OrderStatus.pending => const Color(0xFF1565C0),
    OrderStatus.visited => const Color(0xFF616161),
    OrderStatus.skipped => const Color(0xFFC62828),
    OrderStatus.confirmed => const Color(0xFF2E7D32),
  };

  Color get backgroundColor => switch (this) {
    OrderStatus.pending => const Color(0xFFE8F0FE),
    OrderStatus.visited => const Color(0xFFEEEEEE),
    OrderStatus.skipped => const Color(0xFFFFEBEE),
    OrderStatus.confirmed => const Color(0xFFE8F5E9),
  };

  IconData get icon => switch (this) {
    OrderStatus.pending => Icons.schedule_rounded,
    OrderStatus.visited => Icons.store_outlined,
    OrderStatus.skipped => Icons.block_rounded,
    OrderStatus.confirmed => Icons.check_circle_outline_rounded,
  };
}

class OrderRecord {
  final String id;
  final String shop;
  final String area;
  final String phone;
  final String detail; // notes / items to pitch
  final String time;
  final OrderStatus status;

  const OrderRecord({
    required this.id,
    required this.shop,
    required this.time,
    required this.status,
    this.area = '',
    this.phone = '',
    this.detail = '',
  });

  OrderRecord copyWith({
    String? shop,
    String? area,
    String? phone,
    String? detail,
    String? time,
    OrderStatus? status,
  }) {
    return OrderRecord(
      id: id,
      shop: shop ?? this.shop,
      area: area ?? this.area,
      phone: phone ?? this.phone,
      detail: detail ?? this.detail,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }

  static const List<OrderRecord> dummyList = [
    OrderRecord(
      id: '1',
      shop: 'Ali Brothers — Johar Town',
      detail: 'Lays 50g x20, Kurkure x15, Slanty x10',
      time: '10:32 AM',
      status: OrderStatus.confirmed,
    ),
    // ...add id: '2', '3', ... to the rest of your entries
  ];
}
