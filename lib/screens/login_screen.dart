import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
// 3.1 Importar librería para Timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Estado para ocultar/mostrar la contraseña
  bool _obscurePassword = true;

  // Controladores (cerebro) de la animación
  StateMachineController? controller;
  // SMI: State Machine Input
  SMIBool? isChecking; // Activa el modo "Chismoso"
  SMIBool? isHandsUp; // Se tapa los ojos
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone sad

  // 2.1 Variable para recorrido de la mirada
  SMINumber? numLook; // 0.80 en tu asset

  // 1) FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // 3.2 Timer para detener la mirada al dejar de teclear
  Timer? _typingDebounce;

  // 4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(r'^(?=.[a-z])(?=.[A-Z])(?=.\d)(?=.[^A-Za-z0-9]).{8,}$');
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores

    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError =
        isValidPassword(pass)
            ? null
            : 'Mínimo 8 carácteres, 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial';

    // Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }
  }

  // 2) Listeners (0yentes/Chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (isHandsUp == null || isChecking == null) return;

    if (!_emailFocus.hasFocus && !_passwordFocus.hasFocus) {
      // Ningún campo seleccionado
      isChecking!.change(false);
      isHandsUp!.change(false);
      // 2.2 Mirada neutral al enfocar email
      numLook?.value = 50.0;
    } else if (_emailFocus.hasFocus) {
      // Email seleccionado
      isChecking!.change(true);
      isHandsUp!.change(false);
    } else if (_passwordFocus.hasFocus) {
      // Password seleccionado
      if (_obscurePassword) {
        isChecking!.change(true);
        isHandsUp!.change(false);
      } else {
        isChecking!.change(false);
        isHandsUp!.change(true);
      }
    }
  }

  // 4) Liberación de recursos / limpieza de
  @override
  void dispose() {
    // 4.11 Limpieza de los controllers
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
              // Animación Rive
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
                    // 2.3 Enlazar variable con la animación
                    numLook = controller!.findSMI('numLook');
                  }, // clamp: función que limita un número dentro de un rango definido,
                  // devolviendo el valor original si está dentro de los límites,
                  // el límite inferior si es menor o el límite superior si es mayor.
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 10),

              // Email
              TextField(
                focusNode: _emailFocus,

                // 4.8.1 Enlazar controller al TextField
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  // 4.9.1 Mostrar el texto de error
                  errorText: emailError,
                  hintText: 'Introduce tu email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (isHandsUp != null) isHandsUp!.change(false);

                  // 2.4 Implementación numLook
                  if (isChecking != null) isChecking!.change(true);

                  // Ajuste de límite de 0 a 100
                  // 80 es una medida de calibración
                  final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  numLook?.value = look;

                  // 3.3 Debounce: si vuelve a teclear, reinicia el contador
                  _typingDebounce
                      ?.cancel(); // Cancela cualquier timer existente
                  _typingDebounce = Timer(
                    const Duration(milliseconds: 3000),
                    () {
                      if (!mounted) {
                        return; // Si la pantalla se cierra
                      }
                      // Mirada neutra
                      isChecking?.change(false);
                    },
                  );
                },
              ),

              const SizedBox(height: 10),

              // Contraseña
              TextField(
                focusNode: _passwordFocus,
                // 4.8.2 Enlazar el controller al TextField
                controller: passCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  // 4.9.2 Mostrar el texto de error
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
                      _onFocusChange(); // actualizar animación
                    },
                  ),
                ),
                onChanged: (value) {
                  _onFocusChange(); // actualizar animación según visibilidad
                },
              ),

              const SizedBox(height: 10),

              // Olvidaste contraseña
              SizedBox(
                width: size.width,
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),

              const SizedBox(height: 20),

              // Botón Login
              MaterialButton(
                onPressed: _onLogin,
                color: const Color.fromARGB(255, 243, 33, 198),
                minWidth: size.width,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              const SizedBox(height: 10),

              // Registro
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
