enum RoomDaytime { morning, evening, night }

/// Слои комнаты по часам устройства.
abstract final class RoomDaytimes {
  /// Утро 6:00–16:59, вечер 17:00–21:59, ночь 22:00–5:59.
  static RoomDaytime of(DateTime time) {
    final hour = time.hour;
    if (hour >= 22 || hour < 6) return RoomDaytime.night;
    if (hour >= 17) return RoomDaytime.evening;
    return RoomDaytime.morning;
  }
}
