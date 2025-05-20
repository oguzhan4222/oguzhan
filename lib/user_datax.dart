import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static String? telefon;
  static String? sifre;
  static String? adres;
  static String? adSoyad;

  static bool get girisYapti => telefon != null && telefon!.isNotEmpty;

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    telefon = prefs.getString('telefon');
    sifre = prefs.getString('sifre');
    adres = prefs.getString('adres');
    adSoyad = prefs.getString('adSoyad');
  }

  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    if (telefon != null) prefs.setString('telefon', telefon!);
    if (sifre != null) prefs.setString('sifre', sifre!);
    if (adres != null) prefs.setString('adres', adres!);
    if (adSoyad != null) prefs.setString('adSoyad', adSoyad!);
  }

  static Future<void> cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    telefon = null;
    sifre = null;
    adres = null;
    adSoyad = null;
  }
}
