import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipto/controllers/voucher_controller.dart';
import 'package:recipto/models/voucher_model.dart';

final voucherControllerProvider =
    NotifierProvider<VoucherController, VoucherState>(VoucherController.new);

class VoucherPurchaseScreen extends ConsumerStatefulWidget {
  final String voucherId;

  const VoucherPurchaseScreen({super.key, required this.voucherId});

  @override
  ConsumerState<VoucherPurchaseScreen> createState() =>
      _VoucherPurchaseScreenState();
}

class _VoucherPurchaseScreenState extends ConsumerState<VoucherPurchaseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _focusNode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The voucherId is now passed to the controller's loadVoucher method directly
      ref
          .read(voucherControllerProvider.notifier)
          .loadVoucher(widget.voucherId);
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    final val = double.tryParse(text) ?? 0;
    ref.read(voucherControllerProvider.notifier).setAmount(val);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voucherControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(VoucherState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }

    if (state.voucher == null) {
      return const Center(child: Text('Voucher not found.'));
    }

    final voucher = state.voucher!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            _buildHeader(voucher),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildAmountInput(voucher),
                    const SizedBox(height: 24),
                    _buildSummaryCard(state),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildPaymentSelector(
                            voucher,
                            state.selectedMethod,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _buildQuantityStepper(state.quantity),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildHowToRedeem(voucher.redeemSteps),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildStickyPayButton(state),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeader(VoucherModel voucher) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Refer & Earn',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  voucher.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput(VoucherModel voucher) {
    bool isFocused = _focusNode.hasFocus;
    String maxStr = voucher.maxAmount >= 1000
        ? '${(voucher.maxAmount / 1000).toStringAsFixed(0)}K'
        : voucher.maxAmount.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter your desired / bill amount',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isFocused
                ? Colors.purple.withValues(alpha: 0.05)
                : Colors.white,
            border: Border.all(
              color: isFocused ? Colors.purple : Colors.grey.shade300,
              width: isFocused ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                '₹ ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '100',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                ),
              ),
              Text(
                'Max: $maxStr',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(VoucherState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'YOU PAY',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${state.youPay.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          Column(
            children: [
              const Text(
                'SAVINGS',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${state.savings.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector(VoucherModel voucher, String selectedMethod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: voucher.discounts.map((discount) {
                bool isSelected =
                    selectedMethod.toUpperCase() ==
                    discount.method.toUpperCase();
                return InkWell(
                  onTap: () {
                    ref
                        .read(voucherControllerProvider.notifier)
                        .setPaymentMethod(discount.method);
                  },
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.purple.withValues(alpha: 0.05)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          discount.method.toUpperCase() == 'UPI'
                              ? Icons.account_balance_wallet
                              : Icons.credit_card,
                          color: isSelected ? Colors.purple : Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          discount.method,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.purple : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${discount.percent.toInt()}% OFF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.purple : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuantityStepper(int quantity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: () => ref
                    .read(voucherControllerProvider.notifier)
                    .decrementQuantity(),
                enabled: quantity > 1,
              ),
              Text(
                quantity.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                onTap: () => ref
                    .read(voucherControllerProvider.notifier)
                    .incrementQuantity(),
                enabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.black87 : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildHowToRedeem(List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW TO REDEEM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          String step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$idx. ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStickyPayButton(VoucherState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: state.isDisabled ? null : () {},
        child: Text(
          state.isDisabled
              ? 'Enter Amount'
              : 'Pay ₹${state.youPay.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
