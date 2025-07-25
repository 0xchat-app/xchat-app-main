
import 'dart:math';

import 'package:chatcore/chat-core.dart';

extension UserDBChatEx on UserDBISAR {
  String getUserShowName() {
    final nickName = (this.nickName ?? '').trim();
    final name = (this.name ?? '').trim();
    if (nickName.isNotEmpty) return nickName;
    if (name.isNotEmpty) return name;
    return shortEncodedPubkey;
  }

  updateWith(UserDBISAR user) {
    name = user.name;
    picture = user.picture;
    about = user.about;
    lnurl = user.lnurl;
    gender = user.gender;
    area = user.area;
    dns = user.dns;
  }
}

extension UserListChatEx on List<UserDBISAR> {
  String abbrDesc({
    String noneText = '',
    int showUserCount = 2,
    int maxNameLength = 15,
    String Function(UserDBISAR user)? userNameBuilder,
  }) {
    if (this.isEmpty) return noneText;

    final nameBuilder = userNameBuilder ?? (user) => user.getUserShowName();

    final names = this.sublist(0, min(showUserCount, this.length))
        .map((user) {
      final name = nameBuilder(user);
      if (name.length > maxNameLength) return name.replaceRange(maxNameLength - 3, name.length, '...');
      return name;
    }).toList().join(',');

    final otherCount = max(0, this.length - showUserCount);
    if (otherCount > 0) {
      return names + ' and $otherCount others';
    } else {
      return names;
    }
  }
}