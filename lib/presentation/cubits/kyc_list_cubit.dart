import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:kyc/core/errors/result_extensions.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/kyc.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/usecases/get_customer_usecase.dart';

part 'kyc_list_state.dart';

class KycListCubit extends Cubit<KycListState> {
  final GetCustomerUsecase getCustomerUsecase;

  KycListCubit(this.getCustomerUsecase) : super(KycListStateInitial());

  Future<void> loadInitialApplications() async {
    emit(KycListStateLoading());

    final result = await getCustomerUsecase.execute().then((result) {
      result.when(
        success: (customers) {
          emit(KycListStateLoaded(customers: customers));
        },
        failure: (error) {
          emit(KycListStateError(error.toString()));
        },
      );
    });
  }
  //
  // Future<void> deleteLocalApplication(String id) async {
  //   final currentState = state;
  //   if (currentState is! KycListStateLoaded) return;
  //
  //   try {
  //     await getCustomerUsecase.deleteLocalApplication(id);
  //
  //     final updatedCustomers = currentState.customers
  //         .where((customer) => customer.id != id)
  //         .toList();
  //
  //     emit(currentState.copyWith(customers: updatedCustomers));
  //
  //   } catch (e) {
  //     emit(KycListStateError('Failed to delete application: $e'));
  //   }
  // }
}