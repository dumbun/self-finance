import 'dart:io';
import 'package:share_plus/share_plus.dart';

class Invite {
  static Future<void> shareAppLink() async {
    const androidLink =
        'https://play.google.com/store/apps/details?id=com.dumbun.self_finance&pcampaignid=web_share';

    const iosLink = 'not in production';

    final appLink = Platform.isIOS ? iosLink : androidLink;

    await SharePlus.instance.share(
      ShareParams(
        text:
            '''
Check out Self Finance!

$appLink
''',
      ),
    );
  }
}
