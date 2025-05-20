import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'phone_auth_screen.dart';

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
                  leading: Image.network(
  urun['gorselUrl'] ?? '', // sepetteki ürünün görsel linki
  width: 50,
  height: 50,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.image_not_supported, size: 50); // hata olursa ikon göster
  },
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                await UserData.yukle(); // <-- EN BAŞA EKLE!
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

                await FirebaseFirestore.instance.collection('siparisler').add({
                  'urunler': SepetData.sepet,
                  'toplamFiyat': _sepetToplamFiyat(),
                  'odemeYontemi': odemeYontemi,
                  'adSoyad': UserData.adSoyad,
                  'telefon': UserData.telefon,
                  'adres': UserData.adres,
                  'tarih': Timestamp.now(),
                  'faturaUnvani': UserData.faturaUnvani,
                  'vergiNo': UserData.vergiNo,
                  'vergiDairesi': UserData.vergiDairesi,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Siparişiniz alındı!')),
                );

                setState(() {
                  SepetData.temizle();
                  odemeSecildiMi = false;
                });

                Navigator.pop(context, true); // sepet temizlendi bilgisini gönder
              },
              child: const Text('Siparişi Tamamla'),
            ),
          ),
        ],
      ),
    );
  }
}
