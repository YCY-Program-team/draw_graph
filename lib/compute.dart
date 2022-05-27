double roundToN(double num, int n) {
  return double.parse(num.toStringAsFixed(n >= 0 ? n : 0));
}
