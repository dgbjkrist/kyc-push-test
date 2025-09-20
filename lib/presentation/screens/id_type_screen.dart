import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kyc/presentation/widgets/tab_app_bar.dart';

import '../cubits/forms/kyc_form_cubit.dart';
import '../widgets/id_type_row.dart';

class IdTypeScreen extends StatefulWidget {
  const IdTypeScreen({super.key});

  @override
  State<IdTypeScreen> createState() => _IdTypeScreenState();
}

class _IdTypeScreenState extends State<IdTypeScreen> {
  
  void goToTakePicture(String value) {
    print("value $value");
    context.read<KycFormCubit>().pickIdType(value);
    context.go('/kycs/add/take-picture');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabAppBar(context: context, showBackButton: true, titleProp: "Identification",),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Text("Choisissez votre document d'identification",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 25, right: 25, top: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.0),
                    IdTypeRow(
                        title: "CNI",
                        textImage: Placeholder(),
                        action: () => goToTakePicture("cni")
                    ),
                    IdTypeRow(
                        title: "Passport",
                        textImage: Placeholder(),
                        action: () => goToTakePicture("passport")
                    ),
                    IdTypeRow(
                        title: "Driver licence",
                        textImage: Placeholder(),
                        action: () => goToTakePicture("driverLicence")
                    ),
                    IdTypeRow(
                        title: "Carte consulaire/ Titre de sejour",
                        textImage: Placeholder(),
                        action: () => goToTakePicture("residencePermit")
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}