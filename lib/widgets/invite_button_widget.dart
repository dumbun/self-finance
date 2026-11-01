import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/utility/invite_link_utility.dart';
import 'package:self_finance/widgets/app_icon_widget.dart';

class InviteButtonWidget extends StatelessWidget {
  const InviteButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconWidget(height: 42, width: 42),
            SizedBox(width: 12),
            BodyOneDefaultText(text: "Self Finance", bold: true),
          ],
        ),

        const SizedBox(height: 20),

        BodyTwoDefaultText(text: context.l10n.likeOurApp),

        TextButton(
          onPressed: Invite.shareAppLink,
          child: BodyTwoDefaultText(text: context.l10n.inviteFriends, bold: true),
        ),
      ],
    );
  }
}
