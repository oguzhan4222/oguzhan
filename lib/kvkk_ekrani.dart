import 'package:flutter/material.dart';

class KvkkEkrani extends StatelessWidget {
  const KvkkEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Aydınlatma Metni'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildExpansionTile(
            title: 'KVKK METNİ',
            content:
                '6698 Sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) kapsamında, Ensar Plastik Kalıp olarak kişisel verilerinizin güvenliğine büyük önem veriyoruz. Bu metin, kişisel verilerinizin hangi amaçlarla işlenebileceği, kimlere aktarılabileceği, hangi yöntemlerle toplandığı ve KVKK kapsamında sahip olduğunuz haklar hakkında sizi bilgilendirmek amacıyla hazırlanmıştır.\n\n'
                'İşlenen Kişisel Veriler:\nAd-soyad, telefon numarası, adres, il ve ilçe bilgileri.\n\n'
                'İşleme Amaçları:\n• Sipariş işlemlerinin gerçekleştirilmesi\n• Müşteri hizmetleri süreçlerinin yürütülmesi\n• Ürün teslimatının sağlanması\n• İletişim ve bilgilendirme faaliyetlerinin yürütülmesi.\n\n'
                'Hukuki Sebep:\nKişisel verileriniz, “bir sözleşmenin kurulması ve ifası için gerekli olması” ve “veri sorumlusunun meşru menfaati” hukuki sebeplerine dayanarak toplanmaktadır.\n\n'
                'Veri Aktarımı:\nVerileriniz, yalnızca yukarıda belirtilen amaçlar doğrultusunda, yasal yükümlülükler gereği yetkili kamu kurum ve kuruluşlarına aktarılabilir.\n\n'
                'Haklarınız:\nKVKK\'nın 11. maddesi uyarınca:\n• Kişisel verinizin işlenip işlenmediğini öğrenme\n• İşlenmişse bilgi talep etme\n• Amacına uygun kullanılıp kullanılmadığını öğrenme\n• Aktarıldığı üçüncü kişileri bilme\n• Eksik veya yanlış işlenmişse düzeltilmesini isteme\n• Kanuna aykırı işlenmişse silinmesini/yok edilmesini talep etme\n• Bu işlemlerin aktarıldığı üçüncü kişilere bildirilmesini isteme\n\n'
                'İletişim:\nVeri Sorumlusu: Ensar Plastik Kalıp\n📞 +90 530 448 8871',
          ),
          const SizedBox(height: 10),
          _buildExpansionTile(
            title: 'GİZLİLİK POLİTİKASI',
            content:
                'Ensar Plastik Kalıp olarak kullanıcı bilgilerinin gizliliğine önem veriyoruz. Ancak kullanıcı tarafından sunulan kişisel bilgiler, siparişin alınması, işlenmesi ve teslim edilmesi amacıyla kullanılır.\n\n'
                'Uygulamamızda yer alan tüm içerik ve işlemler kullanıcıya bilgilendirme amacı taşır. Kullanıcı, uygulamayı kullanarak verdiği bilgilerin doğru ve güncel olduğunu kabul eder. Yanıltıcı ya da eksik bilgi verilmesinden doğabilecek hukuki sorumluluk tamamen kullanıcıya aittir.\n\n'
                'Ensar Plastik Kalıp, kullanıcıya ait verileri yasal gereklilikler haricinde üçüncü kişilerle paylaşmaz. Ancak kullanıcı, uygulamayı kullanarak bu şartları ve gizlilik politikasını kabul etmiş sayılır.\n\n'
                'Kullanıcı, hizmetin işleyişinden veya uygulama kullanımından kaynaklı herhangi bir zararda Ensar Plastik Kalıp’ı sorumlu tutamaz.',
          ),
          const SizedBox(height: 10),
          _buildExpansionTile(
            title: 'KULLANICI SÖZLEŞMESİ',
            content:
                'Bu uygulamayı kullanarak aşağıdaki şartları kabul etmiş sayılırsınız:\n\n'
                '1. Kullanıcı, verdiği bilgilerin (ad-soyad, adres, telefon vs.) doğru ve eksiksiz olduğunu beyan eder. Yanıltıcı veya hatalı bilgi verilmesi durumunda oluşabilecek tüm sorumluluk kullanıcıya aittir.\n\n'
                '2. Sipariş işlemleri sırasında yaşanabilecek gecikme, ürün stok durumu, teknik aksaklıklar veya teslimat sorunlarından dolayı doğabilecek doğrudan veya dolaylı zararlardan Ensar Plastik Kalıp sorumlu tutulamaz.\n\n'
                '3. Kullanıcı, uygulama üzerinden sağlanan hizmetlerin kesintisiz ve hatasız olacağını garanti etmediğini kabul eder.\n\n'
                '4. Kullanıcı, uygulama içeriğini kopyalayamaz, çoğaltamaz veya ticari amaçla kullanamaz.\n\n'
                '5. Ensar Plastik Kalıp, kullanıcı sözleşmesini önceden haber vermeksizin değiştirme hakkını saklı tutar.',
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Text(
              content,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
