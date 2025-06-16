import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ThemeSelectionScreenState createState() => ThemeSelectionScreenState();
}

class ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeSelectionProvider>(context);
    final photoboothProvider =
        Provider.of<PhotoboothProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Select a Theme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider.builder(
              itemCount: themeProvider.themes.length,
              itemBuilder: (context, index, realIndex) {
                final theme = themeProvider.themes[index];
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () {
                    _controller.animateToItem(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldenYellow
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.goldenYellow.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        theme.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 400,
                enlargeCenterPage: true,
                viewportFraction: 0.6,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final selectedTheme = themeProvider.themes[_currentIndex];
                photoboothProvider.setTheme(selectedTheme);
                Navigator.pushNamed(context, AppRoutes.genderSelection);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldenYellow,
                foregroundColor: AppColors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
