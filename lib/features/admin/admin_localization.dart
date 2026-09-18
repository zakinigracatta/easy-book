import 'package:flutter/widgets.dart';

String adminText(BuildContext context, String english, String arabic) =>
    Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;
