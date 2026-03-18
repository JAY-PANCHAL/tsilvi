import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../domain/entities/inventory_entity.dart';
import '../widgets/gradient_background.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as InventoryEntity;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: item.images.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(item.images[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.5,
                  );
                },
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
