import 'package:timeago/src/messages/lookupmessages.dart';

class RuTimeMessages implements LookupMessages {
  String prefixAgo() => '';
  String prefixFromNow() => 'через';
  String suffixAgo() => 'назад';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => 'минуту';
  String aboutAMinute(int minutes) => 'минуту';
  String minutes(int minutes) {
    return relativeTimeWithPlural(minutes, false, "mm");
  }
  String aboutAnHour(int minutes) => 'час';
  String hours(int hours) {
    return relativeTimeWithPlural(hours, false, "hh");
  }
  String aDay(int hours) => 'день';
  String days(int days) {
    return relativeTimeWithPlural(days, false, "dd");
  }
  String aboutAMonth(int days) => 'месяц';
  String months(int months) => '${months} месяцев';
  String aboutAYear(int year) => 'год';
  String years(int years) => '${years} лет';
  String wordSeparator() => ' ';

  String plural(String word, int num) {
    var forms = word.split('_');
    return num % 10 == 1 && num % 100 != 11 ? forms[0] : (num % 10 >= 2 && num % 10 <= 4 && (num % 100 < 10 || num % 100 >= 20) ? forms[1] : forms[2]);
  }

  String relativeTimeWithPlural(int number,bool withoutSuffix,String key) {
    var format = {
      'ss': withoutSuffix ? 'секунда_секунды_секунд' : 'секунду_секунды_секунд',
      'mm': withoutSuffix ? 'минута_минуты_минут' : 'минуту_минуты_минут',
      'hh': 'час_часа_часов',
      'dd': 'день_дня_дней',
      'MM': 'месяц_месяца_месяцев',
      'yy': 'год_года_лет'
    };
    if (key == 'm') {
      return withoutSuffix ? 'минута' : 'минуту';
    }
    else {
      return number.toString() + ' ' + plural(format[key], number);
    }
  }
}