double reduceDecimals(double value) {
  return double.parse(value.toStringAsFixed(1));
}

int textToInt(String value) {
  return int.parse(value);
}
