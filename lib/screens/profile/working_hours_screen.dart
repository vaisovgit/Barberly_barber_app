import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/barber_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/barber.dart';

class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  Map<String, WorkingHours> workingHours = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final barber = ref.read(currentBarberProvider).value;
      if (barber?.workingHours != null) {
        setState(() {
          workingHours = Map.from(barber!.workingHours!);
        });
      } else {
        _initializeDefaultHours();
      }
    });
  }

  void _initializeDefaultHours() {
    setState(() {
      for (var day in days) {
        workingHours[day] = WorkingHours(
          startTime: '09:00',
          endTime: '18:00',
          isWorking: day != 'Sunday',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Hours'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveWorkingHours,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final hours =
              workingHours[day] ??
              WorkingHours(
                startTime: '09:00',
                endTime: '18:00',
                isWorking: false,
              );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: hours.isWorking,
                        onChanged: (value) {
                          setState(() {
                            workingHours[day] = WorkingHours(
                              startTime: hours.startTime,
                              endTime: hours.endTime,
                              isWorking: value,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  if (hours.isWorking) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeSelector(
                            label: 'Start',
                            time: hours.startTime,
                            onChanged: (time) {
                              setState(() {
                                workingHours[day] = WorkingHours(
                                  startTime: time,
                                  endTime: hours.endTime,
                                  isWorking: hours.isWorking,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _TimeSelector(
                            label: 'End',
                            time: hours.endTime,
                            onChanged: (time) {
                              setState(() {
                                workingHours[day] = WorkingHours(
                                  startTime: hours.startTime,
                                  endTime: time,
                                  isWorking: hours.isWorking,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveWorkingHours() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) return;

      await ref
          .read(barberServiceProvider)
          .updateWorkingHours(currentUser.uid, workingHours);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Working hours updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final Function(String) onChanged;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final parts = time.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );

        if (picked != null) {
          final formattedTime =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
