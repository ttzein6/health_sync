part of 'login_or_register.dart';

class RegisterPage extends StatefulWidget {
  final Function() loginOnTap;
  const RegisterPage({super.key, required this.loginOnTap});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  File? pickedImage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TapGestureRecognizer _tapGestureRecognizer;
  final TextEditingController emailCtrl = TextEditingController();

  final TextEditingController passCtrl = TextEditingController();

  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController();
  final TextEditingController heightCtrl = TextEditingController();
  final TextEditingController weightCtrl = TextEditingController();
  @override
  void initState() {
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = widget.loginOnTap;
    _tabController = TabController(length: 2, vsync: this);
    pages = [
      _FillEmailPassPage(
        pageState: this,
        formKey: _formKey,
        tabController: _tabController,
        tapGestureRecognizer: _tapGestureRecognizer,
        emailCtrl: emailCtrl,
        passCtrl: passCtrl,
        confirmPassCtrl: confirmPassCtrl,
      ),
      _FillInfoPage(
        pageState: this,
        formKey: _formKey,
        tabController: _tabController,
        nameCtrl: nameCtrl,
        ageCtrl: ageCtrl,
        genderCtrl: genderCtrl,
        heightCtrl: heightCtrl,
        weightCtrl: weightCtrl,
        register: register,
      ),
    ];
    super.initState();
  }

  List<Widget> pages = [];
  Future<void> register() async {
    NavigatorState navState = Navigator.of(context);
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator.adaptive(),
            ));
    bool validate = true;
    // if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
    //   print("email/pass empty");
    //   validate = false;
    //   Navigator.of(context).pop();
    // } else if (passCtrl.text != confirmPassCtrl.text) {
    //   print("pass not match");
    //   validate = false;
    //   Navigator.of(context).pop();
    // }
    if (pickedImage == null ||
        emailCtrl.text.isEmpty ||
        passCtrl.text.isEmpty ||
        confirmPassCtrl.text.isEmpty ||
        nameCtrl.text.isEmpty ||
        ageCtrl.text.isEmpty ||
        genderCtrl.text.isEmpty ||
        heightCtrl.text.isEmpty ||
        weightCtrl.text.isEmpty) {
      validate = false;
      navState.pop();
    }
    if (validate == true) {
      try {
        await Auth.register(
          context: navState.context,
          email: emailCtrl.text,
          password: passCtrl.text,
          name: nameCtrl.text,
          age: int.parse(ageCtrl.text),
          gender: genderCtrl.text,
          weight: int.parse(weightCtrl.text),
          height: int.parse(heightCtrl.text),
          image: pickedImage!,
        ).then((value) {
          navState.pop();
        });
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          navState.pop();
          showDialog(
            context: navState.context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text("Login Error"),
              content: Text(e.message ?? ""),
              actions: [
                TextButton(
                  onPressed: () {
                    navState.pop();
                  },
                  child: const Text("Ok"),
                )
              ],
            ),
          );
        }
      } catch (e) {
        log("ERROR $e");
        navState.pop();
        showDialog(
          context: navState.context,
          builder: (context) => AlertDialog.adaptive(
            content: const Text("Error occured"),
            actions: [
              TextButton(
                onPressed: () {
                  navState.pop();
                },
                child: const Text("Ok"),
              )
            ],
          ),
        );
      }
      log("YOO !");
    } else if (validate == false) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          content: const Text("Please fill required fields"),
          actions: [
            TextButton(
              onPressed: () {
                navState.pop();
              },
              child: const Text("Ok"),
            )
          ],
        ),
      );
    } else {
      log("NO");
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: pages,
    );
  }
}

class _FillEmailPassPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TapGestureRecognizer tapGestureRecognizer;
  final TabController tabController;
  final TextEditingController emailCtrl;
  final RegisterPageState pageState;
  final TextEditingController passCtrl;

  final TextEditingController confirmPassCtrl;
  const _FillEmailPassPage({
    required this.pageState,
    required this.formKey,
    required this.tabController,
    required this.tapGestureRecognizer,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
  });

  @override
  State<_FillEmailPassPage> createState() => _FillEmailPassPageState();
}

class _FillEmailPassPageState extends State<_FillEmailPassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: widget.formKey,
              autovalidateMode: AutovalidateMode.always,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const AnimateZWidget(
                      animate: false,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/icons/icon.png'),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // const SplashIcon(rotate: false),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "let's create an account for you.",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    LoginField(
                      hintText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      textEditingController: widget.emailCtrl,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    LoginField(
                      hintText: "Password",
                      textEditingController: widget.passCtrl,
                      obsucreText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    LoginField(
                      hintText: "Confirm Password",
                      textEditingController: widget.confirmPassCtrl,
                      obsucreText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    LoginButton(
                      onTap: () {
                        widget.tabController.animateTo(1);
                      },
                      label: "Next",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: "Already have an account ? ",
                        ),
                        TextSpan(
                          text: " Login",
                          recognizer: widget.tapGestureRecognizer,
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

class _FillInfoPage extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TabController tabController;
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController genderCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final Future<void> Function() register;
  final RegisterPageState pageState;
  const _FillInfoPage(
      {required this.formKey,
      required this.pageState,
      required this.tabController,
      required this.nameCtrl,
      required this.ageCtrl,
      required this.genderCtrl,
      required this.heightCtrl,
      required this.register,
      required this.weightCtrl});

  @override
  State<_FillInfoPage> createState() => _FillInfoPageState();
}

class _FillInfoPageState extends State<_FillInfoPage> {
  final ImagePicker picker = ImagePicker();

  selectImage() async {
    var image = await ImageUploadService.selectImage();
    setState(() {
      widget.pageState.setState(() {
        widget.pageState.pickedImage = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: MediaQuery.paddingOf(context).vertical + 10),
          child: Form(
            key: widget.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTap: selectImage,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircleAvatar(
                              backgroundImage:
                                  widget.pageState.pickedImage == null
                                      ? null
                                      : AssetImage(
                                          widget.pageState.pickedImage!.path),
                              child: widget.pageState.pickedImage == null
                                  ? const Icon(
                                      Icons.account_circle_rounded,
                                      size: 100,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              iconSize: 30,
                              style: const ButtonStyle(
                                fixedSize:
                                    MaterialStatePropertyAll(Size.square(20)),
                                padding:
                                    MaterialStatePropertyAll(EdgeInsets.zero),
                              ),
                              onPressed: selectImage,
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  LoginField(
                    hintText: "Full Name",
                    textEditingController: widget.nameCtrl,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  LoginField(
                    hintText: "Age",
                    textEditingController: widget.ageCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  LoginField(
                    hintText: "Gender",
                    textEditingController: widget.genderCtrl,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  LoginField(
                    hintText: "Height",
                    textEditingController: widget.heightCtrl,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  LoginField(
                    hintText: "Weight",
                    textEditingController: widget.weightCtrl,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LoginButton(
                        onTap: () {
                          widget.tabController.animateTo(0);
                        },
                        label: "Previous",
                      ),
                      LoginButton(
                        onTap: () {
                          widget.register.call();
                        },
                        label: "Register",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
