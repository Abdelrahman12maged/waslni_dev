/// Domain summary for driver home: count of trips per status.
class DriverTripsSummary {
  final int openCount;
  final int acceptedCount;
  final int completedCount;
  final int suspendedCount;
  final int canceledCount;
  final int closedCount;

  const DriverTripsSummary({
    this.openCount = 0,
    this.acceptedCount = 0,
    this.completedCount = 0,
    this.suspendedCount = 0,
    this.canceledCount = 0,
    this.closedCount = 0,
  });

  const DriverTripsSummary.empty() : this();

  DriverTripsSummary copyWith({
    int? openCount,
    int? acceptedCount,
    int? completedCount,
    int? suspendedCount,
    int? canceledCount,
    int? closedCount,
  }) {
    return DriverTripsSummary(
      openCount: openCount ?? this.openCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      completedCount: completedCount ?? this.completedCount,
      suspendedCount: suspendedCount ?? this.suspendedCount,
      canceledCount: canceledCount ?? this.canceledCount,
      closedCount: closedCount ?? this.closedCount,
    );
  }
}
