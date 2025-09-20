import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/kyc_user.dart';
import '../widgets/custom_button.dart';
import '../widgets/tab_app_bar.dart';
import '../widgets/user_item.dart';
import 'kyc_detail_screen.dart';

class KycManagementScreen extends StatelessWidget {
  const KycManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      const KycUser(
        id: "12345",
        fullName: "Ethan Carter",
        faceUrl: "https://i.pravatar.cc/150?img=1",
        cardRectoUrl: "https://via.placeholder.com/300x200?text=Recto",
        cardVersoUrl: "https://via.placeholder.com/300x200?text=Verso",
        dob: "1990-01-01",
        country: "USA",
      ),
      const KycUser(
        id: "67890",
        fullName: "Olivia Bennett",
        faceUrl: "https://i.pravatar.cc/150?img=2",
        cardRectoUrl: "https://via.placeholder.com/300x200?text=Recto",
        cardVersoUrl: "https://via.placeholder.com/300x200?text=Verso",
        dob: "1992-05-14",
        country: "Canada",
      ),
    ];

    return Scaffold(
      appBar: TabAppBar(
        context: context,
        showBackButton: false,
        titleProp: "KYC Management",
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text("Users", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.shield, color: Colors.white, size: 20),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserItem(
                      user: user,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KycDetailScreen(user: user),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: 'New KYC',
          isLoading: false,
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () => context.go('/kycs/add/id-type'),
        ),
      ),
    );
  }
}
