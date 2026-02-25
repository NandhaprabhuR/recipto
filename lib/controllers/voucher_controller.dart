import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipto/models/voucher_model.dart';
import 'package:recipto/repositories/voucher_repository.dart';

class VoucherState {
  final bool isLoading;
  final String? errorMessage;
  final VoucherModel? voucher;
  final double amount;
  final int quantity;
  final String selectedMethod;
  final double discountAmount;
  final double youPay;
  final double savings;
  final bool isDisabled;

  const VoucherState({
    this.isLoading = true,
    this.errorMessage,
    this.voucher,
    this.amount = 0.0,
    this.quantity = 1,
    this.selectedMethod = 'UPI',
    this.discountAmount = 0.0,
    this.youPay = 0.0,
    this.savings = 0.0,
    this.isDisabled = true,
  });

  VoucherState copyWith({
    bool? isLoading,
    String? errorMessage,
    VoucherModel? voucher,
    double? amount,
    int? quantity,
    String? selectedMethod,
    double? discountAmount,
    double? youPay,
    double? savings,
    bool? isDisabled,
  }) {
    return VoucherState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      voucher: voucher ?? this.voucher,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      youPay: youPay ?? this.youPay,
      savings: savings ?? this.savings,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}

class VoucherController extends Notifier<VoucherState> {
  @override
  VoucherState build() {
    return const VoucherState();
  }

  StreamSubscription<VoucherModel?>? _subscription;

  Future<void> loadVoucher(String voucherId) async {
    _subscription?.cancel();

    final repository = ref.read(voucherRepositoryProvider);

    _subscription = repository
        .watchVoucher(voucherId)
        .listen(
          (voucher) {
            if (voucher != null) {
              state = state.copyWith(isLoading: false, voucher: voucher);
              _recalculate();
            } else {
              state = state.copyWith(
                isLoading: false,
                errorMessage: 'Voucher not found in database.',
              );
            }
          },
          onError: (e) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: e.toString(),
            );
          },
        );

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  void setAmount(double amount) {
    if (state.amount != amount) {
      state = state.copyWith(amount: amount);
      _recalculate();
    }
  }

  void incrementQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
    _recalculate();
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
      _recalculate();
    }
  }

  void setPaymentMethod(String method) {
    if (state.selectedMethod != method) {
      state = state.copyWith(selectedMethod: method);
      _recalculate();
    }
  }

  void _recalculate() {
    if (state.voucher == null) return;

    final voucher = state.voucher!;
    final amount = state.amount;
    final quantity = state.quantity;
    final selectedMethod = state.selectedMethod;

    double percent = 0;
    try {
      final discountInfo = voucher.discounts.firstWhere(
        (d) => d.method.toUpperCase() == selectedMethod.toUpperCase(),
      );
      percent = discountInfo.percent;
    } catch (_) {
      // Ignored
    }

    double discountAmount = amount * (percent / 100);
    double youPay = (amount - discountAmount) * quantity;
    double savings = discountAmount * quantity;

    bool isAmountValid =
        amount >= voucher.minAmount && amount <= voucher.maxAmount;
    bool isDisabled = voucher.disablePurchase || !isAmountValid || youPay <= 0;

    state = state.copyWith(
      discountAmount: discountAmount,
      youPay: youPay,
      savings: savings,
      isDisabled: isDisabled,
    );
  }
}

final voucherControllerProvider =
    NotifierProvider<VoucherController, VoucherState>(VoucherController.new);
