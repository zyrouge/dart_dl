import 'dart:async';

class DLProgress {
  const DLProgress(
    this.current,
    this.total, {
    this.finished = false,
    this.extraDetails,
  });

  final int current;
  final int total;
  final bool finished;
  final Map<dynamic, dynamic>? extraDetails;

  bool get isFinite => current > -1 && total > 0;

  double get percent => finished
      ? 100
      : isFinite
          ? (current / total) * 100
          : 0;

  static StreamController<DLProgress> create() =>
      StreamController<DLProgress>();
}
