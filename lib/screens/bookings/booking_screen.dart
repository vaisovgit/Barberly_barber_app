import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import 'booking_detail_screen.dart';

enum BookingFilterType { all, today, upcoming, past }

final bookingFilterProvider = StateProvider<BookingFilterType>(
  (ref) => BookingFilterType.today,
);

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterType = ref.watch(bookingFilterProvider);

    BookingFilter filter;
    final now = DateTime.now();

    switch (filterType) {
      case BookingFilterType.today:
        filter = BookingFilter(
          startDate: DateTime(now.year, now.month, now.day),
          endDate: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
        break;
      case BookingFilterType.upcoming:
        filter = BookingFilter(
          startDate: DateTime(
            now.year,
            now.month,
            now.day,
          ).add(const Duration(days: 1)),
        );
        break;
      case BookingFilterType.past:
        filter = BookingFilter(
          endDate: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(seconds: 1)),
        );
        break;
      default:
        filter = BookingFilter();
    }

    final bookings = ref.watch(bookingsProvider);
    // debugPrint(
    //   '🔍 Filter: $filterType | Start: ${filter.startDate?.toIso8601String()} | End: ${filter.endDate?.toIso8601String()} | Now: $now',
    // );
    // final user = ref.watch(authStateProvider).value;
    // debugPrint('👤 UID: ${user?.uid ?? "NULL"} (ожидаемо: barber123)');

    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _FilterChip(
                    label: 'Today',
                    isSelected: filterType == BookingFilterType.today,
                    onTap: () {
                      ref.read(bookingFilterProvider.notifier).state =
                          BookingFilterType.today;
                      debugPrint(bookings.toString());
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Upcoming',
                    isSelected: filterType == BookingFilterType.upcoming,
                    onTap: () =>
                        ref.read(bookingFilterProvider.notifier).state =
                            BookingFilterType.upcoming,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'Past',
                    isSelected: filterType == BookingFilterType.past,
                    onTap: () =>
                        ref.read(bookingFilterProvider.notifier).state =
                            BookingFilterType.past,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterChip(
                    label: 'All',
                    isSelected: filterType == BookingFilterType.all,
                    onTap: () =>
                        ref.read(bookingFilterProvider.notifier).state =
                            BookingFilterType.all,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookings.when(
              data: (data) {
                debugPrint('$data');
                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(bookingsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final booking = data[index];
                      return _BookingListItem(booking: booking);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C3E50) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BookingListItem extends StatelessWidget {
  final Booking booking;

  const _BookingListItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: booking.clientImageUrl != null
                        ? NetworkImage(booking.clientImageUrl!)
                        : null,
                    child: booking.clientImageUrl == null
                        ? Text(
                            booking.clientName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.clientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (booking.clientPhone != null)
                          Text(
                            booking.clientPhone!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _StatusChip(status: booking.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEE, MMM d, yyyy').format(booking.dateTime),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('HH:mm').format(booking.dateTime)} (${booking.totalDuration} min)',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.cut, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.services.map((s) => s.name).join(', '),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case BookingStatus.newBooking:
        color = Colors.blue;
        text = 'New';
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case BookingStatus.completed:
        color = Colors.grey;
        text = 'Completed';
        break;
      case BookingStatus.canceled:
        color = Colors.red;
        text = 'Canceled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
