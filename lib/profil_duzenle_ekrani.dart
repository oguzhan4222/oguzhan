import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'data/iller_ilceler.dart';


class ProfilDuzenleEkrani extends StatefulWidget {
  const ProfilDuzenleEkrani({super.key});

  @override
  State<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends State<ProfilDuzenleEkrani> {
  final adSoyadController = TextEditingController();
  final adresController = TextEditingController();
  String? seciliIl;
String? seciliIlce;
List<String> ilceListesi = [];



  @override
void initState() {
  super.initState();
    adSoyadController.text = UserData.adSoyad ?? '';
  adresController.text = UserData.adres ?? '';
  seciliIl = UserData.il; // Kullanıcının kayıtlı ili
  seciliIlce = UserData.ilce; // Kullanıcının kayıtlı ilçesi

  // Eğer il seçiliyse, ona ait ilçeleri getir
  if (seciliIl != null && illerVeIlceler.containsKey(seciliIl)) {
    ilceListesi = illerVeIlceler[seciliIl]!;
  }
}



  Future<void> guncelle() async {
    final yeniAd = adSoyadController.text.trim();
    final yeniAdres = adresController.text.trim();

    UserData.adSoyad = yeniAd;
    UserData.adres = yeniAdres;
    await UserData.kaydet();

    final uyelerRef = FirebaseFirestore.instance.collection('uyeler');
    final query = await uyelerRef
        .where('telefon', isEqualTo: UserData.telefon)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      UserData.il = seciliIl;
UserData.ilce = seciliIlce;

await uyelerRef.doc(docId).update({
  'adSoyad': yeniAd,
  'adres': yeniAdres,
  'il': seciliIl,
  'ilce': seciliIlce,
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
            const SizedBox(height: 16),

DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'İl Seçin'),
  value: seciliIl,
  items: illerVeIlceler.keys.map((il) {
    return DropdownMenuItem(
      value: il,
      child: Text(il),
    );
  }).toList(),
  onChanged: (yeniIl) {
    setState(() {
      seciliIl = yeniIl;
      seciliIlce = null;
    });
  },
),

const SizedBox(height: 16),

DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'İlçe Seçin'),
  value: seciliIlce,
  items: (seciliIl != null)
      ? illerVeIlceler[seciliIl]!.map((ilce) {
          return DropdownMenuItem(
            value: ilce,
            child: Text(ilce),
          );
        }).toList()
      : [],
  onChanged: (yeniIlce) {
    setState(() {
      seciliIlce = yeniIlce;
    });
  },
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
