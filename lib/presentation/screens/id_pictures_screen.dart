import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/forms/kyc_form_cubit.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/frame_photo_kyc.dart';
import '../widgets/tab_app_bar.dart';

class IdPicturesScreen extends StatefulWidget {
  const IdPicturesScreen({super.key});

  @override
  State<IdPicturesScreen> createState() => _IdPicturesScreenState();
}

class _IdPicturesScreenState extends State<IdPicturesScreen> {

  late TextEditingController fullNameController;
  late TextEditingController nationalityController;
  late TextEditingController dobController;

  @override
  void initState() {
    fullNameController = TextEditingController();
    nationalityController = TextEditingController();
    dobController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nationalityController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void _takePhoto(String type) {
    context.read<KycFormCubit>().processImage(type);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycFormCubit, KycFormState>(
  listener: (context, state) {
    if(state is KycFormStateChanged) {
      fullNameController.text = state.fullName.value;
      nationalityController.text = state.nationality.value;
      dobController.text = state.dateOfBirth.value;
    }
  },
  builder: (context, state) {
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
                FramePhotoKyc(
                  title: "Photo Visage",
                  subtitle: "Prenez la photo en vous assurant que le visage soit bien eclairé",
                  onTap: () => _takePhoto("face"),
                ),
                FramePhotoKyc(
                  title: "Pièce Recto",
                  subtitle: "Prenez en photo la partie recto document en vous assurant que les informations sont bien visibles",
                  onTap: () => _takePhoto("recto"),
                ),
                Column(
                  children: [
                    Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                        children: [
                          Icon(Icons.contact_mail_outlined, color: AppColors.colorGrey,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Informations personnelles", style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ]
                    ),
                  ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("Pre-fill via OCR... check and correct if necessary", style: TextStyle(color: Colors.grey[600])),
                    ),
                    CustomTextField(
                      labelText: 'Full name',
                      controller: fullNameController,
                      onChanged: (value) => context.read<KycFormCubit>().updateFullName(value),
                    ),
                    CustomTextField(
                      labelText: 'Date of birthday',
                      controller: dobController,
                      onChanged: (value) => context.read<KycFormCubit>().updateDob(value),
                    ),
                    CustomTextField(
                      labelText: 'Nationnality',
                      controller: nationalityController,
                      onChanged: (value) => context.read<KycFormCubit>().updateNationality(value),
                    ),
                  ],
                ),
                FramePhotoKyc(
                  title: "Pièce Verso",
                  subtitle: "Prenez en photo la pièce en vous assurant que les informations sont bien visibles",
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
  },
);
  }
}
