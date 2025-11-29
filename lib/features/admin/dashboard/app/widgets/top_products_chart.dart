import 'package:flutter/material.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import '../../domain/entities/dashboard_stats.dart';

class TopProductsChart extends StatefulWidget {
  final List<TopProduct> products;

  const TopProductsChart({super.key, this.products = const []});

  @override
  State<TopProductsChart> createState() => _TopProductsChartState();
}

class _TopProductsChartState extends State<TopProductsChart>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late List<Animation<double>> _heightAnimations;

  late final List<ProductData> _products;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0; // Default to first product
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize products from widget (map domain entity to view model)
    final input = widget.products;
    _products = input.isNotEmpty
        ? input
            .map((p) => ProductData(
                name: p.name, soldCount: p.soldCount, imageUrl: p.imageUrl))
            .toList()
        : [
            ProductData(name: '—', soldCount: 0, imageUrl: ''),
          ];

    // Calculate relative heights (0.0 to 1.0)
    final maxSold =
        _products.map((p) => p.soldCount).reduce((a, b) => a > b ? a : b);
    _heightAnimations = _products.map((product) {
      return Tween<double>(
        begin: 0.0,
        end: product.soldCount / (maxSold == 0 ? 1 : maxSold),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
      );
    }).toList();

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppLanguage.topProducts,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA3C335),
            ),
          ),
          const SizedBox(height: 24),

          // Chart
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_products.length, (index) {
                    return _buildProductBar(index);
                  }),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Product Images
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_products.length, (index) {
              return _buildProductImage(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBar(int index) {
    final isSelected = index == _selectedIndex;
    final product = _products[index];
    final heightFactor = _heightAnimations[index].value;

    // Calculate bar height (minimum 20% to show small values)
    final barHeight = 120 * (0.2 + (heightFactor * 0.8));

    return GestureDetector(
      onTap: () => _onBarTap(index),
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Sold count label (only show on selected)
            SizedBox(
              height: 32,
              child: isSelected
                  ? TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFA3C335),
                                    Color(0xFF668209),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                AppLanguage.formatNumber(product.soldCount),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 40,
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFA3C335),
                          Color(0xFF668209),
                        ],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFE0E0E0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(int index) {
    final product = _products[index];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: product.imageUrl.isNotEmpty
            ? Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.shopping_bag_outlined,
        color: Colors.grey.shade400,
        size: 20,
      ),
    );
  }
}

class ProductData {
  final String name;
  final int soldCount;
  final String imageUrl;

  ProductData({
    required this.name,
    required this.soldCount,
    required this.imageUrl,
  });
}
