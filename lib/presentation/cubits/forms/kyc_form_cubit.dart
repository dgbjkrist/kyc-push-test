import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kyc/domain/value_objects/full_name.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../core/image_picker/image_picker_service.dart';
import '../../../core/ocr/ocr_service.dart';
import '../../../domain/entities/kyc.dart';
import '../../../domain/value_objects/date_of_birth.dart';
import '../../../domain/value_objects/nationality.dart';

part 'kyc_form_state.dart';

class KycFormCubit extends Cubit<KycFormState> {
  final OcrService ocr;
  final ImagePickerService imagePickerService;
  KycFormCubit(this.ocr, this.imagePickerService) : super(KycFormStateInitial());

  void pickIdType(String v) {
    if (state case KycFormStateChanged s) emit(s.copyWith(idType: v));
  }

  Future<void> processImage(String slot) async {
    print("Processing image $slot");
    final image = await imagePickerService.pickImage();

    if (image == null) {
      print("Image is null");
      emit(KycFormStateError("An error occured while taking picture"));
      return ;
    }

    KycFormStateChanged kycFormStateChanged;

    if (state is KycFormStateChanged) {
      kycFormStateChanged = state as KycFormStateChanged;
    } else {
      print("State is not KycFormStateChanged");
      kycFormStateChanged = KycFormStateChanged(
        idType: "",
        fullName: FullName(""),
        dateOfBirth: DateOfBirth(""),
        nationality: Nationality(""),
        faceImagePath: "",
        cardRectoPath: "",
        cardVersoPath: "",
      );
    }
    final path = image.path;
    ExtractedInfo? extractedInfo;
    if (slot == 'face') kycFormStateChanged = kycFormStateChanged.copyWith(faceImagePath: path);
    if (slot == 'recto') {
      kycFormStateChanged = kycFormStateChanged.copyWith(cardRectoPath: path);
      extractedInfo = await ocr.extractFromImage(path);
    }
    if (slot == 'verso') kycFormStateChanged = kycFormStateChanged.copyWith(cardRectoPath: path);
    print("Extracted info: ${extractedInfo?.dateOfBirth}");
    print("Extracted info: ${extractedInfo?.fullName}");
    print("Extracted info: ${extractedInfo?.nationality}");
    try {

      if (extractedInfo != null) {
        if (extractedInfo.fullName.isNotEmpty) kycFormStateChanged = kycFormStateChanged.copyWith(fullName: FullName(extractedInfo.fullName));
        if (extractedInfo.dateOfBirth.isNotEmpty) kycFormStateChanged = kycFormStateChanged.copyWith(dateOfBirth: DateOfBirth(extractedInfo.dateOfBirth));
        if (extractedInfo.nationality.isNotEmpty) kycFormStateChanged = kycFormStateChanged.copyWith(nationality: Nationality(extractedInfo.nationality));
      }
    } catch (e) {}
    emit(kycFormStateChanged);
  }

  void pickIdVerso(String path) {
    if (state case KycFormStateChanged s) {
      emit(s.copyWith(cardVersoPath: path));
    }
  }

  void updateFullName(String v) {
    if (state case KycFormStateChanged s) {
      emit(s.copyWith(fullName: FullName(v)));
    }
  }

  void updateDob(String v) {
    if (state case KycFormStateChanged s) {
      emit(s.copyWith(dateOfBirth: DateOfBirth(v)));
    }
  }

  void updateNationality(String v) {
    if (state case KycFormStateChanged s) {
      emit(s.copyWith(nationality: Nationality(v)));
    }
  }
}
