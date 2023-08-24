import 'dart:io';
import 'dart:math';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_bile_app/data.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false,
    home: detail(),
  ));
}
class detail extends StatefulWidget {
  const detail({Key? key}) : super(key: key);

  @override
  State<detail> createState() => _detailState();
}

class _detailState extends State<detail> {
  TextEditingController t1 = TextEditingController();
  List<DropdownMenuItem> totquan = [];
  List<String> perqnty = [];
  List<bool> check = [];
  List<String> product = [];
  List<String> pric = [];
  List<String> proqnty = [];
  List<String> totl = [];
  int sum = 0;
  int allsum = 0;
  int sub = 0;
  int allsub = 0;
  int total = 0;
  List ttl = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //get();
    perqnty = List.filled(data.prod_name.length, "0");
    check = List.filled(data.prod_name.length, false);

    totquan.add(DropdownMenuItem(
      child: Text("0"),
      value: "0",
    ));

    for (int i = 1; i <= 10; i++) {
      totquan.add(DropdownMenuItem(
        child: Text("${i}"),
        value: "${i}",
      ));
      setState(() {});
    }
  }
  get() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
      ].request();
    }
  }
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('image/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HP COMPUTERS ™"),
      ),
      body: Column(
        children: [
          TextField(
              controller: t1,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                  hintText: "Buyer name",
                  labelText: "Enter your name",
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)))),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(child: Text("Product"),width: 100,),
              SizedBox(child: Text("Quantity"),width: 100,),
              SizedBox(child: Text("Price"),width: 80,),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${data.prod_name[index]}"),
                        DropdownButton(
                          items: totquan,
                          value: perqnty[index],
                          onChanged: (value) {
                            perqnty[index] = value;
                            perqnty[index] = value;
                            perqnty[index] = value;
                            setState(() {});
                          },
                        ),
                        Text("${data.price[index]}")
                      ],
                    ),
                    trailing: Checkbox(
                      value: check[index],
                      onChanged: (value) {
                        check[index] = value as bool;
                        print(check);
                        if(check[index]==true){
                          product.add("${data.prod_name[index]}");
                          pric.add("${data.price[index]}");
                          total = int.parse(perqnty[index])*int.parse(pric[index]);
                          sum = sum + int.parse(perqnty[index]);
                          total.toString();
                          ttl.add(total);
                          allsum = allsum + total;
                          print(allsum);
                        }else if(check[index]==false){
                          product.remove(data.prod_name[index]);
                          pric.remove(perqnty[index]);
                          sub = sum - int.parse(perqnty[index]);
                          sum = sub;
                          total = int.parse(perqnty[index])*int.parse(pric[index]);
                          ttl.remove(total);
                          allsub = allsum - total;
                          allsum = allsub;
                          print(allsum);
                          setState(() {

                          });
                        }
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Spacer(),
          ActionChip(onPressed: () async {
            PdfDocument document = PdfDocument();
            PdfPage apage = document.pages.add();
            apage.graphics.drawString(
                'HP COMPUTERS', PdfStandardFont(PdfFontFamily.timesRoman, 25),
                brush: PdfSolidBrush(PdfColor(0, 0, 0)),
                bounds: const Rect.fromLTWH(10, 10, 350, 30));

            apage.graphics.drawString(
                '________________________________________________________________________________________',
                PdfStandardFont(PdfFontFamily.timesRoman, 25),
                brush: PdfSolidBrush(PdfColor(0, 0, 0)),
                bounds: const Rect.fromLTWH(10, 40, 550, 30));

            apage.graphics.drawString(
                'Name: ${t1.text}', PdfStandardFont(PdfFontFamily.courier, 15),
                brush: PdfSolidBrush(PdfColor(0, 0, 0)),
                bounds: const Rect.fromLTWH(10, 85, 200, 25));

            File f = await getImageFileFromAssets('images.jpeg');
            Uint8List imageData = f.readAsBytesSync();
            PdfBitmap image = PdfBitmap(imageData);
            apage.graphics.drawImage(image, Rect.fromLTWH(440, 0, 50, 50));

            PdfGrid grid = PdfGrid();
            grid.columns.add(count: 4);
            final PdfGridRow headerRow = grid.headers.add(1)[0];
            headerRow.cells[0].value = 'Product Name';
            headerRow.cells[1].value = 'Quantity';
            headerRow.cells[2].value = 'Price';
            headerRow.cells[3].value = 'PRO.Total';
            headerRow.style.font =
                PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

            for(int i=0;i<product.length;i++){
              PdfGridRow row = grid.rows.add();
              row.cells[0].value = '${product[i]}';
              row.cells[1].value = '${perqnty[i]}';
              row.cells[2].value = '${pric[i]}';
              row.cells[3].value = '${ttl[i]}';
            }
            PdfGridRow row = grid.rows.add();
            row.cells[0].value = 'TOTAL';
            row.cells[1].value = '$sum';
            row.cells[2].value = '--';
            row.cells[3].value = '$allsum';


            grid.style.cellPadding = PdfPaddings(left: 5, top: 5);
            grid.draw(
                page: apage,
                bounds: Rect.fromLTWH(
                    10, 110, apage.getClientSize().width, apage.getClientSize().height));



            var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS) + "/myd";

            Directory dir = Directory(path);
            if(! await dir.exists()){
              dir.create();
            }
            String doc_name = "${Random().nextInt(1000)}.pdf";
            if(t1.text!=""){
              File f1 = File("${dir.path}/$doc_name");
              f1.writeAsBytes(await document.save());
              document.dispose();

              OpenFile.open(f1.path);

            }else{
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter your name first")));
            }
            setState(() {

            });
          },label: Text("SUBMIT")),
          Spacer(),
        ],
      ),
    );
  }
}