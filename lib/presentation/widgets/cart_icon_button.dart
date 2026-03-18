import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../controllers/users_controller.dart';
import 'customer_required_dialog.dart';

class CartIconButton extends StatelessWidget {
  final Color color;

  const CartIconButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final usersController = Get.find<UsersController>();

    return Obx(
      () {
        final count = cartController.totalItems;
        return IconButton(
          onPressed: () async {
            if (!usersController.hasSelectedUser) {
              await showCustomerRequiredDialog();
              return;
            }
            Get.toNamed(AppRoutes.cart);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_bag_outlined, color: color),
              if (count > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
