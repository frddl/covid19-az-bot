import 'package:covid19_telegram_bot/modules/database.dart';
import 'package:covid19_telegram_bot/modules/news.dart';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';

var teledart;

void conf() {
  teledart = TeleDart(
    Telegram('${env['TOKEN']}'),
    Event(),
  );

  teledart.start().then((me) => print('${me.username} is initialised'));
  teledart.onCommand('start').listen(
        ((message) => {
              Database.storeChat(message),
              teledart.replyMessage(
                message,
                env['WLCM'],
              ),
            }),
      );
}

Future<void> main() async {
  load(); // dotenv
  await Database.init();
  conf();
  await News.init();
}

Future<void> publish(String title, String time, String text) async {
  for (var chat in Database.chats) {
    teledart.telegram.sendMessage(
      chat,
      '${title} (${time})\n${text}',
      parse_mode: 'html',
    );
  }
}
