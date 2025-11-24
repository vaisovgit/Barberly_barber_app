// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/barber_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../models/barber.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barber = ref.watch(currentBarberProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: barber.when(
        data: (data) {
          if (data == null) return const Center(child: Text('No data'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.services.length + 1,
            itemBuilder: (context, index) {
              if (index == data.services.length) {
                return Card(
                  child: InkWell(
                    onTap: () => _showServiceDialog(context, ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Color(0xFF2C3E50)),
                          const SizedBox(width: 8),
                          Text(
                            'Add Service',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final service = data.services[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${service.durationMinutes} min'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showServiceDialog(context, ref, service);
                          } else if (value == 'delete') {
                            _deleteService(context, ref, service.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showServiceDialog(
    BuildContext context,
    WidgetRef ref, [
    Services? service,
  ]) {
    final nameController = TextEditingController(text: service?.name);
    final priceController = TextEditingController(
      text: service?.price.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: service?.durationMinutes.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: service?.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final duration =
                  int.tryParse(durationController.text.trim()) ?? 30;
              final description = descriptionController.text.trim();

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                  ),
                );
                return;
              }

              final currentUser = ref.read(authStateProvider).value;
              if (currentUser == null) return;

              final newService = Services(
                id:
                    service?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                price: price,
                durationMinutes: duration,
                description: description.isEmpty ? null : description,
              );

              try {
                if (service == null) {
                  await ref
                      .read(barberServiceProvider)
                      .addService(currentUser.uid, newService);
                } else {
                  await ref
                      .read(barberServiceProvider)
                      .updateService(currentUser.uid, newService);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      service == null ? 'Service added' : 'Service updated',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(service == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(
    BuildContext context,
    WidgetRef ref,
    String serviceId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) return;

      try {
        await ref
            .read(barberServiceProvider)
            .deleteService(currentUser.uid, serviceId);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Service deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
