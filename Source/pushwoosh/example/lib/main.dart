import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pushwoosh/pushwoosh.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "Waiting..";
  String _log = "";
  bool _showAlert = false;

  set showAlert(bool value) {
    _showAlert = value;
    Pushwoosh.getInstance.setShowForegroundAlert(value);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Pushwoosh.initialize({"app_id": "5927F-D517A", "sender_id": "YOUR_SENDER_ID"});
    setState(() {
      _message = "Ready";
      addLog();
    });

    Pushwoosh pushwoosh = Pushwoosh.getInstance;

    pushwoosh.onPushReceived.listen((PushEvent event) {
      var message = event.pushwooshMessage;
      print("onPushReceived" + message.payload.toString());

      setState(() {
        _message = "Push Received:\n" + message.payload.toString();
        addLog();
      });
    });

    pushwoosh.onPushAccepted.listen((event) {
      var message = event.pushwooshMessage;
      print("onPushAccepted" + message.payload.toString());

      setState(() {
        _message = "Push Accepted:\n" + message.payload.toString();
        addLog();
      });
    });

    pushwoosh.onDeepLinkOpened.listen((String link) {
      var message = "Link opened:\n" + link;
      print(message);

      setState(() {
        _message = "Link opened:\n" + link;
        addLog();
      });
    });

    _showAlert = await pushwoosh.showForegroundAlert;
  }

  void _registerForPushNotifications() async {
    Pushwoosh pushwoosh = Pushwoosh.getInstance;

    String token = "empty";
    try {
      token = await pushwoosh.registerForPushNotifications();
    } catch (e) {
      token = e.toString();
    }

    setState(() {
      _message = "Registered for pushes with token: " + token;
      addLog();
    });
  }

  void _unregisterForPushNotifications() async {
    Pushwoosh pushwoosh = Pushwoosh.getInstance;

    String result = "Unregistered from push notifications";

    try {
      await pushwoosh.unregisterForPushNotifications();
    } catch (e) {
      result = e.toString();
    }

    setState(() {
      _message = result;
      addLog();
    });
  }

  void _getTags() async {
    Pushwoosh pushwoosh = Pushwoosh.getInstance;

    Map<dynamic, dynamic> tags;
    try {
      tags = await pushwoosh.getTags();
    } catch (e) {
      setState(() {
        _message = "Get tags failed:\n" + e.toString();
        addLog();
      });
    }

    setState(() {
      _message = "Tags:\n" + tags.toString();
      addLog();
    });
  }

  void _setTags() async {
    Pushwoosh pushwoosh = Pushwoosh.getInstance;

    Map<String, dynamic> tags = {"tag1": "value"};

    String result = "setTags completed: " + tags.toString();

    try {
      await pushwoosh.setTags(tags);
    } catch (e) {
      result = "Set tags failed:\n" + e.toString();
    }

    setState(() {
      _message = result;
      addLog();
    });
  }

  void _getHwid() async {
    String hwid = await Pushwoosh.getInstance.getHWID;

    setState(() {
      _message = "HWID: " + hwid;
      addLog();
    });
  }

  void _getToken() async {
    String token = await Pushwoosh.getInstance.getPushToken;

    setState(() {
      if (token != null) {
        _message = "Token: " + token;
      } else {
        _message = "No token";
      }
      addLog();
    });
  }

  void _postEvent() async {
    String result = "Event did sent";

    try {
      await Pushwoosh.getInstance.postEvent("ProductAdd", {"productId": 13344});
    } catch (e) {
      result = e.toString();
    }

    setState(() {
      _message = result;
      addLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.phone_android)),
                Tab(icon: Icon(Icons.sms)),
              ],
            ),
            title: Text('Pushwoosh'),
          ),
          body: TabBarView(
            children: [
              new Column(
                children: <Widget>[
                  new Container(
                    child: Text('$_message'),
                    padding: EdgeInsets.all(20.0),
                    height: 100.0,
                  ),
                  new Expanded(
                    child: new ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20.0),
                      children: <Widget>[
                        new CupertinoButton(
                          child: Text('registerForPushNotifications'),
                          onPressed: () => _registerForPushNotifications(),
                        ),
                        new CupertinoButton(
                          child: Text('unregisterForPushNotifications'),
                          onPressed: () => _unregisterForPushNotifications(),
                        ),
                        new CupertinoButton(
                          child: Text('getTags'),
                          onPressed: () => _getTags(),
                        ),
                        new CupertinoButton(
                          child: Text('setTags'),
                          onPressed: () => _setTags(),
                        ),
                        new CupertinoButton(
                          child: Text('getHWID'),
                          onPressed: () => _getHwid(),
                        ),
                        new CupertinoButton(
                          child: Text('getPushToken'),
                          onPressed: () => _getToken(),
                        ),
                        new CupertinoButton(
                          child: Text('postEvent'),
                          onPressed: () => _postEvent(),
                        ),
                        new MergeSemantics(
                          child: new ListTile(
                            title: new Text('showForegroundAlert'),
                            trailing: new CupertinoSwitch(
                              value: _showAlert,
                              onChanged: (bool value) {
                                setState(() {
                                  this.showAlert = value;
                                  _message = "showForegroundAlert: " +
                                      value.toString();
                                });
                              },
                            ),
                            onTap: null,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              new ListView(
                  children: <Widget>[
                    new CupertinoButton(onPressed: _clearLog,
                      child: Text('Clear log')
                    ),
                    new Container(
                  child: Text('$_log'),
                  padding: EdgeInsets.all(5.0),
                )
                  ]
              )
            ],
          ),
        ),
      ),
    );
  }

  void _clearLog(){
    setState(() {
      _log = "";
    });
  }

  void addLog() {
    setState(() {
      _log += "\n\n" + _message;
    });
  }

}
