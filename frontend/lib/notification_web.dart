// notification_web.dart
import 'dart:html' as html;

void showWebNotification(String title, String body) {
  if (html.Notification.permission == 'granted') {
    html.Notification(title, body: body);
  } else if (html.Notification.permission == 'default') {
    html.Notification.requestPermission().then((permission) {
      if (permission == 'granted') {
        html.Notification(title, body: body);
      }
    });
  }
}