import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:self_finance/core/logic/logic.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:share_plus/share_plus.dart';

class EMICalculatorView extends ConsumerStatefulWidget {
  const EMICalculatorView({super.key});

  @override
  ConsumerState<EMICalculatorView> createState() => _EMICalculatorViewState();
}

class _EMICalculatorViewState extends ConsumerState<EMICalculatorView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final FocusNode _rateFocusNode = FocusNode();

  DateTime _takenDate = DateTime.now();
  late DateTime _tenureDate;
  bool _includeEndDate = true;
  bool _isCompound = false;

  LoanCalculator? _loanCalculator;
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tenureDate = _addMonthsClamped(_takenDate, 3);
    _amountController.addListener(_onInputChanged);
    _rateController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onInputChanged);
    _rateController.removeListener(_onInputChanged);
    _amountController.dispose();
    _rateController.dispose();
    _rateFocusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _recalculate(auto: true);
  }

  DateTime _addMonthsClamped(DateTime date, int monthsToAdd) {
    final int totalMonths = (date.month - 1) + monthsToAdd;
    final int newYear = date.year + (totalMonths ~/ 12);
    final int newMonth = (totalMonths % 12) + 1;
    final int daysInTargetMonth = DateTime(newYear, newMonth + 1, 0).day;
    final int newDay = min(date.day, daysInTargetMonth);
    return DateTime(newYear, newMonth, newDay);
  }

  void _recalculate({bool auto = false}) {
    final String cleanAmount =
        _amountController.text.replaceAll(',', '').trim();
    final String cleanRate = _rateController.text.trim();

    final double? amount = double.tryParse(cleanAmount);
    final double? rate = double.tryParse(cleanRate);

    if (amount != null && amount > 0 && rate != null && rate >= 0) {
      setState(() {
        _loanCalculator = LoanCalculator(
          takenAmount: amount,
          rateOfInterest: rate,
          takenDate: _takenDate,
          tenureDate: _tenureDate,
          includeEndDate: _includeEndDate,
        );
      });
    } else {
      if (!auto) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid loan amount and interest rate."),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
      if (_loanCalculator != null) {
        setState(() {
          _loanCalculator = null;
        });
      }
    }
  }

  void _loadDemoData() {
    setState(() {
      _amountController.text = "50000";
      _rateController.text = "2.0";
      _takenDate = DateTime.now();
      _tenureDate = _addMonthsClamped(_takenDate, 3);
      _includeEndDate = true;
      _loanCalculator = LoanCalculator(
        takenAmount: 50000,
        rateOfInterest: 2.0,
        takenDate: _takenDate,
        tenureDate: _tenureDate,
      );
    });
  }

  void _resetAll() {
    setState(() {
      _amountController.clear();
      _rateController.clear();
      _takenDate = DateTime.now();
      _tenureDate = _addMonthsClamped(_takenDate, 3);
      _includeEndDate = true;
      _loanCalculator = null;
    });
  }

  void _addAmount(double addValue) {
    final double current =
        double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;
    final double total = current + addValue;
    _amountController.text = total.toStringAsFixed(0);
  }

  void _setRate(double rate) {
    _rateController.text = rate.toStringAsFixed(1);
  }

  void _setDurationMonths(int months) {
    setState(() {
      _tenureDate = _addMonthsClamped(_takenDate, months);
    });
    _recalculate(auto: true);
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _takenDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _takenDate = picked;
        if (_tenureDate.isBefore(_takenDate)) {
          _tenureDate = _addMonthsClamped(_takenDate, 1);
        }
      });
      _recalculate(auto: true);
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tenureDate.isBefore(_takenDate) ? _takenDate : _tenureDate,
      firstDate: _takenDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tenureDate = picked;
      });
      _recalculate(auto: true);
    }
  }

  String _formatCurrency(double amount, String symbol) {
    return '$symbol ${Utility.doubleFormate(amount)}';
  }

  String _formatAmountInWords(double amount) {
    if (amount >= 10000000) {
      final double cr = amount / 10000000;
      final String formatted =
          cr.truncateToDouble() == cr ? cr.toStringAsFixed(0) : cr.toStringAsFixed(2);
      return '$formatted Crore';
    } else if (amount >= 100000) {
      final double lk = amount / 100000;
      final String formatted =
          lk.truncateToDouble() == lk ? lk.toStringAsFixed(0) : lk.toStringAsFixed(2);
      return '$formatted Lakh';
    } else if (amount >= 1000) {
      final double k = amount / 1000;
      final String formatted =
          k.truncateToDouble() == k ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
      return '$formatted Thousand';
    }
    return '';
  }

  void _copySummary(String currencySymbol) {
    if (_loanCalculator == null) return;

    final double total = _isCompound
        ? _loanCalculator!.compoundTotalAmount
        : _loanCalculator!.totalAmount;
    final double totalInterest = _isCompound
        ? _loanCalculator!.compoundInterestAmount
        : _loanCalculator!.totalInterestAmount;

    final double rate =
        double.tryParse(_rateController.text.trim()) ?? _loanCalculator!.rateOfInterest;
    final double apr = rate * 12;

    final String text = '''
══════════════════════════════════════
  SELF FINANCE - LOAN CALCULATION
══════════════════════════════════════
• Principal Amount : ${_formatCurrency(_loanCalculator!.takenAmount, currencySymbol)}
• Monthly Interest : ${rate.toStringAsFixed(1)}% / month (${apr.toStringAsFixed(1)}% p.a.)
• Period           : ${_displayDateFormat.format(_takenDate)} to ${_displayDateFormat.format(_tenureDate)}
• Counted Duration : ${_loanCalculator!.monthsAndRemainingDays} (${_loanCalculator!.days} days)
• Monthly Return   : ${_formatCurrency(_loanCalculator!.interestPerMonth, currencySymbol)}
• Total Interest   : ${_formatCurrency(totalInterest, currencySymbol)} (${_isCompound ? "Compound" : "Simple"})
──────────────────────────────────────
• TOTAL REPAYMENT  : ${_formatCurrency(total, currencySymbol)}
══════════════════════════════════════
Calculated via Self Finance App
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed loan summary copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareSummary(String currencySymbol) async {
    if (_loanCalculator == null) return;

    final double total = _isCompound
        ? _loanCalculator!.compoundTotalAmount
        : _loanCalculator!.totalAmount;
    final double totalInterest = _isCompound
        ? _loanCalculator!.compoundInterestAmount
        : _loanCalculator!.totalInterestAmount;

    final double rate =
        double.tryParse(_rateController.text.trim()) ?? _loanCalculator!.rateOfInterest;
    final double apr = rate * 12;

    final String text = '''
══════════════════════════════════════
  SELF FINANCE - LOAN CALCULATION
══════════════════════════════════════
• Principal Amount : ${_formatCurrency(_loanCalculator!.takenAmount, currencySymbol)}
• Monthly Interest : ${rate.toStringAsFixed(1)}% / month (${apr.toStringAsFixed(1)}% p.a.)
• Period           : ${_displayDateFormat.format(_takenDate)} to ${_displayDateFormat.format(_tenureDate)}
• Counted Duration : ${_loanCalculator!.monthsAndRemainingDays} (${_loanCalculator!.days} days)
• Monthly Return   : ${_formatCurrency(_loanCalculator!.interestPerMonth, currencySymbol)}
• Total Interest   : ${_formatCurrency(totalInterest, currencySymbol)} (${_isCompound ? "Compound" : "Simple"})
──────────────────────────────────────
• TOTAL REPAYMENT  : ${_formatCurrency(total, currencySymbol)}
══════════════════════════════════════
Calculated via Self Finance App
''';

    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final String? userCurrency = ref.watch(
      userProvider.select((a) => a.asData?.value?.userCurrency),
    );
    final String currencySymbol =
        (userCurrency != null && userCurrency.isNotEmpty) ? userCurrency : '₹';

    final double? parsedAmount =
        double.tryParse(_amountController.text.replaceAll(',', '').trim());
    final String amountWords =
        parsedAmount != null ? _formatAmountInWords(parsedAmount) : '';
    final double? parsedRate = double.tryParse(_rateController.text.trim());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Actions (Isolated with RepaintBoundary)
            _EmiHeader(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: borderColor,
              onDemo: _loadDemoData,
              onReset: _resetAll,
            ),

            const SizedBox(height: 14),

            // Mode Selector (Simple vs Compound)
            _EmiModeSelector(
              isDark: isDark,
              isCompound: _isCompound,
              onModeChanged: (val) {
                setState(() => _isCompound = val);
                _recalculate(auto: true);
              },
            ),

            const SizedBox(height: 14),

            // Main Input Container
            DecoratedBox(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Principal Amount Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Loan Principal Amount",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (amountWords.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor.withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              amountWords,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_rateFocusNode),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Center(
                            widthFactor: 0,
                            child: Text(
                              currencySymbol,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryColor,
                              ),
                            ),
                          ),
                        ),
                        hintText: "Enter amount (e.g. 50,000)",
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.getLigthGreyColor,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.getPrimaryColor,
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: _amountController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: _amountController.clear,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Addition Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _QuickChip(
                            label: "+${currencySymbol}5K",
                            isSelected: false,
                            onTap: () => _addAmount(5000),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "+${currencySymbol}10K",
                            isSelected: false,
                            onTap: () => _addAmount(10000),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "+${currencySymbol}25K",
                            isSelected: false,
                            onTap: () => _addAmount(25000),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "+${currencySymbol}50K",
                            isSelected: false,
                            onTap: () => _addAmount(50000),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "+${currencySymbol}1L",
                            isSelected: false,
                            onTap: () => _addAmount(100000),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Interest Rate Field with APR Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Monthly Interest Rate (% per month)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (parsedRate != null)
                          Text(
                            "Annual: ${(parsedRate * 12).toStringAsFixed(1)}% p.a.",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rateController,
                      focusNode: _rateFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).unfocus();
                        _recalculate();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.percent_rounded,
                          size: 20,
                          color: AppColors.getPrimaryColor,
                        ),
                        suffixText: "% / mo",
                        suffixStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getLigthGreyColor,
                        ),
                        hintText: "e.g. 2.0",
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.getLigthGreyColor,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.getPrimaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Rate Chips
                    Row(
                      children: [
                        _QuickChip(
                          label: "1.0%",
                          isSelected: parsedRate == 1.0,
                          onTap: () => _setRate(1.0),
                          isDark: isDark,
                        ),
                        _QuickChip(
                          label: "1.5%",
                          isSelected: parsedRate == 1.5,
                          onTap: () => _setRate(1.5),
                          isDark: isDark,
                        ),
                        _QuickChip(
                          label: "2.0%",
                          isSelected: parsedRate == 2.0,
                          onTap: () => _setRate(2.0),
                          isDark: isDark,
                        ),
                        _QuickChip(
                          label: "2.5%",
                          isSelected: parsedRate == 2.5,
                          onTap: () => _setRate(2.5),
                          isDark: isDark,
                        ),
                        _QuickChip(
                          label: "3.0%",
                          isSelected: parsedRate == 3.0,
                          onTap: () => _setRate(3.0),
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 3. Date Selection Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Loan Period & Duration",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        if (_loanCalculator != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${_loanCalculator!.days} Days Total",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getPrimaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DateTile(
                            title: "Loan Given",
                            date: _takenDate,
                            onTap: _pickStartDate,
                            isDark: isDark,
                            borderColor: borderColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.getLigthGreyColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _DateTile(
                            title: "Settlement Due",
                            date: _tenureDate,
                            onTap: _pickEndDate,
                            isDark: isDark,
                            borderColor: borderColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Quick Duration Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _QuickChip(
                            label: "1 Month",
                            isSelected:
                                _tenureDate == _addMonthsClamped(_takenDate, 1),
                            onTap: () => _setDurationMonths(1),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "3 Months",
                            isSelected:
                                _tenureDate == _addMonthsClamped(_takenDate, 3),
                            onTap: () => _setDurationMonths(3),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "6 Months",
                            isSelected:
                                _tenureDate == _addMonthsClamped(_takenDate, 6),
                            onTap: () => _setDurationMonths(6),
                            isDark: isDark,
                          ),
                          _QuickChip(
                            label: "1 Year",
                            isSelected:
                                _tenureDate == _addMonthsClamped(_takenDate, 12),
                            onTap: () => _setDurationMonths(12),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. Include End Date Toggle Tile
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.15)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() => _includeEndDate = !_includeEndDate);
                          _recalculate(auto: true);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _includeEndDate,
                                  onChanged: (val) {
                                    setState(
                                      () => _includeEndDate = val ?? true,
                                    );
                                    _recalculate(auto: true);
                                  },
                                  activeColor: AppColors.getPrimaryColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Include Settlement Day",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.getPrimaryTextColor,
                                      ),
                                    ),
                                    const Text(
                                      "Count the last calendar day in interest calculation",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.getLigthGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 5. Calculate Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _recalculate();
                        },
                        icon: const Icon(Icons.calculate_rounded, size: 20),
                        label: const Text(
                          "Calculate Repayment",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getPrimaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor:
                              AppColors.getPrimaryColor.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Results or Empty State (Isolated with RepaintBoundary)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _loanCalculator != null
                  ? RepaintBoundary(
                      key: const ValueKey('results_view'),
                      child: _EmiResultsSection(
                        calc: _loanCalculator!,
                        isCompound: _isCompound,
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        currencySymbol: currencySymbol,
                        rateText: _rateController.text,
                        onCopy: () => _copySummary(currencySymbol),
                        onShare: () => _shareSummary(currencySymbol),
                      ),
                    )
                  : RepaintBoundary(
                      key: const ValueKey('empty_view'),
                      child: _EmptyCalculatorView(
                        isDark: isDark,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        onDemo: _loadDemoData,
                      ),
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _EmiHeader extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final VoidCallback onDemo;
  final VoidCallback onReset;

  const _EmiHeader({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.onDemo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.getPrimaryColor.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  size: 24,
                  color: AppColors.getPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EMI & Interest Calculator",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AppColors.getPrimaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Accurate daily & monthly loan tracker",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getLigthGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onDemo,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.getPrimaryColor,
                ),
                label: const Text(
                  "Demo",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: "Reset All",
                onPressed: onReset,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: AppColors.getLigthGreyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmiModeSelector extends StatelessWidget {
  final bool isDark;
  final bool isCompound;
  final ValueChanged<bool> onModeChanged;

  const _EmiModeSelector({
    required this.isDark,
    required this.isCompound,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              title: "Simple Interest",
              subtitle: "Standard flat monthly rate",
              isSelected: !isCompound,
              onTap: () => onModeChanged(false),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              title: "Compound Interest",
              subtitle: "Compounded monthly",
              isSelected: isCompound,
              onTap: () => onModeChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.getPrimaryColor : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.getPrimaryTextColor)
                    : AppColors.getLigthGreyColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.getLigthGreyColor)
                    : AppColors.getLigthGreyColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
        ),
        backgroundColor: isSelected
            ? AppColors.getPrimaryColor
            : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04)),
        side: BorderSide(
          color: isSelected
              ? AppColors.getPrimaryColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String title;
  final DateTime date;
  final VoidCallback onTap;
  final bool isDark;
  final Color borderColor;

  const _DateTile({
    required this.title,
    required this.date,
    required this.onTap,
    required this.isDark,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat displayFormat = DateFormat('dd MMM yyyy');
    final DateFormat weekdayFormat = DateFormat('EEEE');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: isDark ? Colors.white54 : AppColors.getLigthGreyColor,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white54
                          : AppColors.getLigthGreyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              displayFormat.format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
              ),
            ),
            Text(
              weekdayFormat.format(date),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.getLigthGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmiResultsSection extends StatelessWidget {
  final LoanCalculator calc;
  final bool isCompound;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final String currencySymbol;
  final String rateText;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _EmiResultsSection({
    required this.calc,
    required this.isCompound,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.currencySymbol,
    required this.rateText,
    required this.onCopy,
    required this.onShare,
  });

  String _formatCurrency(double amount) {
    return '$currencySymbol ${Utility.doubleFormate(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount =
        isCompound ? calc.compoundTotalAmount : calc.totalAmount;
    final double totalInterest =
        isCompound ? calc.compoundInterestAmount : calc.totalInterestAmount;
    final double principal = calc.takenAmount;

    final double principalRatio =
        totalAmount > 0 ? (principal / totalAmount).clamp(0.0, 1.0) : 1.0;
    final double interestRatio =
        totalAmount > 0 ? (totalInterest / totalAmount).clamp(0.0, 1.0) : 0.0;

    final int totalMonthsCount =
        calc.months + (calc.remainingDays > 0 ? 1 : 0);
    final double averageMonthlyPayback =
        totalMonthsCount > 0 ? (totalAmount / totalMonthsCount) : totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Summary Gradient Card
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL REPAYMENT AMOUNT",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompound ? "COMPOUND" : "SIMPLE",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(totalAmount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Visual Ratio Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: max(1, (principalRatio * 100).round()),
                          child: Container(color: const Color(0xFF38BDF8)),
                        ),
                        Expanded(
                          flex: max(1, (interestRatio * 100).round()),
                          child: Container(color: const Color(0xFFFBBF24)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Principal vs Interest breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Principal: ${_formatCurrency(principal)} (${(principalRatio * 100).toStringAsFixed(1)}%)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBBF24),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Interest: ${_formatCurrency(totalInterest)} (${(interestRatio * 100).toStringAsFixed(1)}%)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 2. Metrics Grid (4 Clean Detail Cards)
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.calendar_month_rounded,
                title: "Tenure Duration",
                value: calc.monthsAndRemainingDays,
                subtitle: "${calc.days} Total Counted Days",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.percent_rounded,
                title: "Monthly Interest",
                value: _formatCurrency(calc.interestPerMonth),
                subtitle: "$rateText% per month",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.today_rounded,
                title: "Daily Interest",
                value: _formatCurrency(calc.interestPerDay),
                subtitle: "Calculated per day",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.add_chart_rounded,
                title: "Total Interest",
                value: _formatCurrency(totalInterest),
                subtitle: isCompound ? "Compounded Total" : "Simple Total",
                isDark: isDark,
                cardBg: cardBg,
                borderColor: borderColor,
                accentColor: const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),

        if (totalMonthsCount > 1) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.getPrimaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Equivalent monthly payback over $totalMonthsCount months: ${_formatCurrency(averageMonthlyPayback)} / mo",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // 3. Quick Action Buttons (Copy & Share)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text("Copy Summary"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor:
                      isDark ? Colors.white : AppColors.getPrimaryTextColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text("Share"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.getPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color? accentColor;

  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color tintColor = accentColor ?? AppColors.getPrimaryColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: tintColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.getLigthGreyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.getLigthGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCalculatorView extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final VoidCallback onDemo;

  const _EmptyCalculatorView({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.onDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.getPrimaryColor.withValues(
                alpha: isDark ? 0.16 : 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 32,
              color: AppColors.getPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Ready to Calculate",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.getPrimaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter a principal amount and interest rate above to view instant payment breakdown and tenure schedule.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getLigthGreyColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onDemo,
            icon: const Icon(Icons.flash_on_rounded, size: 16),
            label: const Text("Load Example (50,000 @ 2%)"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.getPrimaryColor,
              side: const BorderSide(color: AppColors.getPrimaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
