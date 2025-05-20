import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static String? telefon;
  static String? il;
  static String? ilce;
  static String? adres;
  static String? adSoyad;
  static String? faturaUnvani;
  static String? vergiNo;
  static String? vergiDairesi;



  static bool get girisYapti => telefon != null && telefon!.isNotEmpty;

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    telefon = prefs.getString('telefon');
    il = prefs.getString('il');
    ilce = prefs.getString('ilce');
    adres = prefs.getString('adres');
    adSoyad = prefs.getString('adSoyad');
    faturaUnvani = prefs.getString('faturaUnvani');
    vergiNo = prefs.getString('vergiNo');
    vergiDairesi = prefs.getString('vergiDairesi');
  }

  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    if (telefon != null) prefs.setString('telefon', telefon!);
    if (il != null) prefs.setString('il', il!);
    if (ilce != null) prefs.setString('ilce', ilce!);
    if (adres != null) prefs.setString('adres', adres!);
    if (adSoyad != null) prefs.setString('adSoyad', adSoyad!);
    if (faturaUnvani != null) prefs.setString('faturaUnvani', faturaUnvani!);
    if (vergiNo != null) prefs.setString('vergiNo', vergiNo!);
    if (vergiDairesi != null) prefs.setString('vergiDairesi', vergiDairesi!);
  }

  static Future<void> cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    telefon = null;
    adres = null;
    adSoyad = null;
  }
}

class SepetData {
  static List<Map<String, dynamic>> sepet = [];

  static void ekle({
  required String urunAdi,
  required int adet,
  required int toplamFiyat,
  required String gorselUrl, // 👈 görsel URL'si de alınıyor
}) {
  sepet.add({
    'urunAdi': urunAdi,
    'adet': adet,
    'toplamFiyat': toplamFiyat,
    'gorselUrl': gorselUrl, // 👈 bunu kaydet
  });
}

  static void temizle() {
    sepet.clear();
  }
}
