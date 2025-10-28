import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores de Rive
  StateMachineController? controller;
  SMIBool? isChecking; // Indica si el oso está reaccionando
  SMIBool? isHandsUp; // Indica si el oso tiene las manos arriba
  SMITrigger? trigSuccess; // Trigger de animación de éxito
  SMITrigger? trigFail; // Trigger de animación de fallo
  SMINumber? numLook; // Controla la mirada del oso (0-100)

  // Timer para manejar debounce de animaciones
  Timer? _typingDebounce;

  // Estado de estrellas
  int selectedStars = 0; // Número de estrellas seleccionadas
  bool _submitted = false; // Si el usuario ya envió su calificación

  @override
  void dispose() {
    _typingDebounce?.cancel(); // Cancelar cualquier timer activo
    super.dispose();
  }

  /// Convierte el índice de estrella (1..5) a un valor de mirada (0..100)
  double _starIndexToLookValue(int i) {
    return ((i - 1) * 25).toDouble().clamp(0.0, 100.0);
  }

  /// Dispara la animación según la estrella seleccionada
  void _triggerReaction(int stars) {
    // CANCELAR INMEDIATAMENTE cualquier animación anterior
    _typingDebounce?.cancel();

    // Actualizar la estrella seleccionada
    setState(() {
      selectedStars = stars;
    });

    // REINICIAR INMEDIATAMENTE el estado de animación
    isChecking?.change(false);
    isHandsUp?.change(false);

    // Pequeña pausa para asegurar que Rive procese el reset
    Timer(const Duration(milliseconds: 16), () {
      // Actualizar la mirada del oso
      numLook?.value = _starIndexToLookValue(stars);

      // Activar la animación de reacción
      isChecking?.change(true);

      // Disparar el trigger correspondiente
      if (stars <= 3) {
        trigFail?.fire();
      } else {
        trigSuccess?.fire();
      }

      // Programar el retorno al estado neutral después de un tiempo
      _typingDebounce = Timer(const Duration(milliseconds: 800), () {
        isChecking?.change(false);
      });
    });
  }

  /// Construye la fila de 5 estrellas
  Widget _buildStars() {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(
        GestureDetector(
          onTap: () {
            if (_submitted) return; // Si ya se envió, no hacer nada
            _triggerReaction(i); // Disparar reacción según la estrella
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Icon(
              i <= selectedStars ? Icons.star : Icons.star_border,
              size: 48,
              color: i <= selectedStars ? Colors.amber : Colors.grey,
            ),
          ),
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }

  /// Botón "Rate Now" que envía la calificación
  void _onRateNowPressed() {
    if (selectedStars == 0) return;

    setState(() {
      _submitted = true;
    });

    // Cancelar cualquier animación en curso
    _typingDebounce?.cancel();

    // Disparar reacción final
    if (selectedStars <= 3) {
      trigFail?.fire();
    } else {
      trigSuccess?.fire();
    }

    // Mantener la animación final por más tiempo
    _typingDebounce = Timer(const Duration(milliseconds: 1500), () {
      isChecking?.change(false);
    });

    // Mostrar un SnackBar con feedback
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedStars <= 3
              ? 'Gracias por tu feedback — lo sentimos, lo mejoraremos.'
              : '¡Gracias! Nos alegra que te haya gustado.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Botón "No Thanks" para cerrar la pantalla
  void _onNoThanksPressed() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación Rive del oso
              SizedBox(
                width: size.width,
                height: 300,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ['Login Machine'],
                  onInit: (artboard) {
                    // Inicializar el controlador de la máquina de estados
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);

                    // Obtener referencias a los inputs de la máquina
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    numLook = controller!.findSMI('numLook');

                    // Valores iniciales
                    isChecking?.change(false);
                    isHandsUp?.change(false);
                    numLook?.value = 50.0; // mirar al frente
                  },
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Enjoying Sounter?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "With how many stars do you rate your experience.\nTap a star to rate!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 18),

              // Fila de estrellas
              _buildStars(),
              const SizedBox(height: 24),

              // Botón Rate Now
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (selectedStars == 0 || _submitted)
                          ? null
                          : _onRateNowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _submitted
                          ? const Text(
                            'Rated',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                          : const Text(
                            'Rate now',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón No Thanks
              TextButton(
                onPressed: _onNoThanksPressed,
                child: const Text(
                  'NO THANKS',
                  style: TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
