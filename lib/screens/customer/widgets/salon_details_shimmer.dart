import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_colors.dart';

class SalonDetailsShimmer extends StatelessWidget {
  SalonDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surface,
        highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero cover shimmer
              Container(
                height: 240,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(height: 24, width: 220, decoration: _boxDec()),
                    SizedBox(height: 10),
                    // Category
                    Container(height: 14, width: 120, decoration: _boxDec()),
                    SizedBox(height: 14),
                    // Rating & Location
                    Row(
                      children: [
                        Container(height: 20, width: 60, decoration: _boxDec()),
                        SizedBox(width: 10),
                        Container(
                            height: 14, width: 140, decoration: _boxDec()),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        4,
                        (index) => Column(
                          children: [
                            Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle)),
                            SizedBox(height: 6),
                            Container(
                                height: 10, width: 36, decoration: _boxDec()),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Tabs
                    Container(height: 44, decoration: _boxDec()),
                    SizedBox(height: 20),
                    // Service Cards
                    Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 80,
                            decoration: _boxDec(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDec() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
