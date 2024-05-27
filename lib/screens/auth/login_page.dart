part of 'login_or_register.dart';

class LoginPage extends StatefulWidget {
  final Function() registerOnTap;
  const LoginPage({super.key, required this.registerOnTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCtrl = TextEditingController();

  TextEditingController passCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TapGestureRecognizer _tapGestureRecognizer;
  @override
  void initState() {
    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = widget.registerOnTap;
    super.initState();
  }

  void login() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator.adaptive(),
            ));
    bool validate = true;
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      if (kDebugMode) {
        print("email/pass empty");
      }
      validate = false;
      Navigator.of(context).pop();
    }
    if (validate == true) {
      try {
        await Auth.login(context, emailCtrl.text, passCtrl.text).then((value) {
          log("UUUUU: $value");
          Navigator.of(context).pop();
        });
      } on FirebaseAuthException catch (e) {
        log("YOO ! ${e.toString()}");
        if (mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text("Login Error"),
              content: Text(e.message ?? ""),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok"),
                )
              ],
            ),
          );
        }
      }
    } else if (validate == false) {
      log("HEY");
    } else {
      log("NO");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    // const SplashIcon(rotate: false),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Welcome back !",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    LoginField(
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      textEditingController: emailCtrl,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    LoginField(
                      hintText: "Password",
                      textEditingController: passCtrl,
                      obsucreText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    LoginButton(
                      onTap: () {
                        login.call();
                      },
                      label: "Login",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: "Don't have an account ? ",
                        ),
                        TextSpan(
                          text: " Register",
                          recognizer: _tapGestureRecognizer,
                          style: const TextStyle(
                            color: Colors.amber,
                          ),
                        ),
                      ]),
                    )
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
