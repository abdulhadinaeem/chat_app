import 'package:chat_app/core/constant/route_names.dart';
import 'package:chat_app/core/mixins/validator.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/view_model/messaging_view_model.dart';
import 'package:chat_app/view_model/user_data_view_model.dart';
import 'package:chat_app/widgets/input/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget with ValidatorMixin {
  LoginScreen({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? email;
  String? passWord;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDataServices>(context);
    return Scaffold(
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
                      'Wellcome back!',
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  provider.updateAccountData(
                                      email: email, passWord: passWord);
                                  FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text)
                                      .then((value) {
                                    provider.setStatus('Online');
                                    context.read<AuthState>().user = 1;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  print(e.message.toString());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message.toString()),
                                    ),
                                  );
                                }

                                emailController.clear();
                                passwordController.clear();
                                Navigator.pushReplacementNamed(
                                    context, RouteNames.homeScreen);
                              }
                            },
                            color: Colors.purple,
                            child: const Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              const Text("Don't have an account?  "),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, RouteNames.signUpScreen);
                                },
                                child: const Text(
                                  'SignUp',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
