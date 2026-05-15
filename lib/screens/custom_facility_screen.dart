// lib/screens/custom_facility_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../core/config/app_config.dart';
import '../core/di/service_locator.dart';
import '../services/booking_service.dart';
import '../models/facility_model.dart';
import 'booking_form_screen.dart';

class CustomFacilityScreen extends StatefulWidget {
  final List<FacilityModel> atomicFacilities;

  const CustomFacilityScreen({super.key, required this.atomicFacilities});

  @override
  State<CustomFacilityScreen> createState() => _CustomFacilityScreenState();
}

class _CustomFacilityScreenState extends State<CustomFacilityScreen> {
  final Map<String, int> _selectedQuantities = {};

  String _getValidImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    final host = AppConfig.isDevelopment ? AppConfig.devHost : AppConfig.prodHost;
    return rawUrl
        .replaceAll('127.0.0.1', host)
        .replaceAll('localhost', host);
  }

  // Robust parsing to fix the 0 price issue locally
  double get _totalEstimatedPrice {
    double total = 0;
    for (var facility in widget.atomicFacilities) {
      final id = facility.id;
      final qty = _selectedQuantities[id] ?? 0;
      if (qty > 0) {
        total += (facility.baseRate * qty);
      }
    }
    return total;
  }

  void _updateQuantity(String id, int delta, int maxLimit) {
    final facility = widget.atomicFacilities.firstWhere((f) => f.id == id);
    final isMiniHall = (facility.name).toLowerCase().contains('mini hall');

    // 1. Check exclusivity rule
    if (delta > 0) {
      bool otherSelected = false;
      bool miniHallSelected = false;
      
      _selectedQuantities.forEach((key, value) {
        if (value > 0) {
          final f = widget.atomicFacilities.firstWhere((fac) => fac.id == key);
          if (f.name.toLowerCase().contains('mini hall')) miniHallSelected = true;
          else otherSelected = true;
        }
      });

      if (isMiniHall && otherSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mini Hall must be booked separately. Please deselect other items first.'), behavior: SnackBarBehavior.floating)
        );
        return;
      }
      if (!isMiniHall && miniHallSelected) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot add items to a Mini Hall booking. Mini Hall is separate.'), behavior: SnackBarBehavior.floating)
        );
        return;
      }
    }

    setState(() {
      int current = _selectedQuantities[id] ?? 0;
      int next = current + delta;
      if (next >= 0 && next <= maxLimit) {
        _selectedQuantities[id] = next;
      }
    });
  }

  // --- NEW: THE ORANGE PARTIAL AVAILABILITY SHEET ---
  void _showCustomPartialAvailabilitySheet(Map<String, dynamic> data, DateTime sDate, DateTime eDate, String sTime, String eTime) {
    final alternatives = data['availableAlternatives'] as List<dynamic>? ?? [];

    double newTotal = 0;
    for (var alt in alternatives) {
      double rate = double.tryParse(alt['baseRate']?.toString() ?? '0') ?? 0.0;
      int qty = int.tryParse(alt['quantity']?.toString() ?? '1') ?? 1;
      newTotal += (rate * qty);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 28),
                    const SizedBox(width: 12),
                    Text('Partial Availability', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Some items in your custom package are booked for these dates. We can offer this adjusted package:', style: TextStyle(color: Colors.orange.shade900)),
                const SizedBox(height: 16),

                // List of available items
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                  child: Column(
                    children: alternatives.map((alt) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  '${alt['name'] ?? 'Item'} (x${alt['quantity'] ?? 1})',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)
                              )
                          ),
                          Text('₹${alt['baseRate']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('New Total (Base):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 16), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text('₹$newTotal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.orange.shade900)),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the orange sheet

                      // Mock a pricing map for the form
                      Map<String, dynamic> pseudoPricing = {
                        'baseCalculatedAmount': newTotal,
                        'securityDepositRequired': 0, // Fallback
                        'estimatedTotal': newTotal,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingFormScreen(
                            facility: FacilityModel(id: 'custom', name: 'Adjusted Custom Package'),
                            startDate: sDate, endDate: eDate, startTime: sTime, endTime: eTime,
                            pricingData: pseudoPricing,
                            isPartial: true,
                            partialAlternatives: alternatives,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Accept Available Items & Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // --- DATE/TIME SELECTION & AVAILABILITY CHECK ---
  void _showDateSelectionSheet(List<Map<String, dynamic>> selectedFacilities) {
    // 1. Detect Anchor Facility for Timing
    FacilityModel? anchorFacility;
    bool isHourlyMode = false;
    
    for (var f in widget.atomicFacilities) {
      if ((_selectedQuantities[f.id] ?? 0) > 0) {
        final type = f.pricingType;
        if (type == 'HOURLY' || type == 'SLOT') {
          isHourlyMode = true;
          anchorFacility = f;
          break; 
        }
      }
    }

    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = isHourlyMode ? startDate : DateTime.now().add(const Duration(days: 2));
    
    // 2. FORCE Fixed Timings for all Custom Bookings
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = isHourlyMode ? const TimeOfDay(hour: 16, minute: 0) : const TimeOfDay(hour: 8, minute: 0);
    bool isTimeFixed = true; // LOCK ALL as requested

    if (anchorFacility != null) {
      final details = anchorFacility.pricingDetails;
      if (details != null) {
        if (details['slotType'] == 'FIXED' && details['slots'] != null && (details['slots'] as List).isNotEmpty) {
          final slot = (details['slots'] as List)[0];
          final startParts = (slot['startTime'] as String).split(':');
          final endParts = (slot['endTime'] as String).split(':');
          startTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
          endTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
        } 
        else if (anchorFacility.pricingType == 'HOURLY' && anchorFacility.name.toLowerCase().contains('mini hall')) {
          startTime = const TimeOfDay(hour: 18, minute: 0);
          endTime = const TimeOfDay(hour: 23, minute: 0);
        }
      }
    }

    bool isChecking = false;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                Future<void> pickDate(bool isStart) async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: isStart ? startDate : endDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).colorScheme.primary,
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setModalState(() {
                      if (isStart) {
                        startDate = picked;
                        if (isHourlyMode) endDate = picked; 
                      } else {
                        endDate = picked;
                      }
                      if (endDate.isBefore(startDate)) endDate = startDate;
                    });
                  }
                }

                return Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 24,
                      left: 24, right: 24, top: 24
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(height: 20),
                        Text(
                            isHourlyMode ? 'Event Date & Fixed Schedule' : 'Stay Dates & Fixed Times',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Timings for these facilities are standardized for optimal operations.',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])
                        ),
                        const SizedBox(height: 24),

                        // Selection Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                          child: Column(
                            children: [
                              if (isHourlyMode)
                                _buildSelectionTile(
                                  label: 'Event Date',
                                  value: DateFormat('EEEE, MMM dd, yyyy').format(startDate),
                                  icon: Icons.calendar_today,
                                  color: Colors.indigo,
                                  onTap: () => pickDate(true),
                                )
                              else ...[
                                _buildSelectionTile(
                                  label: 'Check-in Date',
                                  value: DateFormat('MMM dd, yyyy').format(startDate),
                                  icon: Icons.login,
                                  color: Colors.green,
                                  onTap: () => pickDate(true),
                                ),
                                const Divider(height: 24),
                                _buildSelectionTile(
                                  label: 'Check-out Date',
                                  value: DateFormat('MMM dd, yyyy').format(endDate),
                                  icon: Icons.logout,
                                  color: Colors.redAccent,
                                  onTap: () => pickDate(false),
                                ),
                              ],
                              
                              const Divider(height: 32, thickness: 1),

                              // TIME PICKERS (Locked)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSelectionTile(
                                      label: isHourlyMode ? 'Start Time' : 'Check-in Time',
                                      value: startTime.format(context),
                                      icon: Icons.lock_clock,
                                      color: Colors.grey,
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Timings are fixed for custom bookings.'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating)
                                        );
                                      },
                                    ),
                                  ),
                                  Container(height: 40, width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),
                                  Expanded(
                                    child: _buildSelectionTile(
                                      label: isHourlyMode ? 'End Time' : 'Check-out Time',
                                      value: endTime.format(context),
                                      icon: Icons.lock_clock,
                                      color: Colors.grey,
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Timings are fixed for custom bookings.'), duration: Duration(seconds: 1), behavior: SnackBarBehavior.floating)
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // VERIFY AVAILABILITY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: Theme.of(this.context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                            ),
                            onPressed: isChecking ? null : () async {
                              setModalState(() => isChecking = true);

                              final startTimeStr = "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}";
                              final endTimeStr = "${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}";

                              final response = await getIt<BookingService>().checkAvailabilityAndPrice(
                                customFacilities: selectedFacilities,
                                startDate: startDate, endDate: endDate,
                                startTime: startTimeStr, endTime: endTimeStr,
                              );

                              setModalState(() => isChecking = false);

                              if (response['success']) {
                                final responseData = response['data'];
                                final bool isAvailable = responseData['isAvailable'] == true;
                                final bool isPartiallyAvailable = responseData['isPartiallyAvailable'] == true;

                                Navigator.pop(ctx); 

                                if (isAvailable) {
                                  Navigator.push(
                                      this.context,
                                      MaterialPageRoute(
                                          builder: (_) => BookingFormScreen(
                                            facility: FacilityModel(id: 'custom', name: 'Custom Package'),
                                            startDate: startDate, endDate: endDate,
                                            startTime: startTimeStr, endTime: endTimeStr,
                                            pricingData: responseData,
                                            isPartial: true,
                                            partialAlternatives: selectedFacilities,
                                          )
                                      )
                                  );
                                }
                                else if (isPartiallyAvailable) {
                                  _showCustomPartialAvailabilitySheet(responseData, startDate, endDate, startTimeStr, endTimeStr);
                                }
                                else {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(content: Text(responseData['message'] ?? 'Dates are fully booked.'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text(response['message'] ?? 'Failed to verify dates.'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
                                );
                              }
                            },
                            child: isChecking
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Check Availability & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildSelectionTile({required String label, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Custom Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black87, elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.atomicFacilities.length,
              itemBuilder: (context, index) {
                final facility = widget.atomicFacilities[index];
                final id = facility.id;
                final name = facility.name;

                double displayPrice = facility.baseRate;
                final inventoryCount = facility.inventoryCount;

                String? rawImageUrl = (facility.images.isNotEmpty) ? facility.images[0] : null;
                final validImageUrl = _getValidImageUrl(rawImageUrl);

                final isSelected = (_selectedQuantities[id] ?? 0) > 0;
                final qty = _selectedQuantities[id] ?? 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          height: 80, width: 80,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                          clipBehavior: Clip.antiAlias,
                          child: validImageUrl.isNotEmpty
                              ? CachedNetworkImage(imageUrl: validImageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.apartment, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('₹${displayPrice.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        inventoryCount > 1
                            ? Row(
                          children: [
                            IconButton(icon: const Icon(Icons.remove_circle_outline), color: qty > 0 ? Colors.redAccent : Colors.grey, onPressed: () => _updateQuantity(id, -1, inventoryCount)),
                            Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(icon: const Icon(Icons.add_circle_outline), color: qty < inventoryCount ? Theme.of(context).colorScheme.primary : Colors.grey, onPressed: () => _updateQuantity(id, 1, inventoryCount)),
                          ],
                        )
                            : Checkbox(
                                value: isSelected,
                                activeColor: Theme.of(context).colorScheme.primary,
                                onChanged: (val) {
                                  if (val == true) {
                                    // Reuse exclusivity check
                                    final isMiniHall = name.toLowerCase().contains('mini hall');
                                    bool otherSelected = false;
                                    bool miniHallSelected = false;
                                    _selectedQuantities.forEach((key, value) {
                                      if (value > 0) {
                                        final f = widget.atomicFacilities.firstWhere((fac) => fac.id == key);
                                        if (f.name.toLowerCase().contains('mini hall')) miniHallSelected = true;
                                        else otherSelected = true;
                                      }
                                    });

                                    if (isMiniHall && otherSelected) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Mini Hall must be booked separately. Please deselect other items first.'), behavior: SnackBarBehavior.floating)
                                      );
                                      return;
                                    }
                                    if (!isMiniHall && miniHallSelected) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cannot add items to a Mini Hall booking. Mini Hall is separate.'), behavior: SnackBarBehavior.floating)
                                      );
                                      return;
                                    }
                                    setState(() => _selectedQuantities[id] = 1);
                                  } else {
                                    setState(() => _selectedQuantities[id] = 0);
                                  }
                                }
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BOTTOM STICKY BAR
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Estimated Total', style: TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis),
                        Text('₹$_totalEstimatedPrice', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _totalEstimatedPrice > 0 ? () {
                      final List<Map<String, dynamic>> selectedFacilities = [];
                      _selectedQuantities.forEach((id, qty) {
                        if (qty > 0) selectedFacilities.add({'facilityId': id, 'quantity': qty});
                      });
                      _showDateSelectionSheet(selectedFacilities);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}