import 'package:chat_app/core/constant/app_globals.dart';
import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/core/mixins/validator.dart';
import 'package:chat_app/model/user_data_model.dart';
import 'package:chat_app/view_model/user_data_view_model.dart';
import 'package:chat_app/view/essential_view/home/home_screen.dart';
import 'package:chat_app/view/initial_view.dart/login_screen.dart';
import 'package:chat_app/widgets/input/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatelessWidget with ValidatorMixin {
  SignUpScreen({super.key});
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? passWord;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userCollection');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDataServices>(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.14,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 15, bottom: 5),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Wellcome',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                            nameController: nameController,
                            lable: 'Name',
                            hintText: 'Harry',
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Your Name';
                              } else {
                                return null;
                              }
                            }),
                        CustomTextField(
                            nameController: emailController,
                            lable: 'Email',
                            hintText: 'abc@gmail.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.contains('@')) {
                                return 'please enter valid email';
                              } else {
                                return null;
                              }
                            }),
                        CustomTextField(
                            nameController: passwordController,
                            lable: 'Password',
                            hintText: '********',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 8) {
                                return 'At least 8 characters required';
                              } else {
                                return null;
                              }
                            }),
                        MaterialButton(
                          height: 55,
                          minWidth: double.infinity,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          //ON PRESSED.......
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              email = emailController.text;
                              passWord = passwordController.text;
                              name = nameController.text;
                              prefs.setString('name', name!);
                              prefs.setString('email', email!);
                              prefs.setString('passWord', passWord!);

                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text)
                                  .then((value) {
                                provider.storeAccountData(context,
                                    name: name,
                                    email: email,
                                    passWord: passWord);
                              });
                              nameController.clear();
                              emailController.clear();
                              passwordController.clear();
                              currentUserName = name!;
                              Navigator.pushReplacementNamed(
                                  context, RouteNames.homeScreen);
                            }
                          },
                          color: Colors.purple,
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            const Text('Already have an account?  '),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, RouteNames.logInScreen);
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.purple,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
