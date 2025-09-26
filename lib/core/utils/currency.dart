class CurrencyFormatter {
  static const String _symbol = 'Rs.';

  /// Format a PKR amount (int or double) with thousand separators and PKR symbol.
  static String formatPkr(num? amount) {
    if (amount == null) return 'Not specified';
    final intValue = amount.round();
    final digits = _formatWithSeparators(intValue);
    return '$_symbol $digits';
  }

  /// Format a PKR salary range.
  static String formatPkrRange(num? min, num? max) {
    if (min != null && max != null) {
      return '${formatPkr(min)} - ${formatPkr(max)}';
    } else if (min != null) {
      return 'From ${formatPkr(min)}';
    } else if (max != null) {
      return 'Up to ${formatPkr(max)}';
    }
    return 'Not specified';
  }

  /// Compact label for sliders (e.g., 150k, 1.2M) but force PKR context in UI text.
  static String compact(num value) {
    if (value >= 1000000) {
      final v = (value / 1000000);
      return v.toStringAsFixed(v % 1 == 0 ? 0 : 1) + 'M';
    }
    if (value >= 1000) {
      final v = (value / 1000);
      return v.toStringAsFixed(v % 1 == 0 ? 0 : 1) + 'k';
    }
    return value.toStringAsFixed(0);
  }

  static String _formatWithSeparators(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int counter = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      counter++;
      if (counter == 3 && i != 0) {
        buffer.write(',');
        counter = 0;
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
