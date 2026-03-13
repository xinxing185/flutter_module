import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter_module/widget/custom_switch.dart';

import 'core/app_lifecycle_observer.dart';
import 'core/app_navigator.dart';
import 'core/immersive_status_bar.dart';

void main() {
  ///添加全局生命周期监听类
  PageVisibilityBinding.instance.addGlobalObserver(AppLifecycleObserver());
  ///这里的CustomFlutterBinding调用务必不可缺少，用于控制Boost状态的resume和pause
  CustomFlutterBinding();
  runApp(MyApp());
  // FlutterBoost.instance.setup(
  //   appBuilder: appBuilder,
  //   initialRoute: '/',
  //   pageBuilders: {
  //     'flutterPage': (String pageName, Map<String, dynamic> params, String? _) => FlutterPage(params: params),
  //     'secondFlutterPage': (String pageName, Map<String, dynamic> params, String? _) => SecondFlutterPage(params: params),
  //   },
  // );
}

void _setImmersiveStatusBar() {
  print("_setImmersiveStatusBar");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 透明状态栏
      statusBarIconBrightness: Brightness.dark, // 状态栏图标白色
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.lightBlue, // 底部导航栏颜色
      systemNavigationBarIconBrightness: Brightness.light, )); // 隐藏状态栏 & 底部导航栏，沉浸模式
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

///创建一个自定义的Binding，继承和with的关系如下，里面什么都不用写
class CustomFlutterBinding extends WidgetsFlutterBinding with BoostFlutterBinding {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 由于很多同学说没有跳转动画，这里是因为之前exmaple里面用的是 [PageRouteBuilder]，
  /// 其实这里是可以自定义的，和Boost没太多关系，比如我想用类似iOS平台的动画，
  /// 那么只需要像下面这样写成 [CupertinoPageRoute] 即可
  /// (这里全写成[MaterialPageRoute]也行，这里只不过用[CupertinoPageRoute]举例子)
  ///
  /// 注意，如果需要push的时候，两个页面都需要动的话，
  /// （就是像iOS native那样，在push的时候，前面一个页面也会向左推一段距离）
  /// 那么前后两个页面都必须是遵循CupertinoRouteTransitionMixin的路由
  /// 简单来说，就两个页面都是CupertinoPageRoute就好
  /// 如果用MaterialPageRoute的话同理

  Map<String, FlutterBoostRouteFactory> routerMap = {
    '/': (settings, isContainerPage, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            // Map<String, dynamic> map = settings.arguments as Map<String, dynamic> ;
            // String data = map['data'] as String;
            return MainPage(
              data: "data11",
            );
          });
    },
    'mainPage': (settings, isContainerPage, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            // Map<String, dynamic> map = settings.arguments as Map<String, dynamic> ;
            // String data = map['data'] as String;
            return MainPage(
              data: "data12",
            );
          });
    },
    'simplePage': (settings, isContainerPage, uniqueId) {
      return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            Map<String, dynamic> map = settings.arguments as Map<String, dynamic>;
            // String data = map['data'] as String;
            return SimplePage(
              data: null,
            );
          });
    },
  };

  Route<dynamic>? routeFactory(RouteSettings settings, bool isContainerPage, String? uniqueId) {
    FlutterBoostRouteFactory func = routerMap[settings.name] as FlutterBoostRouteFactory;
    // return func(settings, uniqueId);
    return func(settings, isContainerPage, uniqueId);
  }

  Route<dynamic>? routeFactory2(RouteSettings settings, bool isContainerPage, String? uniqueId) {
    // print(settings.name);
    // print(uniqueId);
    // print(routerMap);
    FlutterBoostRouteFactory? func = routerMap[settings.name];
    // print("routeFactory2");
    if (func == null) {
      print("the fun is null");
      return null;
    }
    print("the fun is not null");
    return func(settings, isContainerPage, uniqueId);
    // return func(settings, uniqueId);
  }

  Widget appBuilder(Widget home) {
    return MaterialApp(
      home: home,
      debugShowCheckedModeBanner: false,

      ///必须加上builder参数，否则showDialog等会出问题
      builder: (_, __) {
        return home;
      },
      // locale: ,
      // localizationsDelegates: ,
      // supportedLocales: ,
      // locale: ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterBoostApp(
      routeFactory2,
      appBuilder: appBuilder,
    );
  }
}

class MainPage extends StatelessWidget {
  final String data;
  // final Map<String, dynamic> data;

  // const MainPage({Object? this.data});
  const MainPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // _setImmersiveStatusBar();
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                // 自定义返回行为
                Navigator.pop(context);
              },
          ),
          // backgroundColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Color(0xFFF5F6FA),
          title: Text('PortInfo',),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
        backgroundColor: Color(0xFFF5F6FA),
      body:
          SafeArea(
            child: Center(
            child:
            Column(
                children: [
                  Text("接收参数:"),
                  Text('$data'),
                  TextButton(onPressed: () {
                    AppNavigator.pushReplacement("simplePage");
                  }, child: Text('Jump')),
                  TextButton(onPressed: () {
                    _setImmersiveStatusBar();
                  }, child: Text('Change')),
                ]
            ),
          ),
          )
    );
  }
}

class SimplePage extends StatefulWidget {
  const SimplePage({super.key, Object? data});

  @override
  State<StatefulWidget> createState() => _MySimplePageState();
}

class _MySimplePageState extends State<SimplePage> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              // 自定义返回行为
              Navigator.pop(context);
            },
          ),
          // backgroundColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Color(0xFFF5F6FA),
          title: Text('Port Settings',),
        ),
        backgroundColor: Color(0xFFF5F6FA),
        body:  SafeArea(
          child: Column(children: [
            Text('Switch Widget 3'),
            Switch(
              value: false,
              onChanged: (value) {
              },
              // activeColor: Colors.green, // 开启状态的颜色
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.blue,
              inactiveThumbColor: Colors.grey, // 关闭状态的滑块颜色
              inactiveTrackColor: Colors.grey.shade400, // 关闭状态轨道颜色
            ),
            SwitchListTile(
              title: Text("启用通知1"),
              // subtitle: Text("接收实时更新和推送"),
              value: true,
              onChanged: (value) {
              },
              // activeColor: Colors.blue,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.blue,
              inactiveThumbColor: Colors.grey, // 关闭状态的滑块颜色
              inactiveTrackColor: Colors.grey.shade400, // 关闭状态轨道颜色
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("启用通知2", style: TextStyle(fontSize: 16)),
                      // Text("接收实时更新和推送", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  CustomImageSwitch(value: isOn, onChanged: (value) {
                    setState(() {
                      isOn = value;
                    });
                  }, activeImage: 'assets/images/icon_switch_thumb.png', inactiveImage: 'assets/images/icon_switch_thumb.png'),
                ],
              ),
            ),

          ]),
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
