import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoboothProvider>(builder: (context, provider, child) {
      final characters = provider.gender == 'male'
          ? ['m1.png', 'm2.png', 'm3.png', 'm4.png']
          : ['f1.png', 'f2.png', 'f3.png', 'f4.png'];

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
              const Text(
                'Select Your Character',
                style: TextStyle(
                  fontSize: 40,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: characters
                    .map((character) => GestureDetector(
                          onTap: () {
                            provider.setSelectedCharacter(character);
                            Navigator.pushNamed(context, AppRoutes.faceCapture);
                          },
                          child: Container(
                            width: 250,
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.goldenYellow,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/characters/$character'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
