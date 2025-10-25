import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMINumber? numLook;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  Timer? _typingDebounce;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String? emailError;
  String? passError;
  bool _isLoading = false;

  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  Future<void> _onLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError =
        isValidPassword(pass)
            ? null
            : 'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial';

    // Mostrar errores independientemente
    setState(() {
      emailError = eError;
      passError = pError;
    });

    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();

    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0;

    await Future.delayed(Duration.zero);

    if (emailError == null && passError == null) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (isHandsUp == null || isChecking == null) return;

    if (!_emailFocus.hasFocus && !_passwordFocus.hasFocus) {
      // Sin foco en ningún campo
      isChecking!.change(false);
      isHandsUp!.change(false);
      numLook?.value = 50.0;
    } else if (_emailFocus.hasFocus) {
      // Foco en email
      isChecking!.change(true);
      isHandsUp!.change(false);
    } else if (_passwordFocus.hasFocus) {
      // Foco en contraseña → siempre tapar ojos
      isChecking!.change(false);
      isHandsUp!.change(true);
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);

                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    numLook = controller!.findSMI('numLook');
                  },
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                focusNode: _emailFocus,
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: emailError,
                  hintText: 'Introduce tu email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (isHandsUp != null) isHandsUp!.change(false);
                  if (isChecking != null) isChecking!.change(true);
                  final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  numLook?.value = look;

                  _typingDebounce?.cancel();
                  _typingDebounce = Timer(
                    const Duration(milliseconds: 3000),
                    () {
                      if (!mounted) return;
                      isChecking?.change(false);
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                focusNode: _passwordFocus,
                controller: passCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  errorText: passError,
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                      _onFocusChange();
                    },
                  ),
                ),
                onChanged: (value) => _onFocusChange(),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 33, 198),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? '),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¡Regístrate aquí!',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
