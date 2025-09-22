import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/kyc.dart';
import '../cubits/forms/kyc_form_cubit.dart';
import '../cubits/kyc_cubit.dart';
import '../cubits/logout_cubit.dart';
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

  Future<void> _showSubmitConfirmation() async {
    final kycFormState = context.read<KycFormCubit>().state;
    if (kycFormState is! KycFormStateChanged) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soumettre le KYC'),
        content: const Text('Êtes-vous sûr de vouloir soumettre ce formulaire KYC ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );

    if (result == true) {
      context.read<KycCubit>().submit(kycFormState.toEntity());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycFormCubit, KycFormState>(
  listener: (context, state) {
    print("state ::::::: ${state.toString()} $state");
    if(state is KycFormStateChanged) {
      fullNameController.text = state.fullName.value;
      nationalityController.text = state.nationality.value;
      dobController.text = state.dateOfBirth.value;
    }

    if (state is KycStateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC soumis avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (state is KycFormStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la soumission: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  builder: (context, state) {
    KycFormStateChanged? kycFormState;
    if (state is KycFormStateChanged) {
      kycFormState = state;
    }
    return AbsorbPointer(
      absorbing: state is KycStateLoading,
      child: Scaffold(
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
                    path: state is KycFormStateChanged ? state.faceImagePath : null,
                  ),
                  FramePhotoKyc(
                    title: "Pièce Recto",
                    subtitle: "Prenez en photo la partie recto document en vous assurant que les informations sont bien visibles",
                    onTap: () => _takePhoto("recto"),
                    path: state is KycFormStateChanged ? state.cardRectoPath : null,
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
                        errorText: kycFormState?.fullName.isValid != true
                            ? kycFormState?.fullName.error
                            : null,
                        onChanged: (value) => context.read<KycFormCubit>().updateFullName(value),
                      ),
                      CustomTextField(
                        labelText: 'Date of birthday',
                        controller: dobController,
                        errorText: kycFormState?.dateOfBirth.isValid != true
                            ? kycFormState?.dateOfBirth.error
                            : null,
                        onChanged: (value) => context.read<KycFormCubit>().updateDob(value),
                      ),
                      CustomTextField(
                        labelText: 'Nationnality',
                        controller: nationalityController,
                        errorText: kycFormState?.nationality.isValid != true
                            ? kycFormState?.nationality.error
                            : null,
                        onChanged: (value) => context.read<KycFormCubit>().updateNationality(value),
                      ),
                    ],
                  ),
                  FramePhotoKyc(
                    title: "Pièce Verso",
                    subtitle: "Prenez en photo la pièce en vous assurant que les informations sont bien visibles",
                    onTap: () => _takePhoto("verso"),
                    path: state is KycFormStateChanged ? state.cardVersoPath : null,
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
            isLoading: state is KycStateLoading,
            onPressed: _showSubmitConfirmation
          ),
        ),
      ),
    );
  },
);
  }
}
