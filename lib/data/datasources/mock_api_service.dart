import 'dart:math';

import '../../core/utils/app_constants.dart';
import '../models/inventory_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class MockApiService {
  final Random _random = Random(42);
  final List<InventoryModel> _inventory = [];
  final List<UserModel> _users = [];
  final List<OrderModel> _orders = [];

  MockApiService() {
    _seedInventory();
    _seedUsers();
    _seedOrders();
  }

  Future<void> sendOtp(String mobile) async {
    await Future.delayed(const Duration(milliseconds: 900));
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return otp == AppConstants.mockOtp;
  }

  Future<List<InventoryModel>> fetchInventory({
    required int page,
    required int limit,
    String query = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 850));
    final filtered = _inventory
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.sku.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final start = (page - 1) * limit;
    if (start >= filtered.length) return [];
    final end = min(start + limit, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<InventoryModel?> fetchBySku(String sku) async {
    await Future.delayed(const Duration(milliseconds: 700));
    try {
      return _inventory.firstWhere(
          (item) => item.sku.toLowerCase() == sku.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> fetchUsers({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (query.isEmpty) return _users;
    final q = query.toLowerCase();
    return _users
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.mobile.contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  Future<UserModel> addUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _users.insert(0, user);
    return user;
  }

  Future<List<OrderModel>> fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _orders;
  }

  Future<OrderModel> addOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _orders.insert(0, order);
    return order;
  }

  void _seedInventory() {
    const imagePool = [
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
      'https://images.unsplash.com/photo-1503602642458-232111445657?w=800',
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=800',
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
    ];

    for (var i = 0; i < 64; i++) {
      final sku = 'SKU-${1000 + i}';
      final name = 'Premium Item ${i + 1}';
      final images = [
        imagePool[i % imagePool.length],
        imagePool[(i + 2) % imagePool.length],
        imagePool[(i + 4) % imagePool.length],
      ];
      _inventory.add(
        InventoryModel(
          id: 'inv_$i',
          name: name,
          sku: sku,
          description:
              'A premium ${i % 2 == 0 ? 'glass' : 'metal'} finish product with elegant design and durable build. Perfect for modern retail.',
          price: 40 + _random.nextInt(120) + _random.nextDouble(),
          currency: 'INR',
          images: images,
        ),
      );
    }
  }

  void _seedUsers() {
    const names = [
      'Aarav Mehta',
      'Diya Sharma',
      'Neel Patel',
      'Isha Kapoor',
      'Kabir Verma',
      'Mira Nair',
    ];
    for (var i = 0; i < names.length; i++) {
      _users.add(UserModel(
        id: 'user_$i',
        name: names[i],
        mobile: '98${_random.nextInt(100000000).toString().padLeft(8, '0')}',
        email: '${names[i].split(' ').first.toLowerCase()}@tsilivi.com',
        businessName: 'Tsilivi Retail ${i + 1}',
      ));
    }
  }

  void _seedOrders() {
    for (var i = 0; i < 5; i++) {
      _orders.add(
        OrderModel(
          id: 'ORD-${9000 + i}',
          date: DateTime.now().subtract(Duration(days: i * 2)),
          total: 240.0 + _random.nextInt(500).toDouble(),
          items: [],
        ),
      );
    }
  }
}
