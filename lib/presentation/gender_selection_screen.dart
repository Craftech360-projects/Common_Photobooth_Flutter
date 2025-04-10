import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<PhotoboothProvider>().setGender('male');
                    Navigator.pushNamed(context, AppRoutes.characterSelection);
                  },
                  child: Container(
                    width: 300,
                    height: 400,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.goldenYellow,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/male_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<PhotoboothProvider>().setGender('female');
                    Navigator.pushNamed(context, AppRoutes.characterSelection);
                  },
                  child: Container(
                    width: 300,
                    height: 400,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.goldenYellow,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/female_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
