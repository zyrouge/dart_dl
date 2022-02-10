class DLProgress {
  const DLProgress(this.current, this.total);

  final int current;
  final int total;

  bool get isFinite => current > -1 && total > 0;

  double get percent => isFinite ? (current / total) * 100 : -1;
}
