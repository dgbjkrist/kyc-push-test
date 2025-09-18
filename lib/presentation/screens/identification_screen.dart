import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/picture_card.dart';
import '../widgets/tab_app_bar.dart';

class IdentificationScreen extends StatefulWidget {
  const IdentificationScreen({super.key});

  @override
  State<IdentificationScreen> createState() => _IdentificationScreenState();
}

class _IdentificationScreenState extends State<IdentificationScreen> {
  void _takePhoto(String type) {
    debugPrint("Prendre photo pour: $type");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabAppBar(
        context: context,
        titleProp: "Identification",
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Prenez en photo la pièce en vous assurant que les informations sont bien visibles",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                PictureCard(
                  title: "Photo Visage",
                  icon: Icons.face,
                  onTap: () => _takePhoto("visage"),
                ),
                const SizedBox(height: 16),
                PictureCard(
                  title: "Pièce Recto",
                  icon: Icons.credit_card,
                  onTap: () => _takePhoto("recto"),
                ),
                const SizedBox(height: 16),
                PictureCard(
                  title: "Pièce Verso",
                  icon: Icons.credit_card,
                  onTap: () => _takePhoto("verso"),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: CustomButton(
          text: 'Continuer',
          isLoading: false,
          onPressed: () {},
        ),
      ),
    );
  }
}
