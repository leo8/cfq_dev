import 'package:flutter/material.dart';
import '../../utils/styles/colors.dart';
import '../../utils/styles/text_styles.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const String _imageUrl =
      'https://cdn.vectorstock.com/i/1000v/58/83/abstract-city-map-with-blurred-edge-vector-21245883.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.transparent,
      body: Stack(
        children: [
          // Background Image from Network
          Positioned.fill(
            child: Image.network(
              _imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text('Failed to load image',
                      style: CustomTextStyle.title3),
                );
              },
            ),
          ),
          // Overlay Text
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: CustomColor.customBlack
                    .withOpacity(0.5), // Semi-transparent background
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Upcoming Feature',
                style: CustomTextStyle.hugeTitle2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
