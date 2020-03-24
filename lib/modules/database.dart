import 'package:covid19_telegram_bot/modules/news.dart';
import 'package:mysql1/mysql1.dart';
import 'package:dotenv/dotenv.dart' show load, env;
import 'package:teledart/model.dart';

class Database {
  static List<int> chats = [];
  static List<String> news = [];

  static var conn;

  static void init() async {
    load();

    var settings = ConnectionSettings(
      host: env['DB_HOST'],
      port: int.parse(env['DB_PORT']),
      user: env['DB_USERNAME'],
      password: env['DB_PASSWORD'],
      db: env['DB_DATABASE'],
    );

    conn = await MySqlConnection.connect(settings);

    var db_chats = await conn.query('select distinct chat_id from chats');
    for (var id in db_chats) {
      chats.add(int.parse(id[0]));
    }
    print('Chat IDs have been populated');

    var db_news = await conn.query('select link from news');
    for (var link in db_news) {
      news.add(link[0]);
    }
    print('News have been populated');
  }

  static void storeChat(Message message) async {
    if (!chats.contains(message.chat.id)) {
      chats.add(message.chat.id);
      await conn.query(
        'insert ignore into chats (chat_id) values (?)',
        [message.chat.id],
      );
    }
  }

  static void storeNews(String link) async {
    if (!news.contains(link)) {
      news.add(link);
      await conn.query(
        'insert ignore into news (link) values (?)',
        [link],
      );
      await News.post(link);
    }
  }
}
