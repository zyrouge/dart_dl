class DLProgress {
  const DLProgress(
    this.current,
    this.total, {
    this.finished = false,
  });

  final int current;
  final int total;
  final bool finished;

  bool get isFinite => current > -1 && total > 0;

  double get percent => finished
      ? 100
      : isFinite
          ? (current / total) * 100
          : 0;
}
