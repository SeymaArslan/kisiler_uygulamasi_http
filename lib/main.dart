import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kisiler_uygulamasi_http/KisiDetaySayfa.dart';
import 'package:kisiler_uygulamasi_http/KisiKayitSayfa.dart';
import 'package:kisiler_uygulamasi_http/Kisiler.dart';
import 'package:kisiler_uygulamasi_http/KisilerCevap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {

  bool aramaYapiliyorMu = false;
  String aramaKelimesi = "";

  List<Kisiler> parseKisilerCevap(String cevap){  // cevap a web service ta ki json cevabı göndereceğiz
    return KisilerCevap.fromJson(json.decode(cevap)).kisilerListesi;  // bu cevabı da parse ederek bana kisilerListesi olarak verileri verecek
  }
  
  Future<List<Kisiler>> tumKisiler() async{
    var url = Uri.parse("http://localhost/web-services-kisiler/tum_kisiler.php");
    var cevap = await http.get(url); // yukarıda bahsettiğimiz cevap a web service ten cevap göndermeyi burada gerçekleştiriyoruz
    return parseKisilerCevap(cevap.body);
  }

  Future<List<Kisiler>> aramaYap(String aramaKelimesi) async{
    var url = Uri.parse("http://localhost/web-services-kisiler/tum_kisiler_arama.php");
    var veri = {"kisi_ad":aramaKelimesi};
    var cevap = await http.post(url, body: veri);
    return parseKisilerCevap(cevap.body);
  }

  Future<void> sil(int kisi_id) async{
    var url = Uri.parse("http://localhost/web-services-kisiler/delete_kisiler.php");
    var veri = {"kisi_id":kisi_id.toString()}; // kisi_id yukarıda int olarak geliyor ve http her kisi_id nin de String olmasını bekliyor ve Stringe dönüştürüyoruz
    var cevap = await http.post(url, body: veri);
    print("Silme cevap: ${cevap.body}");  // silme sonucunda bir cevap gelecek ya silme sonucunu başarılı veya başarısız olarak web service tan çekeceğiz
    setState(() {
    });
  }

  Future<bool> uygulamayiKapat() async{
    await exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            uygulamayiKapat();
          },
        ),
        title: aramaYapiliyorMu ?
        TextField(
          decoration: InputDecoration(hintText: "Arama için bir şey yazın"),
          onChanged: (aramaSonucu){
            print("Arama sonucu : $aramaSonucu");
            setState(() {
              aramaKelimesi = aramaSonucu;
            });
          },
        )
            : Text("Kişiler Uygulaması"),
        actions: [
          aramaYapiliyorMu ?
          IconButton(
              onPressed: (){
                setState(() {
                  aramaYapiliyorMu = false;
                  aramaKelimesi = "";
                });
              },
              icon: Icon(Icons.cancel_outlined, color: Colors.deepOrangeAccent,)
          )
              :IconButton(
            onPressed: (){
              setState(() {
                aramaYapiliyorMu = true;
              });
            },
            icon: Icon(Icons.search, color: Colors.black,),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: uygulamayiKapat,
        child: FutureBuilder<List<Kisiler>>(
          future: aramaYapiliyorMu ? aramaYap(aramaKelimesi): tumKisiler(), // tumKisiler metodunu kullanarak listemize eriştik
          builder: (context, snapshot){
            if(snapshot.hasData){
              var kisilerListesi = snapshot.data;
              return ListView.builder(
                itemCount: kisilerListesi!.length,
                itemBuilder: (context, index){  // döngü gibi olan
                  var kisi = kisilerListesi[index];
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => KisiDetaySayfa(kisi: kisi,)));
                    },
                    child: Card(
                      child: SizedBox( height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(kisi.kisi_ad, style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(kisi.kisi_tel,),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.grey,),
                              onPressed: (){
                                sil(int.parse(kisi.kisi_id));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else  {
              return Center();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => KisiKayitSayfa()));
        },
        tooltip: "Kişi Ekle",
        child: const Icon(Icons.add),
      ),
    );
  }
}
