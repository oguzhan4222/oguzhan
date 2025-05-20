import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

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
