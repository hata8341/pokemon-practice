import 'package:flutter/material.dart';
import 'package:pokepoke/models/theme_mode.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, mode, child) => ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lightbulb),
            title: const Text('Dark/Light Mode'),
            trailing: Text((mode.mode == ThemeMode.system)
                ? 'System'
                : (mode.mode == ThemeMode.dark ? 'Dark' : 'Light')),
            onTap: () async {
              // settingsとthememodeSelectionPageでmodeの受け渡しをするためにデータの方を<ThemeMode>で定義する
              var ret = await Navigator.of(context).push<ThemeMode>(
                  MaterialPageRoute(
                      builder: (context) =>
                          ThemeModeSelectionPage(mode: mode.mode)));
              print(ret);
              if (ret != null) {
                mode.update(ret);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ThemeModeSelectionPage extends StatefulWidget {
  const ThemeModeSelectionPage({Key? key, required this.mode})
      : super(key: key);
  final ThemeMode mode;

  @override
  _ThemeModeSelectionPageState createState() => _ThemeModeSelectionPageState();
}

class _ThemeModeSelectionPageState extends State<ThemeModeSelectionPage> {
  late ThemeMode _current;

  @override
  void initState() {
    super.initState();
    _current = widget.mode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                  onPressed: () => Navigator.pop<ThemeMode>(context, _current),
                  icon: const Icon(Icons.arrow_back)),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _current,
              // _currentにnullは代入できないのでval!<-で明示する
              onChanged: (val) => {setState(() => _current = val!)},
              title: const Text('System'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _current,
              onChanged: (val) => {setState(() => _current = val!)},
              title: const Text('Dark'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _current,
              onChanged: (val) => {setState(() => _current = val!)},
              title: const Text('Light'),
            ),
          ],
        ),
      ),
    );
  }
}
