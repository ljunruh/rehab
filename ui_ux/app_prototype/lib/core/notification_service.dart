import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Singleton-Service für tägliche Trainings-Benachrichtigungen.
///
/// Persistiert Aktivierungs-Status und gewählte Uhrzeit in einer JSON-Datei
/// (via path_provider). Beim App-Start [initialize] aufrufen, damit eine
/// bereits gespeicherte Erinnerung wieder eingetragen wird.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _notifId = 42;
  static const _channelId = 'daily_training_reminder';
  static const _fileName = 'notification_settings.json';

  bool get _supportsLocalNotifications => Platform.isAndroid || Platform.isIOS;

  /// Initialisiert das Plugin und stellt eine gespeicherte Erinnerung wieder her.
  Future<void> initialize() async {
    // Desktop-Plattformen überspringen, um Plugin-Probleme zu vermeiden.
    if (!_supportsLocalNotifications) {
      return;
    }

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Android 13+: Notification-Permission anfragen
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Ggf. vorhandene Einstellung wiederherstellen
    final saved = await loadSettings();
    if (saved['enabled'] == true) {
      await schedule(saved['time'] as String? ?? '08:00');
    }
  }

  /// Plant eine tägliche Benachrichtigung zur angegebenen Uhrzeit (Format "HH:mm").
  /// Auf Windows/Linux/macOS wird die Zeit nur gespeichert, aber nicht geplant.
  Future<void> schedule(String time) async {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Nur auf Android/iOS planen
    if (_supportsLocalNotifications) {
      await _plugin.cancel(_notifId);

      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Trainings-Erinnerung',
          channelDescription: 'Tägliche Erinnerung an dein Training',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

      await _plugin.zonedSchedule(
        _notifId,
        'Reha App',
        'Denk an dein Training',
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // Zeit immer speichern (funktioniert auf allen Plattformen)
    await _save(enabled: true, time: time);
  }

  /// Storniert die geplante Benachrichtigung.
  /// [time] wird weiterhin gespeichert, damit die Auswahl beim erneuten
  /// Aktivieren erhalten bleibt.
  Future<void> cancel(String time) async {
    if (_supportsLocalNotifications) {
      await _plugin.cancel(_notifId);
    }
    await _save(enabled: false, time: time);
  }

  /// Gibt die gespeicherten Einstellungen zurück: {'enabled': bool, 'time': String}.
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final file = await _file();
      if (!await file.exists()) return {'enabled': false, 'time': '08:00'};
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {'enabled': false, 'time': '08:00'};
    }
  }

  Future<void> _save({required bool enabled, required String time}) async {
    final file = await _file();
    await file.writeAsString(jsonEncode({'enabled': enabled, 'time': time}));
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  /// NUR FÜR DEBUG – löst sofort eine Test-Notification aus. kann aus der Finalen Version raus
  Future<void> debugShowNow() async {
    if (_supportsLocalNotifications) {
      await _plugin.show(
        99,
        'Reha App',
        'Denk an dein Training',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Trainings-Erinnerung',
          ),
        ),
      );
    }
  }
}
