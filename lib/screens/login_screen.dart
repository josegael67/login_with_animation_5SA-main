import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;

  //Cerebro de la lógica de las animaciones
  StateMachineController? controller;
  //SMI: State Machine Input
  SMIBool? isChecking; //Activa el modo chismoso
  SMIBool? isHandsUp; //Se tapa los ojos
  SMITrigger? trigSuccess; //Se emociona
  SMITrigger? trigFail; //Se pone triste

  @override
  Widget build(BuildContext context) {
    //Obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      //Evita el notch o la cámara frontal
      body: SafeArea(
        child: Padding(
          //Espaciado
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  //Al iniciarse
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    //Verificar que inició bien
                    if (controller == null) return;
                    artboard.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                  },
                ),
              ),
              //Espacio entre el oso y el texto email
              const SizedBox(height: 10),
              //Campo de texto del email
              TextField(
                onChanged: (value) {
                  if (isHandsUp != null) {
                    //Reafirma no taparse los ojos al escribir el email
                    isHandsUp!.change(false);
                  }
                  if (isChecking == null) return;
                  //Activa el modo
                  isChecking!.change(true);
                },
                //Para que aparezca el @ en Móviles UI/UX
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.mail),
                  border: OutlineInputBorder(
                    //esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                onChanged: (value) {
                  if (isChecking != null) {
                    //Reafirma no taparse los ojos al escribir el email
                    isChecking!.change(false);
                  }
                  if (isHandsUp == null) return;
                  //Activa el modo
                  isHandsUp!.change(true);
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
              //Texto Olvidé la contraseña como botón
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
              //Botón de Login
              const SizedBox(height: 10),
              //Botón estilo Android
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {},
                child: Text('Login', style: TextStyle(color: Colors.white)),
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
                          //Negritas
                          fontWeight: FontWeight.bold,
                          //Subrayado
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
