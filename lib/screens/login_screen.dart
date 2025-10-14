import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; // Para el temporizador

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  // Controladores de animación
  StateMachineController? controller;
  SMIBool? isChecking; // Activa el modo chismoso
  SMIBool? isHandsUp; // Se tapa los ojos
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone triste

  // FocusNodes para los campos
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  // Temporizador para dejar de "chismosear"
  Timer? lookAwayTimer;

  @override
  void initState() {
    super.initState();

    // Listeners para los FocusNodes
    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false);
      }
    });

    passFocus.addListener(() {
      isHandsUp?.change(passFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    // Liberar memoria
    emailFocus.dispose();
    passFocus.dispose();
    lookAwayTimer?.cancel(); // 👈 Cancelar el timer al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                focusNode: emailFocus,
                onChanged: (value) {
                  if (isHandsUp != null) {
                    isHandsUp!.change(false);
                  }
                  if (isChecking == null) return;

                  // Activa modo chismoso
                  isChecking!.change(true);

                  // Reinicia el temporizador
                  lookAwayTimer?.cancel();

                  // Después de 3 segundos sin escribir, deja de chismosear
                  lookAwayTimer = Timer(const Duration(seconds: 3), () {
                    isChecking!.change(false);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                focusNode: passFocus,
                onChanged: (value) {
                  if (isChecking != null) {
                    isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  // Aquí podrías activar la animación de cubrirse los ojos
                  // isHandsUp!.change(true);
                },
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {},
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New here?"),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
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
