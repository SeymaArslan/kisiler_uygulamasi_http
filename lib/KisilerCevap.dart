import 'package:kisiler_uygulamasi_http/Kisiler.dart';

class KisilerCevap{
  int success;
  List<Kisiler> kisilerListesi;

  KisilerCevap(this.success, this.kisilerListesi);

  factory KisilerCevap.fromJson(Map<String, dynamic> json){
    var jsonArray = json["kisiler"] as List;
    List<Kisiler> kisilerListesi = jsonArray.map((jsonArrayNesnesi) => Kisiler.fromJson(jsonArrayNesnesi)).toList(); // buradaki e değeri bize sırayla listedeki her alanı getirecek,
    // bizde bu değerleri Kisiler sınıfında parse ederek kisiler nesnesine dönüştüreceğiz
    return KisilerCevap(json["success"] as int, kisilerListesi);  // success bilgisini de burada parse edip alıyoruz
  }
}