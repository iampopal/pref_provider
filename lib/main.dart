import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.debugCheckInvalidValueType = null;
    return FutureProvider<PrefProvider>(
      create: (context) => PrefProvider.getInstance(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prefProvider = Provider.of<PrefProvider>(context);
    final textStyle = TextStyle(
      fontWeight: prefProvider.isBold() ? FontWeight.bold : FontWeight.normal,
      fontSize: prefProvider.getSize(),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Pref Provider"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingPage()));
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          prefProvider.getText(),
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<PrefProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("Bold"),
            trailing: Switch(
              value: pref.isBold(),
              onChanged: (bool value) {
                setState(() {
                  pref.setBold(value);
                });
              },
            ),
          ),
          ListTile(
            onTap: () {
              _showDialog(context, pref);
            },
            title: Text("Text"),
            subtitle: Text(pref.getText()),
          ),
          ListTile(
            title: Text("Font Size"),
            subtitle: Slider(
              onChanged: (v) {
                setState(() {
                  pref.setSize(v);
                });
              },
              value: pref.getSize(),
              min: 0,
              max: 100,
              label: "Hello",
            ),
          ),
        ],
      ),
    );
  }

  Future _showDialog(BuildContext context, PrefProvider pref) {
    return showDialog(
      context: context,
      builder: (context) {
        String text = "";
        return AlertDialog(
          title: Text("Text"),
          content: TextField(
            onChanged: (t) => text = t,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  pref.setText(text);
                  Navigator.pop(context);
                });
              },
            )
          ],
        );
      },
    );
  }
}

class PrefProvider extends ChangeNotifier {
  SharedPreferences sharedPreferences;
  PrefProvider();

  static Future<PrefProvider> getInstance() async {
    PrefProvider prefProvider = PrefProvider();
    prefProvider.sharedPreferences = await SharedPreferences.getInstance();
    return prefProvider;
  }

  bool isBold() => sharedPreferences.getBool("bold") ?? false;

  setBold(bool bold) {
    sharedPreferences.setBool("bold", bold);
    notifyListeners();
  }

  String getText() => sharedPreferences.getString("text") ?? "Hello World";

  setText(String text) {
    sharedPreferences.setString("text", text);
    notifyListeners();
  }

  double getSize() => sharedPreferences.getDouble("size") ?? 24;

  setSize(double size) {
    sharedPreferences.setDouble("size", size);
    notifyListeners();
  }
}
