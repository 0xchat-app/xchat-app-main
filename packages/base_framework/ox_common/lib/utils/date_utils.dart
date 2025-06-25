import 'package:ox_localizable/ox_localizable.dart';
import 'package:intl/intl.dart';

class OXDateUtils {

  static String formatTimestamp(int timestamp,{String pattern = 'yyyy-MM-dd HH:mm'}){
    var format = new DateFormat(pattern);
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return format.format(date);
  }

  static String convertTimeFormatString2(int timestamp, {String pattern = 'MM-dd HH:mm'}) {
    final DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime msgDate = DateTime(messageTime.year, messageTime.month, messageTime.day);
    final int daysDiff = today.difference(msgDate).inDays;
    
    if (daysDiff == 0) {
      return formatTimestamp(timestamp, pattern: 'HH:mm');
    }
    
    if (daysDiff == 1) {
      return Localized.text('ox_common.yesterday') + ' ' + formatTimestamp(timestamp, pattern: 'HH:mm');
    }
    
    if (daysDiff <= 7) {
      return _getWeekdayText(messageTime.weekday);
    }
    
    if (daysDiff <= 30) {
      return _getLocalizedDateFormat(messageTime, false);
    }
    
    return _getLocalizedDateFormat(messageTime, true);
  }

  static String _getWeekdayText(int weekday) {
    const List<String> weekdayKeys = [
      'ox_common.monday',
      'ox_common.tuesday', 
      'ox_common.wednesday',
      'ox_common.thursday',
      'ox_common.friday',
      'ox_common.saturday',
      'ox_common.sunday'
    ];
    
    // weekday: 1=Monday, 7=Sunday
    String key = weekdayKeys[weekday - 1];
    String localizedText = Localized.text(key);
    
    if (localizedText == key) {
      const List<String> englishWeekdays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      return englishWeekdays[weekday - 1];
    }
    
    return localizedText;
  }

  static String _getLocalizedDateFormat(DateTime dateTime, bool includeYear) {
    final bool isChinese = localized.localeType == LocaleType.zh || localized.localeType == LocaleType.zh_tw;
    
    if (isChinese) {
      if (includeYear) {
        return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
      } else {
        return '${dateTime.month}月${dateTime.day}日';
      }
    } else {
      if (includeYear) {
        return DateFormat('MM/dd/yyyy').format(dateTime);
      } else {
        return DateFormat('MM/dd').format(dateTime);
      }
    }
  }

  /// Returned "Just" "x minutes ago" "x hours ago" "x days ago" "x months ago" "x years ago"
  static String convertTimeFormatString3(int timestamp) {

    final oneSecond = 1;
    final oneMinute = oneSecond * 60;
    final oneHour = oneMinute * 60;
    final oneDay = oneHour * 24;
    final oneMonth = oneDay * 30;
    final oneYear = oneMonth * 12;

    final int nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final double t = (nowTimeStamp - timestamp)/1000;

    if(t <= oneMinute){
      return Localized.text('ox_common.now');
    }
    else if(t > oneMinute && t < oneHour){
      return (t~/oneMinute).toString() + Localized.text('ox_common.oneminute');
    }
    else if(t >= oneHour && t < oneDay){
      return (t~/oneHour).toString() + Localized.text('ox_common.onehour');
    }
    else if(t >= oneDay && t < oneMonth){
      return (t~/oneDay).toString() + Localized.text('ox_common.oneday');
    }
    else if(t >= oneMonth && t < oneYear){
      return (t~/oneMonth).toString() + Localized.text('ox_common.onemonth');
    } else {
      return (t~/oneYear).toString() + Localized.text('ox_common.oneyear');
    }
  }

  /// Get Monthly copy
  static String monthString(int month) {
    if (month < 1 || month > 12) return '';
    final enMonthList = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (localized.localeType == LocaleType.zh || localized.localeType == LocaleType.zh_tw) {
      return '$month';
    } else {
      return enMonthList[--month];
    }
  }

  /// Get Daily copy
  static String dayString(int day, {separator = false}) {
    if (day < 1 || day > 31) return '';
    if (localized.localeType == LocaleType.zh || localized.localeType == LocaleType.zh_tw) {
      return '$day';
    } else {
      return '${separator ? ' ' : ''}$day';
    }
  }

  ///Get the 'Daily, Month for short', and the month localized, eg '28 Sep'
  static String getLocalizedMonthAbbreviation(int timestamp, {String locale = 'en'}) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedDate = DateFormat('d MMM', locale).format(date);
    return formattedDate;
  }
}

extension YLCommon on DateTime {
  int get secondsSinceEpoch =>(DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
}