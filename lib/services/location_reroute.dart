//Show location on google map
import 'package:url_launcher/url_launcher.dart';

Future<void> launchLocation(String address) async {
  if (await canLaunch("https://www.google.com/maps/search")) {
    final bool nativeApp = await launch(
        "https://www.google.com/maps/search/$address",
        forceWebView: false,
        universalLinksOnly: true,
        forceSafariVC: false);
    if (!nativeApp) {
      await launch("https://www.google.com/maps/search/$address",
          forceWebView: true, forceSafariVC: true);
    }
  }
}
