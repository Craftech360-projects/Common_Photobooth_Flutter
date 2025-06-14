import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/category_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Local UI state to control showing sub-categories
  bool _showAiArtistrySubCategories = false;

  // Card builder for reusability
  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: Constants.br16),
      child: InkWell(
        onTap: onTap,
        borderRadius: Constants.br16,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: AppColors.deepPurple),
              Constants.h16,
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepPurple,
                ),
              ),
              Constants.h8,
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.lightWhite,
      appBar: AppBar(
        title: const Text('Choose Your Experience'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Show a back button only if sub-categories are visible
        leading: _showAiArtistrySubCategories
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _showAiArtistrySubCategories = false;
                    categoryProvider.resetSelection();
                  });
                },
              )
            : null,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _showAiArtistrySubCategories
              ? _buildSubCategoryView(categoryProvider)
              : _buildMainCategoryView(categoryProvider),
        ),
      ),
    );
  }

  // Widget for the initial view with main categories
  Widget _buildMainCategoryView(CategoryProvider provider) {
    return Padding(
      key: const ValueKey('main_categories'),
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildCategoryCard(
              title: 'AI Artistry',
              subtitle: 'Transform your photo into a unique art style.',
              icon: Icons.palette,
              onTap: () {
                provider.selectMainCategory(MainCategory.aIArtistry);
                setState(() {
                  _showAiArtistrySubCategories = true;
                });
              },
            ),
          ),
          Constants.w24,
          Expanded(
            child: _buildCategoryCard(
              title: 'Swaplab',
              subtitle: 'Swap your face with a character.',
              icon: Icons.switch_account,
              onTap: () {
                provider.selectWorkflow('swaplab.json');
                Navigator.pushNamed(context, AppRoutes.genderSelection);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the view showing AI Artistry sub-categories
  Widget _buildSubCategoryView(CategoryProvider provider) {
    return Padding(
      key: const ValueKey('sub_categories'),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select an AI Artistry Style',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGrey),
          ),
          Constants.h32,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildCategoryCard(
                  title: 'Ghibli',
                  subtitle: 'Whimsical, hand-drawn anime style.',
                  icon: Icons.auto_awesome,
                  onTap: () {
                    provider.selectWorkflow('ghibli.json');
                    Navigator.pushNamed(context, AppRoutes.genderSelection);
                  },
                ),
              ),
              Constants.w24,
              Expanded(
                child: _buildCategoryCard(
                  title: 'Pixar',
                  subtitle: 'Cute and expressive 3D cartoon style.',
                  icon: Icons.movie_filter,
                  onTap: () {
                    provider.selectWorkflow('pixar.json');
                    Navigator.pushNamed(context, AppRoutes.genderSelection);
                  },
                ),
              ),
              Constants.w24,
              Expanded(
                child: _buildCategoryCard(
                  title: 'Packaging',
                  subtitle: 'Become a collectible action figure.',
                  icon: Icons.inventory_2,
                  onTap: () {
                    provider.selectWorkflow('packaging.json');
                    Navigator.pushNamed(context, AppRoutes.genderSelection);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
