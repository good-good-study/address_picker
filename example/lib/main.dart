import 'package:address_picker/address_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '地址选择器',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        backgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: '地址选择器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///
  Province? province;
  City? city;
  Area? area;
  Street? street;

  String? _address = '未选择地址';

  /// 选择地址
  void _onAddress() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddressPicker(
          province: province,
          city: city,
          area: area,
          street: street,
          onConfirm: (province, city, area, street) async {
            this.province = province;
            this.city = city;
            this.area = area;
            this.street = street;
            if (province != null && city != null && area != null) {
              var address =
                  province.name + city.name + area.name + (street?.name ?? '');
              setState(() {
                _address = address;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '$_address',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddress,
        tooltip: '选择地址',
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
