// lib/models/invoice_model.dart

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String invoiceType;
  final String bookingId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final DateTime invoiceDate;
  final DateTime dueDate;

  // Base Pricing & Taxes
  final double baseAmount;
  final List<dynamic>? additionalItems;
  final double totalAdditionalAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double discountAmount;
  final double totalAmount;

  // Settlements
  final int electricityUnitsConsumed;
  final double electricityCharges;
  final double cleaningCharges;
  final double generatorCharges;
  final List<dynamic>? damagesAndPenalties;
  final double totalDeductions;
  final double securityDepositHeld;
  final double finalRefundAmount;
  final double additionalBalanceDue;
  final String settlementMode;

  // Statuses
  final String paymentStatus;
  final String approvalStatus;
  final String? adminRemarks;
  final String? invoicePdfUrl;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceType,
    required this.bookingId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.invoiceDate,
    required this.dueDate,
    this.baseAmount = 0,
    this.additionalItems,
    this.totalAdditionalAmount = 0,
    this.cgstAmount = 0,
    this.sgstAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.electricityUnitsConsumed = 0,
    this.electricityCharges = 0,
    this.cleaningCharges = 0,
    this.generatorCharges = 0,
    this.damagesAndPenalties,
    this.totalDeductions = 0,
    this.securityDepositHeld = 0,
    this.finalRefundAmount = 0,
    this.additionalBalanceDue = 0,
    this.settlementMode = 'ONLINE',
    this.paymentStatus = 'PENDING',
    this.approvalStatus = 'PENDING_ADMIN_APPROVAL',
    this.adminRemarks,
    this.invoicePdfUrl,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      invoiceType: json['invoiceType'] ?? 'GENERAL',
      bookingId: json['bookingId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      invoiceDate: json['invoiceDate'] != null ? DateTime.parse(json['invoiceDate']) : DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      baseAmount: double.tryParse(json['baseAmount']?.toString() ?? '0') ?? 0.0,
      additionalItems: json['additionalItems'],
      totalAdditionalAmount: double.tryParse(json['totalAdditionalAmount']?.toString() ?? '0') ?? 0.0,
      cgstAmount: double.tryParse(json['cgstAmount']?.toString() ?? '0') ?? 0.0,
      sgstAmount: double.tryParse(json['sgstAmount']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      electricityUnitsConsumed: int.tryParse(json['electricityUnitsConsumed']?.toString() ?? '0') ?? 0,
      electricityCharges: double.tryParse(json['electricityCharges']?.toString() ?? '0') ?? 0.0,
      cleaningCharges: double.tryParse(json['cleaningCharges']?.toString() ?? '0') ?? 0.0,
      generatorCharges: double.tryParse(json['generatorCharges']?.toString() ?? '0') ?? 0.0,
      damagesAndPenalties: json['damagesAndPenalties'],
      totalDeductions: double.tryParse(json['totalDeductions']?.toString() ?? '0') ?? 0.0,
      securityDepositHeld: double.tryParse(json['securityDepositHeld']?.toString() ?? '0') ?? 0.0,
      finalRefundAmount: double.tryParse(json['finalRefundAmount']?.toString() ?? '0') ?? 0.0,
      additionalBalanceDue: double.tryParse(json['additionalBalanceDue']?.toString() ?? '0') ?? 0.0,
      settlementMode: json['settlementMode'] ?? 'ONLINE',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      approvalStatus: json['approvalStatus'] ?? 'PENDING_ADMIN_APPROVAL',
      adminRemarks: json['adminRemarks'],
      invoicePdfUrl: json['invoicePdfUrl'],
    );
  }
}
