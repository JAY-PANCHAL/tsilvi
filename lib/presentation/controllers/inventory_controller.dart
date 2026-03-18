import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import '../../core/utils/app_storage.dart';
import '../../core/utils/toast.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'cart_controller.dart';

class InventoryController extends GetxController {
  final InventoryRepository repository;

  InventoryController(this.repository);

  final items = <InventoryEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final query = ''.obs;
  final page = 1.obs;
  final categories = <CategoryEntity>[].obs;
  final selectedCategory = Rxn<CategoryEntity>();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _init();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _init() async {
    await _loadCategories();
    await fetchInitial();
  }

  Future<void> _loadCategories() async {
    var data = await AppStorage.getCategories();
    if (data.isEmpty) {
      try {
        final repo = Get.find<CategoryRepository>();
        data = await repo.fetchCollections();
        if (data.isNotEmpty) {
          await AppStorage.setCategories(data);
        }
      } catch (_) {}
    }
    categories.assignAll(data);
    if (categories.isNotEmpty) {
      selectedCategory.value ??= categories.first;
    }
  }

  Future<void> fetchInitial() async {
    final category = selectedCategory.value?.slug ?? '';
    if (category.isEmpty) {
      items.clear();
      hasMore.value = false;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    page.value = 1;
    try {
      final data = await repository.fetchInventory(
        page: page.value,
        limit: AppConstants.pageSize,
        query: query.value,
        category: category,
      );
      items.assignAll(data);
      hasMore.value = data.length == AppConstants.pageSize;
    } catch (e) {
      showToast('Failed to load items', success: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    page.value += 1;
    try {
      final data = await repository.fetchInventory(
        page: page.value,
        limit: AppConstants.pageSize,
        query: query.value,
        category: selectedCategory.value?.slug ?? '',
      );
      items.addAll(data);
      hasMore.value = data.length == AppConstants.pageSize;
    } catch (e) {
      showToast('Failed to load more items', success: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void updateQuery(String value) {
    query.value = value;
    fetchInitial();
  }

  Future<void> searchBySku(String value) async {
    final sku = value.trim();
    if (sku.isEmpty) return;
    final item = await repository.fetchBySku(sku);
    if (item == null) {
      showToast('No item found for SKU $sku', success: false);
      return;
    }
    items.removeWhere((e) => e.id == item.id);
    items.insert(0, item);
    showToast('Found ${item.name}');
  }

  void selectCategory(CategoryEntity category) {
    final current = selectedCategory.value;
    final sameSlug =
        current?.slug.isNotEmpty == true && current?.slug == category.slug;
    final sameName = current?.slug.isEmpty == true &&
        current?.name.toLowerCase() == category.name.toLowerCase();
    if (sameSlug || sameName) return;
    selectedCategory.value = category;
    selectedCategory.refresh();
    fetchInitial();
  }

  Future<void> scanAndAddSku(String sku) async {
    final item = await repository.fetchBySku(sku);
    if (item == null) {
      Get.snackbar('Not Found', 'No item found for SKU $sku');
      return;
    }
    if (!items.any((e) => e.id == item.id)) {
      items.insert(0, item);
    }
    Get.find<CartController>().addItem(item);
    showToast('${item.name} added to cart');
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }
}
