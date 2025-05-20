// main.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'phone_auth_screen.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';


class UserData {
  static String? telefon;
  static String? adres;
  static String? adSoyad;

  static bool get girisYapti => telefon != null && telefon!.isNotEmpty;

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    telefon = prefs.getString('telefon');
    adres = prefs.getString('adres');
    adSoyad = prefs.getString('adSoyad');
  }

  static Future<void> kaydet() async {
    final prefs = await SharedPreferences.getInstance();
    if (telefon != null) prefs.setString('telefon', telefon!);
    if (adres != null) prefs.setString('adres', adres!);
    if (adSoyad != null) prefs.setString('adSoyad', adSoyad!);
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
  }) {
    sepet.add({
      'urunAdi': urunAdi,
      'adet': adet,
      'toplamFiyat': toplamFiyat,
      'gorsel': 'assets/urun.png',
    });
  }

  static void temizle() {
    sepet.clear();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // 👈 Firebase başlatılıyor
  await UserData.yukle();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaşıKolay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashEkrani(),
    );
  }
}

class SplashEkrani extends StatefulWidget {
  const SplashEkrani({super.key});

  @override
  State<SplashEkrani> createState() => _SplashEkraniState();
}

class _SplashEkraniState extends State<SplashEkrani> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UrunSecimiEkrani()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'TaşıKolay',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class UrunSecimiEkrani extends StatefulWidget {
  const UrunSecimiEkrani({super.key});

  @override
  State<UrunSecimiEkrani> createState() => _UrunSecimiEkraniState();
}

class _UrunSecimiEkraniState extends State<UrunSecimiEkrani> {
  @override
void initState() {
  super.initState();
  UserData.yukle().then((_) {
    setState(() {}); // ekranı güncelle
  });
}
  void _urunTiklandi(String urunAdi, int birimFiyat) async {
    await showDialog(
      context: context,
      builder: (_) => AdetSecDialog(
        urunAdi: urunAdi,
        birimFiyat: birimFiyat,
        onEklendi: () {
          setState(() {}); // sayıyı güncelle
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaşıKolay'),
        actions: UserData.girisYapti
    ? [
        // 👤 İSİM BUTONU (sola kaydırıldı)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'duzenle') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilDuzenleEkrani()),
                );
              } else if (value == 'gecmis') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SiparisGecmisiEkrani()),
                );
              } else if (value == 'cikis') {
                UserData.cikisYap().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const UrunSecimiEkrani()),
                    (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'duzenle', child: Text('Profili Düzenle')),
              const PopupMenuItem(value: 'gecmis', child: Text('Sipariş Geçmişi')),
              const PopupMenuItem(value: 'cikis', child: Text('Çıkış Yap')),
            ],
            child: Row(
              children: [
                Text(
                  (UserData.adSoyad != null && UserData.adSoyad!.isNotEmpty)
                      ? UserData.adSoyad!.split(' ').first
                      : '',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
              ],
            ),
          ),
        ),

        // 🍔 HAMBURGER MENÜ (en sağda)
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.receipt),
                      title: const Text('Fatura Bilgilerim'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('K.V.K.K'),
                      onTap: () => Navigator.pop(context),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text('TaşıKolay Çağrı Merkezi', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('+90 532 123 45 67'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ]
    : [
        // 👥 GİRİŞ YAPMAMIŞ KİŞİ İKONU
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Giriş Yap'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('Üye Ol'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UyeOlEkrani()),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
      ),
      body: Stack(
  children: [
    Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _urunTiklandi('Damacana Aparatı A', 25),
            child: SizedBox.expand(
              child: Image.asset('assets/urun.png', fit: BoxFit.cover),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => _urunTiklandi('Damacana Aparatı B', 30),
            child: SizedBox.expand(
              child: Image.asset('assets/urun.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    ),
    Positioned(
      bottom: 80,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final Uri telUri = Uri(scheme: 'tel', path: '+905321234567'); // <- numaranı buraya yaz
          if (await canLaunchUrl(telUri)) {
            await launchUrl(telUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Arama başlatılamadı')),
            );
          }
        },
        child: const Icon(Icons.phone, color: Colors.white),
      ),
    ),
  ],
),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SepetEkrani(),
              ),
            );
          },
          icon: const Icon(Icons.shopping_cart),
          label: Text('Sepete Git (${SepetData.sepet.length})'),
        ),
      ),
    );
  }
}

class AdetSecDialog extends StatefulWidget {
  final String urunAdi;
  final int birimFiyat;
  final VoidCallback? onEklendi;

  const AdetSecDialog({
    super.key,
    required this.urunAdi,
    required this.birimFiyat,
    this.onEklendi,
  });

  @override
  State<AdetSecDialog> createState() => _AdetSecDialogState();
}

class _AdetSecDialogState extends State<AdetSecDialog> {
  int adet = 1;

  @override
  Widget build(BuildContext context) {
    int toplam = adet * widget.birimFiyat;

    return AlertDialog(
  title: Text(widget.urunAdi),
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('Birim Fiyat: ${widget.birimFiyat}₺'),
      // diğer içerikler...
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('İptal'),
    ),
    TextButton(
      onPressed: () {
        // sepete ekle
      },
      child: const Text('Sepete Ekle'),
    ),
  ],
);

  }
}

class UyeOlEkrani extends StatefulWidget {
  const UyeOlEkrani({super.key});

  @override
  State<UyeOlEkrani> createState() => _UyeOlEkraniState();
}

class _UyeOlEkraniState extends State<UyeOlEkrani> {
  final adSoyadController = TextEditingController();
  final telefonController = TextEditingController();
  final adresController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üye Ol')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: adSoyadController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            TextField(
  controller: telefonController,
  keyboardType: TextInputType.phone,
  decoration: const InputDecoration(
    labelText: 'Telefon',
    prefixText: '+90 ',
    hintText: '5XXXXXXXXX',
  ),
),
            TextField(
              controller: adresController,
              decoration: const InputDecoration(labelText: 'Adres'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (adSoyadController.text.isNotEmpty &&
    telefonController.text.isNotEmpty) {
                  UserData.adSoyad = adSoyadController.text;
                  UserData.telefon = telefonController.text;
                  UserData.adres = adresController.text;
                  await UserData.kaydet();
                  await FirebaseFirestore.instance.collection('uyeler').add({
                    'adSoyad': adSoyadController.text,
                    'telefon': telefonController.text,
                    'adres': adresController.text,
                    'kayitTarihi': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
class SepetEkrani extends StatefulWidget {
  const SepetEkrani({super.key});
  @override
  State<SepetEkrani> createState() => _SepetEkraniState();
}
class _SepetEkraniState extends State<SepetEkrani> {
    String? odemeYontemi;
  bool odemeSecildiMi = false;

    int _sepetToplamFiyat() {
    return SepetData.sepet.fold(0, (toplam, urun) => toplam + (urun['toplamFiyat'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
body: Column(
        children: [
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
  'Ödeme Yöntemini Seçin:',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: odemeSecildiMi ? Colors.black : Colors.red,
  ),
),

      DropdownButton<String>(
  hint: const Text('Bir ödeme yöntemi seçin'),
  value: odemeYontemi,
  onChanged: (String? yeniDeger) {
  setState(() {
    odemeYontemi = yeniDeger;
  });
},
        items: <String>['Havale/EFT', 'Kredi Kartı']
            .map<DropdownMenuItem<String>>((String deger) {
          return DropdownMenuItem<String>(
            value: deger,
            child: Text(deger),
          );
        }).toList(),
      ),
    ],
  ),
),
if (odemeYontemi == 'Havale/EFT')
  Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'IBAN: TR49 1234 5678 9012 3456 7890 12\nEnsar Plastik Kalıp A.Ş.',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: 'TR49 1234 5678 9012 3456 7890 12'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('IBAN kopyalandı')),
            );
          },
        ),
      ],
    ),
  ),



          Expanded(
            child: ListView.builder(
              itemCount: SepetData.sepet.length,
              itemBuilder: (context, index) {
                final urun = SepetData.sepet[index];
                return ListTile(
  leading: Image.asset(
    urun['gorsel'],
    width: 50,
    height: 50,
  ),
  title: Text(urun['urunAdi']),
  subtitle: Row(
  children: [
    IconButton(
      icon: const Icon(Icons.remove),
      onPressed: () {
        setState(() {
          if (urun['adet'] > 1) {
            urun['adet']--;
            urun['toplamFiyat'] =
                urun['adet'] * (urun['toplamFiyat'] ~/ (urun['adet'] + 1));
          }
        });
      },
    ),
    Text('${urun['adet']} adet'),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        setState(() {
          urun['adet']++;
          urun['toplamFiyat'] =
              urun['adet'] * (urun['toplamFiyat'] ~/ (urun['adet'] - 1));
        });
      },
    ),
  ],
),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('${urun['toplamFiyat']}₺'),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          setState(() {
            SepetData.sepet.removeAt(index);
          });
        },
      ),
    ],
  ),
);
              },
            ),
          ),
          Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0),
  child: Text(
    'Toplam: ${_sepetToplamFiyat()}₺',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
),

          Padding(
  padding: const EdgeInsets.all(16),
  child: ElevatedButton(
    onPressed: () async {
      if (!UserData.girisYapti) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Lütfen giriş yapın')),
  );
  await Future.delayed(const Duration(seconds: 2));
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
  );
  return;
}
  if (odemeYontemi == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lütfen ödeme yöntemini seçin')),
    );
    return;
  }
  print("Sipariş veriliyor...");

        await FirebaseFirestore.instance.collection('siparisler').add({
          'urunler': SepetData.sepet,
          'toplamFiyat': _sepetToplamFiyat(),
          'odemeYontemi': odemeYontemi,
          'adSoyad': UserData.adSoyad,
          'telefon': UserData.telefon,
          'adres': UserData.adres,
          'tarih': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siparişiniz alındı!')),
        );

        setState(() {
          SepetData.temizle();
          odemeSecildiMi = false;
        });

        Navigator.pop(context);
      },

    child: const Text('Siparişi Tamamla'),
  ),
),
        ],
      ),
    );
  }
}


class ProfilDuzenleEkrani extends StatefulWidget {
  const ProfilDuzenleEkrani({super.key});

  @override
  State<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends State<ProfilDuzenleEkrani> {
  final adSoyadController = TextEditingController();
  final adresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    adSoyadController.text = UserData.adSoyad ?? '';
    adresController.text = UserData.adres ?? '';
  }

  Future<void> guncelle() async {
    final yeniAd = adSoyadController.text.trim();
    final yeniAdres = adresController.text.trim();

    // Yerelde güncelle
    UserData.adSoyad = yeniAd;
    UserData.adres = yeniAdres;
    await UserData.kaydet();

    // Firestore'da güncelle
    final uyelerRef = FirebaseFirestore.instance.collection('uyeler');
    final query = await uyelerRef
        .where('telefon', isEqualTo: UserData.telefon)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await uyelerRef.doc(docId).update({
        'adSoyad': yeniAd,
        'adres': yeniAdres,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bilgiler güncellendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profili Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: adSoyadController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            TextField(
              controller: adresController,
              decoration: const InputDecoration(labelText: 'Adres'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: guncelle,
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
class SiparisGecmisiEkrani extends StatefulWidget {
  const SiparisGecmisiEkrani({super.key});

  @override
  State<SiparisGecmisiEkrani> createState() => _SiparisGecmisiEkraniState();
}

class _SiparisGecmisiEkraniState extends State<SiparisGecmisiEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sipariş Geçmişi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('siparisler')
            .where('telefon', isEqualTo: UserData.telefon)
            .orderBy('tarih', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
  if (snapshot.hasError) {
    return Center(child: Text('Hata: ${snapshot.error}'));
  }

  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }
          final siparisler = snapshot.data!.docs;

          if (siparisler.isEmpty) {
            return const Center(child: Text('Hiç siparişiniz yok.'));
          }

          return ListView.builder(
            itemCount: siparisler.length,
            itemBuilder: (context, index) {
              final siparis = siparisler[index].data() as Map<String, dynamic>;
              final tarih = (siparis['tarih'] as Timestamp).toDate();
              final urunler = siparis['urunler'] as List<dynamic>;
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tarih: ${tarih.toString().substring(0, 16)}'),
                      Text('Toplam: ${siparis['toplamFiyat']}₺'),
                      Text('Ödeme: ${siparis['odemeYontemi']}'),
                      const SizedBox(height: 6),
                      ...urunler.map((u) => Text('- ${u['urunAdi']} x${u['adet']}')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
