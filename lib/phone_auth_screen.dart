import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'main.dart' show UyeOlEkrani, UrunSecimiEkrani;
import 'urun_secimi_ekrani.dart';
import 'uye_ol_ekrani.dart';

Map<String, List<String>> illerVeIlceler = {
  'Konya': ['Selçuklu', 'Meram', 'Karatay'],
  'İstanbul': ['Kadıköy', 'Beşiktaş', 'Üsküdar'],
  'Ankara': ['Çankaya', 'Keçiören', 'Yenimahalle'],
};

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String? secilenIl;
String? secilenIlce;
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  String verificationId = '';
  bool codeSent = false;
  String mesaj = '';

  Future<void> dogrulamaBaslat() async {
    String rawNumber =
        phoneController.text.replaceAll(RegExp(r'\s+'), '').trim();

    if (rawNumber.startsWith('0')) {
      rawNumber = rawNumber.substring(1); // baştaki 0'ı kaldır
    }

    final tamNumara = '+90$rawNumber';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: tamNumara,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // emülatörde otomatik giriş kapalı
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => mesaj = 'Hata: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  Future<void> koduDogrula() async {
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: codeController.text.trim(),
    );
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Telefonu +90 ile birlikte al
    String rawNumber = phoneController.text.replaceAll(RegExp(r'\s+'), '').trim();

if (rawNumber.startsWith('0')) {
  rawNumber = rawNumber.substring(1); // baştaki 0'ı kaldır
}

final tamNumara = '+90$rawNumber';

    // Firestore'daki uyeler koleksiyonunda arama yap
    final query = await FirebaseFirestore.instance
        .collection('uyeler')
        .where('telefon', isEqualTo: tamNumara)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final userDoc = query.docs.first.data();
      print("Firestore'dan gelen kullanıcı verisi: ${userDoc}");

UserData.telefon = userDoc['telefon'];
UserData.adSoyad = userDoc['adSoyad'];
UserData.adres = userDoc['adres'];
UserData.il = userDoc['il'] ?? '';
UserData.ilce = userDoc['ilce'] ?? '';
await UserData.kaydet();
await UserData.yukle();
    } else {
      // eğer kullanıcı kaydı yoksa, sadece telefon bilgisini kaydet
      UserData.telefon = tamNumara;
      await UserData.kaydet();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UrunSecimiEkrani()),
      (route) => false,
    );
  } catch (e) {
    setState(() => mesaj = 'Kod hatalı!');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telefon ile Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
  controller: phoneController,
  decoration: const InputDecoration(
    labelText: 'Telefon Numarası',
    prefixText: '+90 ',
    hintText: '5XXXXXXXXX',
    counterText: '',
  ),
  keyboardType: TextInputType.phone,
  maxLength: 10,
),
            const SizedBox(height: 4),
            const Text(
              'Numaranın başına 0 eklemeyin',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            if (codeSent)
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'SMS Kodu'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: codeSent ? koduDogrula : dogrulamaBaslat,
              child: Text(codeSent ? 'Kodu Doğrula' : 'Giriş Kodu Gönder'),
            ),
            TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UyeOlEkrani()),
    );
  },
  child: const Text(
    'Üye değil misiniz? Üye Ol',
    style: TextStyle(
      color: Colors.deepPurple,
      fontWeight: FontWeight.w500,
    ),
  ),
),
            if (mesaj.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(mesaj, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
