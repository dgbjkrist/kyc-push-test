import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/service_locator.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/kyc_user.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../../domain/usecases/get_customer_usecase.dart';
import '../cubits/kyc_list_cubit.dart';
import '../cubits/logout_cubit.dart';
import '../widgets/custom_button.dart';
import '../widgets/customer_item.dart';
import '../widgets/tab_app_bar.dart';
import '../widgets/user_item.dart';
import 'kyc_detail_screen.dart';

class KycManagementScreen extends StatefulWidget {
  const KycManagementScreen({super.key});

  @override
  State<KycManagementScreen> createState() => _KycManagementScreenState();
}

class _KycManagementScreenState extends State<KycManagementScreen> {

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final cubit = sl<KycListCubit>();

    final currentState = cubit.state;
    if (currentState is! KycListStateLoaded) {
      cubit.loadInitialApplications();
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      await context.read<LogoutCubit>().logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<KycListCubit>(),
      child: Scaffold(
        appBar: TabAppBar(
          context: context,
          showBackButton: false,
          titleProp: "KYC Management",
          centerTitle: false,
          actionsProp: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black,),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Déconnexion', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: const _KycListView(),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'New KYC',
            isLoading: false,
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.go('/kycs/add/id-type'),
          ),
        ),
      ),
    );
  }
}

class _KycListView extends StatelessWidget {
  const _KycListView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KycListCubit, KycListState>(
      listener: (context, state) {
      },
      builder: (context, state) {
        if (state is KycListStateInitial || state is KycListStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is KycListStateError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is KycListStateLoaded) {
          return _buildList(context, state.customers);
        }
        return const Center(child: Text('No KYC applications found'));
      },
    );
  }

  Widget _buildList(BuildContext context,
      List<Customer> applications,) {
    if (applications.isEmpty) {
      return const Center(child: Text('No KYC applications found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Users",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView.separated(
                itemCount: applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final application = applications[index];
                  return CustomerItem(
                    customer: application,
                    onTap: () => _navigateToDetail(context, application),
                    onDelete: application.isLocal
                        ? () => _deleteApplication(context, application)
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KycDetailScreen(customer: customer),
      ),
    );
  }

  void _deleteApplication(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Application'),
            content: const Text(
                'Are you sure you want to delete this local application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // context.read<KycListCubit>().deleteLocalApplication(customer.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
