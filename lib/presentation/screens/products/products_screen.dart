import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  static const List<String> _tabs = [
    'All',
    'Cosmetics',
    'Supplements',
    'Appliances',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const List<_Product> _products = [
    _Product(
      name: 'Naarya Glow Serum',
      description: 'Brightening vitamin C serum with hyaluronic acid for radiant skin.',
      category: 'Cosmetics',
      price: '₹899',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFE91E8C),
      bg: Color(0xFFFCE4EC),
      isAvailable: true,
    ),
    _Product(
      name: 'Rose Petal Face Wash',
      description: 'Gentle cleansing with natural rose extracts. Suitable for all skin types.',
      category: 'Cosmetics',
      price: '₹449',
      icon: Icons.local_florist_rounded,
      color: Color(0xFFC2185B),
      bg: Color(0xFFFFEBEE),
      isAvailable: true,
    ),
    _Product(
      name: 'Naarya Hair Nourish Oil',
      description: 'Ayurvedic blend of bhringraj, amla & coconut for strong, lustrous hair.',
      category: 'Cosmetics',
      price: '₹599',
      icon: Icons.spa_rounded,
      color: Color(0xFF7B52A8),
      bg: Color(0xFFEDE7F6),
      isAvailable: true,
    ),
    _Product(
      name: 'Iron & Folate Supplement',
      description: 'Women\'s daily iron + folate capsules for energy and cycle health.',
      category: 'Supplements',
      price: '₹699',
      icon: Icons.medication_rounded,
      color: Color(0xFF43A047),
      bg: Color(0xFFE8F5E9),
      isAvailable: false,
    ),
    _Product(
      name: 'Omega-3 for Women',
      description: 'High-potency fish oil capsules supporting hormonal & heart health.',
      category: 'Supplements',
      price: '₹799',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF1976D2),
      bg: Color(0xFFE3F2FD),
      isAvailable: false,
    ),
    _Product(
      name: 'Smart Period Heater',
      description: 'Wireless heat therapy belt for cramp relief during menstruation.',
      category: 'Appliances',
      price: '₹1,299',
      icon: Icons.heat_pump_rounded,
      color: Color(0xFFF57C00),
      bg: Color(0xFFFFF3E0),
      isAvailable: false,
    ),
    _Product(
      name: 'Posture Corrector for Women',
      description: 'Ergonomic back support designed for the female spine.',
      category: 'Appliances',
      price: '₹999',
      icon: Icons.accessibility_new_rounded,
      color: Color(0xFFAB6DBC),
      bg: Color(0xFFEDD9F0),
      isAvailable: false,
    ),
  ];

  List<_Product> get _filtered {
    if (_selectedTab == 0) return _products;
    return _products.where((p) => p.category == _tabs[_selectedTab]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Products', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: AppColors.divider,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Naarya Wellness Store',
                            style: AppTextStyles.h2.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Cosmetics, supplements & appliances — all curated for women.',
                          style: AppTextStyles.body2.copyWith(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 36),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            SectionHeader(title: _selectedTab == 0 ? 'All Products' : _tabs[_selectedTab]),
            const SizedBox(height: AppSpacing.componentGap),

            ..._filtered.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
              child: _buildProductCard(p),
            )),

            const SizedBox(height: AppSpacing.sectionGap),
            // Future scope note
            NaaryaCard(
              color: AppColors.surfaceVariant,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'More products including supplements, appliances and specialised wellness items coming soon!',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(_Product product) {
    return NaaryaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: product.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product.icon, color: product.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: AppTextStyles.subtitle2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: product.isAvailable
                                  ? AppColors.textDark
                                  : AppColors.textMuted)),
                    ),
                    if (!product.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Soon',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                                fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(product.description,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(product.price,
                        style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (product.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Buy Now',
                            style: AppTextStyles.caption.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Product {
  final String name;
  final String description;
  final String category;
  final String price;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool isAvailable;

  const _Product({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    required this.bg,
    required this.isAvailable,
  });
}
