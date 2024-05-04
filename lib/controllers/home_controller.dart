import "dart:developer";

import 'package:background_notify/entities/form_entity.dart';
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class HomeController {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPassword = true;
  bool isMonitoring = true;

  Future<String> saveForm(FormEntity formData) async {
    if (validFields(formData) == 'validado') {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        await prefs.setString('email', formData.email);
        await prefs.setString('phone', formData.phone);
        await prefs.setString('password', formData.password);

        return "Dados Inseridos com Sucesso!";
      } catch (e) {
        log(e.toString(), name: 'Insert Error');
      }
    } else {
      return validFields(formData);
    }

    return '';
  }

  Future<String> fetchForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    FormEntity formEntity = FormEntity();
    try {
      formEntity.email = prefs.getString('email') ?? '';
      formEntity.phone = prefs.getString('phone') ?? '';
      formEntity.password = prefs.getString('password') ?? '';
      if (validFields(formEntity) == "validado") {
        return "Dados Recuperados";
      } else {
        return "Dados Incompletos";
      }
    } catch (e) {
      log(e.toString(), name: 'Get Error');
      return "Falha ao buscar dados";
    }
  }

  Future<FormEntity> startForm() async {
    FormEntity formEntity = FormEntity();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      formEntity.email = prefs.getString('email') ?? '';
      formEntity.phone = prefs.getString('phone') ?? '';
      formEntity.password = prefs.getString('password') ?? '';
      if (validFields(formEntity) == "validado") {
        return formEntity;
      } else {
        return FormEntity();
      }
    } catch (e) {
      log(e.toString(), name: 'Get Error');
      return FormEntity();
    }
  }

  String validFields(FormEntity formData) {
    if (formData.email == '' ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(formData.email)) {
      return 'Insira um email válido.';
    } else if (formData.phone == '') {
      return 'Insira um telefone válido.';
    } else if (formData.password == '') {
      return 'Insira uma senha válida.';
    } else {
      return 'validado';
    }
  }
}
