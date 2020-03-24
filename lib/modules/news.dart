import 'dart:convert';

import 'package:covid19_telegram_bot/modules/database.dart';
import 'package:covid19_telegram_bot/covid19_telegram_bot.dart' as bot;
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:async';

class News {
  static var client;
  static var duration = const Duration(seconds: 10);
  static HtmlEscape htmlEscape = const HtmlEscape();

  static Future init() async {
    print('Initalizing news module');
    client = Client();
    Timer.periodic(duration, (Timer t) => fetch());
  }

  static Future fetch() async {
    print('Parsing news at ${DateTime.now().toString()}');
    var response = await client.get('https://cabmin.gov.az/az/category/10/');
    var document = parse(response.body);
    var links = document.querySelectorAll('div.float').reversed;
    for (var link in links) {
      await Database.storeNews(link.parentNode.attributes['href']);
    }
  }

  static Future<void> post(String link) async {
    print('posting ${link}');
    var response = await client.get(link);
    var document = parse(response.body);

    var title = document.querySelector('.articleTitle').text.trim();
    var time = document
        .querySelector(
            'body > div.main > center > div.mainMini > div > ul > center > div:nth-child(4)')
        .text
        .split('|')[1]
        .trim();

    var textContent = document.querySelectorAll(
        'body > div.main > center > div.mainMini > div > ul > center > div:nth-child(7) > p');

    var text = '';
    for (var c in textContent) {
      text = text +
          '\n' +
          c.innerHtml.replaceAll('<br>', '').replaceAll('&nbsp;', '');
    }

    await bot.publish(
        htmlEscape.convert(title.replaceAll('<br>', '')), time, text);
  }
}
