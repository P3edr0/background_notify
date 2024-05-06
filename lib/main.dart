import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:background_notify/controllers/home_controller.dart';
import 'package:background_notify/entities/form_entity.dart';
import 'package:background_notify/widgets/textform_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:notifications/notifications.dart';

GetIt getIt = GetIt.instance;

Future<void> main() async {
  getIt.registerLazySingleton<HomeController>(() => HomeController());

  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        initialNotificationContent: 'Monitorando...',
        isForegroundMode: true,
        foregroundServiceNotificationId: 2,
        initialNotificationTitle: "Funcionando em Back"),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

Future<void> postNofify(
    {required String title, required String message}) async {
  // Parâmetros da requisição

  HomeController controller = GetIt.instance<HomeController>();

  FormEntity formEntity = await controller.startForm();

  Map<String, String> parametros = {
    'email': formEntity.email,
    'senha': formEntity.password,
    'celular': formEntity.phone,
    'title': title,
    'message': message,
    'KT_Insert1': '1',
  };
  String queryString = parametros.entries
      .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');

  log(queryString, name: 'Parametros');
  String url =
      'https://www.mysoft.net.br/comprasonline/php/holanda/insert_notifications.php?$queryString';
  http.Response resposta = await http.post(
    Uri.parse(url),
    body: parametros,
  );

  log('Status = ${resposta.statusCode} body = ${resposta.body}');
}

void onData(NotificationEvent event) async {
  log(event.packageName!, name: "Pack Name");
  if (event.packageName != "com.example.background_notify") {
    try {
      postNofify(title: event.title!, message: event.message!)
          .then((value) => FlutterLocalNotificationsPlugin().show(
                1,
                'News',
                'Notificação enviada',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    '',
                    'MY FOREGROUND SERVICE',
                    icon: 'ic_bg_service_small',
                    ongoing: false,
                    number: 3,
                  ),
                ),
              ));
    } catch (e) {
      postNofify(title: event.title!, message: event.message!)
          .then((value) => FlutterLocalNotificationsPlugin().show(
                1,
                'Falha',
                'Não foi possível enviar a notificação',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    '',
                    'MY FOREGROUND SERVICE',
                    icon: 'ic_bg_service_small',
                    ongoing: false,
                    number: 3,
                  ),
                ),
              ));
    }
  }
}

Future<void> onStart(ServiceInstance service) async {
  // HomeController controller = GetIt.instance<HomeController>();
  getIt.registerLazySingleton<HomeController>(() => HomeController());

  HomeController controller = GetIt.instance<HomeController>();

  controller.notifications = Notifications();

  try {
    FormEntity temFormEntity = await controller.startForm();
    if ((temFormEntity.email) != "") {
      controller.isMonitoring = false;
      FlutterLocalNotificationsPlugin().show(
        1,
        'Start',
        'Monitorando notificações.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            '',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: false,
            number: 3,
          ),
        ),
      );

      controller.notify = Notifications().notificationStream!.listen(onData);
    } else {
      controller.isMonitoring = true;

      FlutterLocalNotificationsPlugin().show(
        1,
        'Dados Vazios',
        'Preencha os dados para monitorar as notificações.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            '',
            'MY FOREGROUND SERVICE',
            icon: 'ic_bg_service_small',
            ongoing: false,
            number: 3,
          ),
        ),
      );
    }
  } catch (exception) {
    log(exception.toString());
    onStart(service);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HomeController controller = GetIt.instance<HomeController>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  MaskTextInputFormatter phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  @override
  void initState() {
    startControllers();

    super.initState();
  }

  Future<void> startControllers() async {
    FormEntity tempForm = await controller.startForm();
    controller.emailController.text = tempForm.email;
    controller.passwordController.text = tempForm.password;
    controller.phoneController.text = tempForm.phone;
    if (tempForm.email.isEmpty) {
      controller.isMonitoring = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue[200]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Version: 1.1.0.'),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      height: 400,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Icon(
                            Icons.notifications_active_rounded,
                            color: controller.isMonitoring
                                ? Colors.green[700]!
                                : Colors.red[700]!,
                            size: 45,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormWidget(
                            title: "Email",
                            controller: controller.emailController,
                            isPassword: controller.isPassword,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextFormWidget(
                            title: "Telefone",
                            controller: controller.phoneController,
                            isPassword: controller.isPassword,
                            keyboardType: TextInputType.phone,
                            mask: phoneMask,
                          ),
                          TextFormWidget(
                            title: "Senha",
                            controller: controller.passwordController,
                            isPassword: controller.isPassword,
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    controller.isPassword =
                                        !controller.isPassword;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      controller.isPassword
                                          ? Icons.remove_red_eye_rounded
                                          : Icons.close,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text('SHOW'),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Colors.green[700]!)),
                                onPressed: () async {
                                  FormEntity formData = FormEntity();
                                  formData.email =
                                      controller.emailController.text;
                                  formData.password =
                                      controller.passwordController.text;
                                  formData.phone =
                                      controller.phoneController.text;

                                  String result =
                                      await controller.saveForm(formData);
                                  if (result !=
                                      "Dados Inseridos com Sucesso!") {
                                    controller.isMonitoring = false;

                                    if (!context.mounted) return;
                                    _messangerKey.currentState!
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                      result,
                                      textAlign: TextAlign.center,
                                    )));
                                  } else {
                                    controller.notify = Notifications()
                                        .notificationStream!
                                        .listen(onData);
                                    FlutterLocalNotificationsPlugin().show(
                                      1,
                                      'Start',
                                      'Monitorando notificações.',
                                      const NotificationDetails(
                                        android: AndroidNotificationDetails(
                                          '',
                                          'MY FOREGROUND SERVICE',
                                          icon: 'ic_bg_service_small',
                                          ongoing: false,
                                          number: 3,
                                        ),
                                      ),
                                    );
                                    setState(() {
                                      controller.isMonitoring = true;
                                    });
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.save,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text('SAVE'),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CircularProgressIndicator(
                      strokeWidth: 5,
                      color: controller.isMonitoring
                          ? Colors.green[700]!
                          : Colors.red[700]!,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            controller.isMonitoring
                                ? Colors.green[700]!
                                : Colors.red[700]!),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      onPressed: () {},
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        width: 270,
                        child: controller.isMonitoring
                            ? const Text('Monitorando')
                            : const Text("Pausado"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
