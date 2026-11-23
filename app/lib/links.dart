import 'package:url_launcher/url_launcher.dart';

import 'data.dart';

/// Opens the MSW Labs learning platform (intern.mystartupwave.com).
Future<void> openMswLabs() => launchUrl(Uri.parse(mswLabsUrl), mode: LaunchMode.externalApplication);
