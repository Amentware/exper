import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Exper/widgets/colors.dart';

class dummy extends StatefulWidget {
  const dummy({super.key});

  @override
  State<dummy> createState() => _dummyState();
}

class _dummyState extends State<dummy> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _username = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _username.dispose();
  }

  void inputfunction() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // set loading to true

    try {
      for (int i = 1; i < 290; i++) {
        await firestore.collection('dailyupdate').doc(i.toString()).set({
          'meg': "Your are at Day:$i",
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backgrounds/Android Large - 2.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _username,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'week',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.account_circle_outlined,
                    color: orangeColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'length',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: orangeColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'weight',
                  fillColor: const Color.fromARGB(255, 248, 248, 248),
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: orangeColor,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(15),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),

                            /*gradient: LinearGradient(
                              colors: [
                                Color(0xff003E87),
                                Color(0xFF0075FF),
                                
                              ],
                              stops: [
                                0.0,
                                1.0
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              tileMode: TileMode.repeated),*/
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: orangeColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: orangeColor,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        splashColor: const Color.fromARGB(255, 225, 52, 0),
                        borderRadius: BorderRadius.circular(50),
                        onTap: inputfunction,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(15),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                          child: Text('input'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
