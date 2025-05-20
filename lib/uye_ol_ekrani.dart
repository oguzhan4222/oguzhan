import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'package:flutter/services.dart';
import 'data/iller_ilceler.dart';



class UyeOlEkrani extends StatefulWidget {
  const UyeOlEkrani({super.key});

  @override
  State<UyeOlEkrani> createState() => _UyeOlEkraniState();
}

class _UyeOlEkraniState extends State<UyeOlEkrani> {
  final adSoyadController = TextEditingController();
  final telefonController = TextEditingController();
  final adresController = TextEditingController();
  String? secilenIl;
String? secilenIlce;
List<String> ilceListesi = [];
  String? telefonHataMesaji;
  String? adSoyadHataMesaji;
  String? adresHataMesaji;
  String? ilHataMesaji;
  String? ilceHataMesaji;

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
            if (adSoyadHataMesaji != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  adSoyadHataMesaji!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            TextField(
              controller: telefonController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixText: '+90 ',
                hintText: '5XXXXXXXXX',
                counterText: '',
              ),
            ),
            if (telefonHataMesaji != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  telefonHataMesaji!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            TextField(
              controller: adresController,
              decoration: const InputDecoration(labelText: 'Adres'),
            ),
            if (adresHataMesaji != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  adresHataMesaji!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButton<String>(
  isExpanded: true,
  hint: Text("İl seçiniz"),
  value: secilenIl,
  items: illerVeIlceler.keys
      .map((il) => DropdownMenuItem(value: il, child: Text(il)))
      .toList(),
  onChanged: (yeniIl) {
    setState(() {
      secilenIl = yeniIl;
      ilceListesi = illerVeIlceler[yeniIl] ?? [];
      secilenIlce = null; // İl değişince ilçe de sıfırlansın
    });
  },
),

            if (ilHataMesaji != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  ilHataMesaji!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButton<String>(
  isExpanded: true,
  hint: Text("İlçe seçiniz"),
  value: secilenIlce,
  items: ilceListesi
      .map((ilce) => DropdownMenuItem(value: ilce, child: Text(ilce)))
      .toList(),
  onChanged: (yeniIlce) {
    setState(() {
      secilenIlce = yeniIlce;
    });
  },
),

            if (ilceHataMesaji != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  ilceHataMesaji!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final ad = adSoyadController.text.trim();
                final tel = telefonController.text.trim();
                final adr = adresController.text.trim();

                setState(() {
                  adSoyadHataMesaji = (ad.isEmpty) ? 'Ad Soyad alanı boş bırakılmamalı.' : null;
                  telefonHataMesaji = (tel.length != 10) ? 'Lütfen 10 haneli geçerli bir telefon numarası girin.' : null;
                  adresHataMesaji = (adr.isEmpty) ? 'Adres alanı boş bırakılmamalı.' : null;
                  ilHataMesaji = (secilenIl == null) ? 'İl seçimi yapmalısınız.' : null;
                  ilceHataMesaji = (secilenIlce == null) ? 'İlçe seçimi yapmalısınız.' : null;
                });

                if (adSoyadHataMesaji != null ||
                    telefonHataMesaji != null ||
                    adresHataMesaji != null ||
                    ilHataMesaji != null ||
                    ilceHataMesaji != null) {
                  return;
                }

                final tamNumara = '+90$tel';
                final doc = await FirebaseFirestore.instance.collection('uyeler').doc(tamNumara).get();

                if (doc.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bu telefon numarası zaten kayıtlı')),
                  );
                  return;
                }

                UserData.adSoyad = ad;
                UserData.telefon = tamNumara;
                UserData.adres = adr;
                UserData.il = secilenIl;
                UserData.ilce = secilenIlce;

                await UserData.kaydet();

                await FirebaseFirestore.instance.collection('uyeler').doc(tamNumara).set({
                  'adSoyad': ad,
                  'telefon': tamNumara,
                  'adres': adr,
                  'il': secilenIl,
                  'ilce': secilenIlce,
                  'kayitTarihi': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
