import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_spacing.dart';
import '../../../core/utils/cycle_phase_calculator.dart';
import '../../../data/models/nutrition_plan_model.dart';
import '../../widgets/common/naarya_card.dart';
import '../../widgets/common/section_header.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _phaseLabels = ['Menstrual', 'Follicular', 'Ovulation', 'Luteal'];

  static const _phaseColors = [
    AppColors.phaseMenstrual,
    AppColors.phaseFollicular,
    AppColors.phaseOvulation,
    AppColors.phaseLuteal,
  ];

  static const _phaseBgColors = [
    AppColors.phaseMenstrualBg,
    AppColors.phaseFollicularBg,
    AppColors.phaseOvulationBg,
    AppColors.phaseLutealBg,
  ];

  late final List<NutritionPlan> _plans;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _plans = _buildMockPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NutritionPlan> _buildMockPlans() {
    return [
      // Menstrual
      NutritionPlan(
        phase: CyclePhase.menstrual,
        phaseDescription:
            'During menstruation your body loses iron and needs replenishment. '
            'Focus on warm, nourishing foods that reduce cramps and restore energy.',
        meals: const [
          MealSuggestion(
            name: 'Iron-Rich Spinach Dal',
            type: 'lunch',
            ingredients: ['Spinach', 'Moong dal', 'Turmeric', 'Cumin', 'Garlic'],
          ),
          MealSuggestion(
            name: 'Warm Beetroot Soup',
            type: 'dinner',
            ingredients: ['Beetroot', 'Carrot', 'Ginger', 'Onion', 'Black pepper'],
          ),
          MealSuggestion(
            name: 'Dark Chocolate & Banana Smoothie',
            type: 'snack',
            ingredients: ['Dark chocolate', 'Banana', 'Almond milk', 'Honey'],
          ),
          MealSuggestion(
            name: 'Spinach & Cheese Omelette',
            type: 'breakfast',
            ingredients: ['Eggs', 'Spinach', 'Cheese', 'Tomato', 'Onion'],
          ),
        ],
        tips: const [
          'Eat iron-rich foods like spinach, lentils, and red meat to compensate for blood loss.',
          'Stay hydrated with warm water, herbal teas, and soups.',
          'Include dark chocolate (70%+ cacao) to boost mood and magnesium.',
          'Avoid excessive caffeine and salty foods to reduce bloating.',
          'Ginger tea can help alleviate menstrual cramps naturally.',
        ],
        focusNutrients: const ['Iron', 'Magnesium', 'Vitamin C', 'Omega-3'],
      ),
      // Follicular
      NutritionPlan(
        phase: CyclePhase.follicular,
        phaseDescription:
            'Rising estrogen boosts energy and metabolism. This is a great time to eat '
            'lighter, nutrient-dense foods that support hormone production.',
        meals: const [
          MealSuggestion(
            name: 'Grilled Chicken Salad',
            type: 'lunch',
            ingredients: ['Chicken breast', 'Mixed greens', 'Avocado', 'Lemon dressing', 'Seeds'],
          ),
          MealSuggestion(
            name: 'Kimchi Rice Bowl',
            type: 'dinner',
            ingredients: ['Brown rice', 'Kimchi', 'Tofu', 'Sesame oil', 'Spring onion'],
          ),
          MealSuggestion(
            name: 'Fresh Veggie Wrap',
            type: 'lunch',
            ingredients: ['Whole wheat wrap', 'Hummus', 'Bell pepper', 'Cucumber', 'Sprouts'],
          ),
          MealSuggestion(
            name: 'Probiotic Yoghurt Parfait',
            type: 'breakfast',
            ingredients: ['Greek yoghurt', 'Granola', 'Blueberries', 'Chia seeds', 'Honey'],
          ),
        ],
        tips: const [
          'Include lean protein like chicken, fish, and eggs to support muscle building.',
          'Fermented foods (yoghurt, kimchi, sauerkraut) support gut health and estrogen metabolism.',
          'Eat plenty of fresh vegetables for fibre and micronutrients.',
          'This is a good phase to try intermittent fasting if desired.',
          'Focus on vitamin E-rich foods like almonds and sunflower seeds.',
        ],
        focusNutrients: const ['Protein', 'Probiotics', 'Vitamin E', 'B Vitamins'],
      ),
      // Ovulation
      NutritionPlan(
        phase: CyclePhase.ovulation,
        phaseDescription:
            'Peak energy! Your body temperature rises slightly. Focus on lighter meals '
            'with antioxidants and anti-inflammatory foods.',
        meals: const [
          MealSuggestion(
            name: 'Berry Antioxidant Bowl',
            type: 'breakfast',
            ingredients: ['Mixed berries', 'Acai powder', 'Banana', 'Oats', 'Almond butter'],
          ),
          MealSuggestion(
            name: 'Quinoa Tabbouleh',
            type: 'lunch',
            ingredients: ['Quinoa', 'Parsley', 'Tomato', 'Cucumber', 'Lemon juice', 'Olive oil'],
          ),
          MealSuggestion(
            name: 'Grilled Fish with Veggies',
            type: 'dinner',
            ingredients: ['Salmon', 'Asparagus', 'Lemon', 'Garlic', 'Brown rice'],
          ),
          MealSuggestion(
            name: 'Fruit & Nut Trail Mix',
            type: 'snack',
            ingredients: ['Almonds', 'Walnuts', 'Dried cranberries', 'Pumpkin seeds', 'Dark chocolate chips'],
          ),
        ],
        tips: const [
          'Eat antioxidant-rich fruits like berries, pomegranate, and citrus.',
          'Choose whole grains over refined carbs for sustained energy.',
          'Keep meals light and fresh — your metabolism is at its peak.',
          'Include anti-inflammatory spices like turmeric and ginger.',
          'Stay well-hydrated; your body temperature is slightly elevated.',
        ],
        focusNutrients: const ['Antioxidants', 'Fibre', 'Zinc', 'Vitamin D'],
      ),
      // Luteal
      NutritionPlan(
        phase: CyclePhase.luteal,
        phaseDescription:
            'Progesterone rises and PMS symptoms may appear. Eat complex carbs and '
            'magnesium-rich foods to stabilise mood and curb cravings.',
        meals: const [
          MealSuggestion(
            name: 'Sweet Potato & Black Bean Bowl',
            type: 'lunch',
            ingredients: ['Sweet potato', 'Black beans', 'Brown rice', 'Avocado', 'Salsa'],
          ),
          MealSuggestion(
            name: 'Oatmeal with Peanut Butter',
            type: 'breakfast',
            ingredients: ['Rolled oats', 'Peanut butter', 'Banana', 'Cinnamon', 'Flaxseeds'],
          ),
          MealSuggestion(
            name: 'Comfort Dal Khichdi',
            type: 'dinner',
            ingredients: ['Rice', 'Moong dal', 'Ghee', 'Turmeric', 'Cumin', 'Vegetables'],
          ),
          MealSuggestion(
            name: 'Magnesium Boost Smoothie',
            type: 'snack',
            ingredients: ['Cocoa powder', 'Banana', 'Spinach', 'Almond milk', 'Dates'],
          ),
        ],
        tips: const [
          'Complex carbs (sweet potatoes, oats, brown rice) help boost serotonin.',
          'Magnesium-rich foods (nuts, dark chocolate, bananas) ease PMS symptoms.',
          'Don\'t skip meals — blood sugar drops can worsen mood swings.',
          'Reduce salt, sugar, and caffeine to minimise bloating and irritability.',
          'Warm, comforting foods like soups and stews are ideal this phase.',
        ],
        focusNutrients: const ['Magnesium', 'Complex Carbs', 'Calcium', 'Vitamin B6'],
      ),
    ];
  }

  // ------ cancer food data ------
  static const _cancerCausingFoods = [
    {'name': 'Processed Meats', 'detail': 'Hot dogs, sausages, bacon — classified as Group 1 carcinogens by WHO.'},
    {'name': 'Sugary Drinks', 'detail': 'Excess sugar fuels inflammation and obesity, increasing cancer risk.'},
    {'name': 'Alcohol', 'detail': 'Even moderate drinking increases risk of breast and liver cancer.'},
    {'name': 'Charred / Grilled Meat', 'detail': 'High-heat cooking creates HCAs and PAHs linked to cancer.'},
    {'name': 'Refined Flour & Ultra-Processed Foods', 'detail': 'High glycemic index foods spike insulin, promoting tumour growth.'},
    {'name': 'Artificial Sweeteners (excess)', 'detail': 'Some studies link heavy use of certain artificial sweeteners to cancer risk.'},
    {'name': 'Trans Fats & Hydrogenated Oils', 'detail': 'Found in fried and packaged foods; linked to chronic inflammation.'},
  ];

  static const _cancerPreventingFoods = [
    {'name': 'Cruciferous Vegetables', 'detail': 'Broccoli, cauliflower, kale — contain sulforaphane, a potent anti-cancer compound.'},
    {'name': 'Berries', 'detail': 'Rich in anthocyanins and ellagic acid that protect DNA from damage.'},
    {'name': 'Turmeric', 'detail': 'Curcumin has strong anti-inflammatory and anti-cancer properties.'},
    {'name': 'Green Tea', 'detail': 'Catechins (EGCG) inhibit tumour growth and support detoxification.'},
    {'name': 'Tomatoes', 'detail': 'Lycopene is a powerful antioxidant linked to reduced cancer risk.'},
    {'name': 'Garlic & Onions', 'detail': 'Allium compounds help the body detoxify carcinogens.'},
    {'name': 'Whole Grains & Legumes', 'detail': 'Fibre-rich foods support gut health and lower colorectal cancer risk.'},
    {'name': 'Fatty Fish', 'detail': 'Omega-3 fatty acids reduce inflammation and may slow cancer cell growth.'},
    {'name': 'Nuts & Seeds', 'detail': 'Walnuts, flaxseeds, and chia seeds are rich in protective lignans.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.subtitle1,
          unselectedLabelStyle: AppTextStyles.subtitle2,
          tabs: List.generate(4, (i) => Tab(text: _phaseLabels[i])),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(4, (i) => _PhaseNutritionTab(
                plan: _plans[i],
                color: _phaseColors[i],
                bgColor: _phaseBgColors[i],
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Phase tab ────────────────────

class _PhaseNutritionTab extends StatelessWidget {
  final NutritionPlan plan;
  final Color color;
  final Color bgColor;

  const _PhaseNutritionTab({
    required this.plan,
    required this.color,
    required this.bgColor,
  });

  IconData _mealIcon(String type) {
    switch (type) {
      case 'breakfast':
        return Icons.free_breakfast_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'snack':
        return Icons.cookie_rounded;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // ---- Phase description card ----
        NaaryaCard(
          color: bgColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_rounded, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase Overview',
                      style: AppTextStyles.subtitle1.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(plan.phaseDescription, style: AppTextStyles.body2),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ---- Focus nutrients chips ----
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: plan.focusNutrients.map((n) {
            return Chip(
              label: Text(n, style: AppTextStyles.label.copyWith(color: color)),
              backgroundColor: bgColor,
              side: BorderSide(color: color.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              avatar: Icon(Icons.check_circle, size: 16, color: color),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ---- Meal suggestions ----
        const SectionHeader(title: 'Meal Suggestions'),
        const SizedBox(height: AppSpacing.componentGap),
        ...plan.meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.componentGap),
              child: _MealCard(meal: meal, color: color, bgColor: bgColor, mealIcon: _mealIcon(meal.type)),
            )),

        const SizedBox(height: AppSpacing.sectionGap),

        // ---- Tips ----
        const SectionHeader(title: 'Nutrition Tips'),
        const SizedBox(height: AppSpacing.componentGap),
        NaaryaCard(
          child: Column(
            children: plan.tips.asMap().entries.map((entry) {
              final isLast = entry.key == plan.tips.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: color, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(entry.value, style: AppTextStyles.body2),
                      ),
                    ],
                  ),
                  if (!isLast) const Divider(height: 20),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.sectionGap),

        // ---- Cancer foods section ----
        const SectionHeader(title: 'Cancer & Food'),
        const SizedBox(height: AppSpacing.componentGap),
        _CancerFoodSection(),

        const SizedBox(height: AppSpacing.sectionGap),
      ],
    );
  }
}

// ──────────────────── Meal card ────────────────────

class _MealCard extends StatelessWidget {
  final MealSuggestion meal;
  final Color color;
  final Color bgColor;
  final IconData mealIcon;

  const _MealCard({
    required this.meal,
    required this.color,
    required this.bgColor,
    required this.mealIcon,
  });

  @override
  Widget build(BuildContext context) {
    return NaaryaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(mealIcon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, style: AppTextStyles.subtitle1),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      ),
                      child: Text(
                        meal.type[0].toUpperCase() + meal.type.substring(1),
                        style: AppTextStyles.caption.copyWith(color: color, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: meal.ingredients.map((ing) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(ing, style: AppTextStyles.caption),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Cancer food section ────────────────────

class _CancerFoodSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cancer-causing foods
        NaaryaCard(
          color: AppColors.errorLight,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Foods That May Increase Cancer Risk',
                    style: AppTextStyles.subtitle1.copyWith(color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._NutritionScreenState._cancerCausingFoods.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.remove_circle_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${item['name']}: ',
                                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: item['detail'],
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.componentGap),

        // Cancer-preventing foods
        NaaryaCard(
          color: AppColors.successLight,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.success, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Foods That Help Prevent Cancer',
                    style: AppTextStyles.subtitle1.copyWith(color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._NutritionScreenState._cancerPreventingFoods.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.add_circle_outline, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${item['name']}: ',
                                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: item['detail'],
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
