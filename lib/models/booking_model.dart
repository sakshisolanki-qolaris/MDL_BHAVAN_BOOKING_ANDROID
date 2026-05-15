import 'facility_model.dart';

class BookingSchedule {
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? actualCheckInTime;
  final DateTime? actualCheckOutTime;

  BookingSchedule({
    this.startTime,
    this.endTime,
    this.actualCheckInTime,
    this.actualCheckOutTime,
  });

  factory BookingSchedule.fromJson(Map<String, dynamic> json) {
    return BookingSchedule(
      startTime: json['startTime'] != null ? DateTime.tryParse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      actualCheckInTime: json['actualCheckInTime'] != null ? DateTime.tryParse(json['actualCheckInTime']) : null,
      actualCheckOutTime: json['actualCheckOutTime'] != null ? DateTime.tryParse(json['actualCheckOutTime']) : null,
    );
  }
}

class BookingFinancials {
  final double calculatedAmount;
  final double securityDeposit;
  final double holdAmountPaid;
  final double advanceAmountRequested;
  final double remainingAmountPaid;
  final double refundAmount;
  final String? paymentStatus;
  final bool isHoldingAllowed;
  final double holdingPercentage;
  final DateTime? holdDeadline;

  BookingFinancials({
    this.calculatedAmount = 0,
    this.securityDeposit = 0,
    this.holdAmountPaid = 0,
    this.advanceAmountRequested = 0,
    this.remainingAmountPaid = 0,
    this.refundAmount = 0,
    this.paymentStatus,
    this.isHoldingAllowed = false,
    this.holdingPercentage = 0,
    this.holdDeadline,
  });

  factory BookingFinancials.fromJson(Map<String, dynamic> json) {
    return BookingFinancials(
      calculatedAmount: double.tryParse(json['calculatedAmount']?.toString() ?? '0') ?? 0.0,
      securityDeposit: double.tryParse(json['securityDeposit']?.toString() ?? '0') ?? 0.0,
      holdAmountPaid: double.tryParse(json['holdAmountPaid']?.toString() ?? '0') ?? 0.0,
      advanceAmountRequested: double.tryParse(json['advanceAmountRequested']?.toString() ?? '0') ?? 0.0,
      remainingAmountPaid: double.tryParse(json['remainingAmountPaid']?.toString() ?? '0') ?? 0.0,
      refundAmount: double.tryParse(json['refundAmount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: json['paymentStatus'],
      isHoldingAllowed: json['isHoldingAllowed'] ?? false,
      holdingPercentage: double.tryParse(json['holdingPercentage']?.toString() ?? '0') ?? 0.0,
      holdDeadline: json['holdDeadline'] != null ? DateTime.tryParse(json['holdDeadline']) : null,
    );
  }
}

class BookingModel {
  final String id;
  final String? bookingId;
  final String status;
  final String? eventType;
  final int guestCount;
  final FacilityModel? facility;
  final BookingSchedule? schedule;
  final BookingFinancials? financials;
  final Map<String, dynamic>? verification;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  BookingModel({
    required this.id,
    this.bookingId,
    required this.status,
    this.eventType,
    this.guestCount = 0,
    this.facility,
    this.schedule,
    this.financials,
    this.verification,
    this.cancellationReason,
    this.cancelledAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString(),
      status: json['status'] ?? 'PENDING',
      eventType: json['eventType'],
      guestCount: int.tryParse(json['guestCount']?.toString() ?? '0') ?? 0,
      facility: json['facility'] != null ? FacilityModel.fromJson(json['facility']) : null,
      schedule: json['schedule'] != null ? BookingSchedule.fromJson(json['schedule']) : null,
      financials: json['financials'] != null ? BookingFinancials.fromJson(json['financials']) : null,
      verification: json['verification'],
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.tryParse(json['cancelledAt']) : null,
    );
  }
}

