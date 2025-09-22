import 'package:flutter/material.dart';

import '../../domain/entities/customer.dart';

class CustomerItem extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CustomerItem({
    required this.customer,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            'https://i.pravatar.cc/150?u=${customer.id}',
          ),
        ),
        title: Text(customer.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DOB: ${customer.dateOfBirth.toLocal()}'),
            Text('Nationality: ${customer.nationality}'),
            if (customer.isLocal) _buildLocalTag(),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildLocalTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'LOCAL',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}