import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/forms/login_form_cubit.dart';
import '../cubits/login_cubit.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) return context.go('/');
        if (state is LoginError) {
          ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final formState = context.watch<LoginFormCubit>().state;
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        labelText: 'Email',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        onChanged: (value) => context.read<LoginFormCubit>().emailChanged(value),
                        validator: () => !formState.email.isValid ? formState.email.error : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: 'Password',
                        controller: _passwordController,
                        isPassword: true,
                        onChanged: (value) => context.read<LoginFormCubit>().passwordChanged(value),
                        validator: () => !formState.password.isValid ? formState.password.error : null,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Login',
                        isLoading: state is LoginLoading,
                        onPressed: () {
                          formState.isValid ?
                            context.read<LoginCubit>().login(
                              email: formState.email.value,
                              password: formState.password.value,
                            )
                          : null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
