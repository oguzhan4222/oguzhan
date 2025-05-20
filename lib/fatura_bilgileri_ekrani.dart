import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class FaturaBilgileriEkrani extends StatefulWidget {
  const FaturaBilgileriEkrani({super.key});

  @override
  State<FaturaBilgileriEkrani> createState() => _FaturaBilgileriEkraniState();
}

class _FaturaBilgileriEkraniState extends State<FaturaBilgileriEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _adSoyadController = TextEditingController();
  final _vergiNoController = TextEditingController();
  final _vergiDairesiController = TextEditingController();
  final _adresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() async {
    final telefon = UserData.telefon ?? 'bilinmiyor';
final belge = await FirebaseFirestore.instance
    .collection('fatura_bilgileri')
    .doc(telefon)
    .get();


    if (belge.exists) {
      final data = belge.data()!;
      _adSoyadController.text = data['adSoyad'] ?? '';
      _vergiNoController.text = data['vergiNo'] ?? '';
      _vergiDairesiController.text = data['vergiDairesi'] ?? '';
      _adresController.text = data['adres'] ?? '';
    }
  }

  void _kaydet() async {
  if (_formKey.currentState!.validate()) {
    final telefon = UserData.telefon ?? 'bilinmiyor';

    // --- UserData'ya fatura bilgilerini yaz ve kaydet ---
    UserData.faturaUnvani = _adSoyadController.text.trim();
    UserData.vergiNo = _vergiNoController.text.trim();
    UserData.vergiDairesi = _vergiDairesiController.text.trim();
    UserData.adres = _adresController.text.trim();
    await UserData.kaydet();
    // -----------------------------------------------------

    await FirebaseFirestore.instance
        .collection('fatura_bilgileri')
        .doc(telefon)
        .set({
      'adSoyad': _adSoyadController.text.trim(),
      'vergiNo': _vergiNoController.text.trim(),
      'vergiDairesi': _vergiDairesiController.text.trim(),
      'adres': _adresController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fatura bilgileri kaydedildi')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fatura Bilgilerim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _adSoyadController,
                decoration: const InputDecoration(labelText: 'Ad Soyad / Firma Ünvanı'),
                validator: (value) => value == null || value.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              TextFormField(
                controller: _vergiNoController,
                decoration: const InputDecoration(labelText: 'T.C. No / Vergi Numarası'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              TextFormField(
                controller: _vergiDairesiController,
                decoration: const InputDecoration(labelText: 'Vergi Dairesi (sadece tüzel kişiler için)'),
              ),
              TextFormField(
                controller: _adresController,
                decoration: const InputDecoration(labelText: 'Adres'),
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Adres gerekli' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _kaydet,
                child: const Text('Kaydet'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
