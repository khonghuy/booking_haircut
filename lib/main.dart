import 'dart:async';
import 'package:booking_haircut/screens/booking_sreens.dart';
import 'package:booking_haircut/screens/home_screens.dart';
import 'package:booking_haircut/state/state_management.dart';
import 'package:booking_haircut/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case '/home':
            return PageTransition(
                settings: setting,
                child: HomePage(),
                type: PageTransitionType.fade);
            break;
          case '/booking':
            return PageTransition(
                settings: setting,
                child: BookingScreen(),
                type: PageTransitionType.fade);
            break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((firebaseUser) async {
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        //         'Login Success ${FirebaseAuth.instance.currentUser
        //             ?.phoneNumber}')));

        //Start new screen
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        if (e is PlatformException) if (e.code ==
            FirebaseAuthUi.kUserCancelledError)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${e.message}')));
        else
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Unk error')));
      });
    } else {}
  }

  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(child: Scaffold(
      key: scaffoldState,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/my_bg.png'),
                fit: BoxFit.cover)),
        child: Column(mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: FutureBuilder(
                future: checkLoginState(context, false, scaffoldState),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator(),);
                  else {
                    var userState = snapshot.data as LOGIN_STATE;
                    if (userState == LOGIN_STATE.LOGGED) {
                      return Container();
                    } else {
                      return ElevatedButton.icon(
                        onPressed: () => processLogin(context),
                        icon: Icon(Icons.phone, color: Colors.white,),
                        label: Text('LOGIN WITH PHONE', style: TextStyle(
                            color: Colors.white),),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.black)),);
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    ));

  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if (!context.read(forceReload).state) {
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
                FirebaseAuth.instance.currentUser
                    .getIdToken()
                    .then((token) async {
                  print('$token');
                  context.read(userToken).state = token;
                  CollectionReference userRef =
                      FirebaseFirestore.instance.collection('User');
                  DocumentSnapshot snapshotUser = await userRef
                      .doc(FirebaseAuth.instance.currentUser.phoneNumber)
                      .get();
                  context.read(forceReload).state = true;
                  if (snapshotUser.exists) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  } else {
                    var nameController = TextEditingController();
                    var addressController = TextEditingController();
                    Alert(
                        context: context,
                        title: 'UPDATE PROFILES',
                        content: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_circle),
                                  labelText: 'Name'),
                              controller: nameController,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  icon: Icon(Icons.home), labelText: 'Address'),
                              controller: addressController,
                            )
                          ],
                        ),
                        buttons: [
                          DialogButton(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.pop(context)),
                          DialogButton(
                              child: Text('UPDATE'),
                              onPressed: () {
                                //update to server
                                userRef
                                    .doc(FirebaseAuth
                                        .instance.currentUser.phoneNumber)
                                    .set({
                                  'name': nameController.text,
                                  'address': addressController.text
                                }).then((value) async {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              'UPDATE PROFILES SUCCESSFULLY!')));
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (route) => false);
                                  });
                                }).catchError((e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(
                                          SnackBar(content: Text('$e')));
                                });
                              }),
                        ]).show();
                  }
                })
              });
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }
}
