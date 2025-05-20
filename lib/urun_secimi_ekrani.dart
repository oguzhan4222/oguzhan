import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_data.dart';
import 'phone_auth_screen.dart';
import 'sepet_ekrani.dart';
import 'profil_duzenle_ekrani.dart';
import 'siparis_gecmisi_ekrani.dart';
import 'uye_ol_ekrani.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kvkk_ekrani.dart';
import 'fatura_bilgileri_ekrani.dart';



class SplashEkrani extends StatefulWidget {
  const SplashEkrani({super.key});

  @override
  State<SplashEkrani> createState() => _SplashEkraniState();
}

class _SplashEkraniState extends State<SplashEkrani> {
  @override
void initState() {
  super.initState();
  // kullanıcı verisini yükle
  UserData.yukle().then((_) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UrunSecimiEkrani()),
      );
    });
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
} // ✅ Bu parantez en sona gelmeli


class UrunSecimiEkrani extends StatefulWidget {
  const UrunSecimiEkrani({super.key});

  @override
  State<UrunSecimiEkrani> createState() => _UrunSecimiEkraniState();
}

class _UrunSecimiEkraniState extends State<UrunSecimiEkrani> {
  final PageController _pageController = PageController();
int _aktifSliderIndex = 0;

@override
void initState() {
  super.initState();

  UserData.yukle().then((_) {
    setState(() {});
  });

  // SLIDER AUTO PLAY
  Timer.periodic(const Duration(seconds: 3), (timer) {
    if (_pageController.hasClients) {
      int nextPage = (_aktifSliderIndex + 1) % 3;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  });
}

  void _urunTiklandi(String urunAdi, int birimFiyat, String gorsel) async {
  await showDialog(
    context: context,
    builder: (_) => AdetSecDialog(
      urunAdi: urunAdi,
      birimFiyat: birimFiyat,
      gorselUrl: gorsel, // ✅ Doğrusu bu (soldaki isim değişti)
      onEklendi: () {
        setState(() {});
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.blue, // 👈 mavi zemin
  title: const Text(
    'TaşıKolay',
    style: TextStyle(color: Colors.white), // 👈 beyaz yazı
  ),
  actions: [
    if (UserData.girisYapti)
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'duzenle') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilDuzenleEkrani()));
            } else if (value == 'gecmis') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SiparisGecmisiEkrani()));
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
                  color: Colors.white, // 👈 beyaz isim
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white), // 👈 beyaz ikon
            ],
          ),
        ),
      ),
    IconButton(
      icon: const Icon(Icons.menu, color: Colors.white), // 👈 beyaz menü
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
  onTap: () {
    Navigator.pop(context); // menüyü kapat
    if (UserData.girisYapti) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FaturaBilgileriEkrani()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PhoneAuthScreen()));
    }
  },
),

  ListTile(
  leading: const Icon(Icons.lock),
  title: const Text('K.V.K.K'),
  onTap: () {
    Navigator.pop(context); // menüyü kapat
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KvkkEkrani()),
    );
  },
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
    if (!UserData.girisYapti)
      IconButton(
        icon: const Icon(Icons.person, color: Colors.white),
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

      body: Column(
  children: [
    // SLIDER BÖLÜMÜ
    SizedBox(
  height: 130,
  width: double.infinity,
  child: Stack(
    children: [
      PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _aktifSliderIndex = index;
          });
        },
        children: [
          Image.asset('assets/slider1.jpg', fit: BoxFit.cover),
          Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
          Image.asset('assets/slider3.jpg', fit: BoxFit.cover),
        ],
      ),
      Positioned(
        bottom: 10,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _aktifSliderIndex == index ? Colors.white : Colors.white54,
              ),
            );
          }),
        ),
      ),
    ],
  ),
),

    // ÜRÜN GRİDİ
    Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('urunler')
        .where('aktif', isEqualTo: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;

      return GridView.builder(
        itemCount: docs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final urun = docs[index].data() as Map<String, dynamic>;
          final String isim = urun['isim'] ?? 'Ürün';
          final double fiyat = (urun['fiyat'] as num).toDouble();
          final String gorsel = urun['gorselUrl'] ?? '';

          return GestureDetector(
            onTap: () => _urunTiklandi(isim, fiyat.toInt(), gorsel),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        gorsel,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fiyat: ${fiyat.toStringAsFixed(1)}₺',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      isim,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),



  ],
),

      bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(12),
  child: ElevatedButton.icon(
    onPressed: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SepetEkrani(),
        ),
      );

      if (result == true) {
        setState(() {}); // Sepet boşaldıysa güncelle
      }
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
  final String gorselUrl;
  final VoidCallback? onEklendi;

  const AdetSecDialog({
    super.key,
    required this.urunAdi,
    required this.birimFiyat,
    required this.gorselUrl,
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

    return Dialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Container(
  padding: const EdgeInsets.all(16),
  width: MediaQuery.of(context).size.width * 0.9,
  height: 600,
  child: Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.start, // 👈 BU SATIRI EKLE
  children: [
        Text(
          widget.urunAdi,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Image.network(
  widget.gorselUrl,
  height: 350,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error, size: 100, color: Colors.red);
  },
),
        const SizedBox(height: 6),
        const Spacer(),
        Text('Birim Fiyat: ${widget.birimFiyat}₺'),
        const SizedBox(height: 6),
        Text('Toplam: ${adet * widget.birimFiyat}₺'),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (adet > 1) {
                  setState(() {
                    adet--;
                  });
                }
              },
            ),
            Text(
              '$adet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  adet++;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                SepetData.ekle(
  urunAdi: widget.urunAdi,
  adet: adet,
  toplamFiyat: adet * widget.birimFiyat,
  gorselUrl: widget.gorselUrl, // 👈 görsel linki de gönderiliyor
);
                widget.onEklendi?.call();
                Navigator.pop(context);
              },
              child: const Text('Sepete Ekle'),
            ),
          ],
        )
      ],
    ),
  ),
);
  }
}
