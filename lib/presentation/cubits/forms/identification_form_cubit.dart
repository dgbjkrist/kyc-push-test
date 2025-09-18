import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'identification_form_state.dart';

class IdentificationFormCubit extends Cubit<IdentificationFormState> {
  IdentificationFormCubit() : super(IdentificationFormInitial());
}
