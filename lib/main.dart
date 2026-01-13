import 'package:flutter/material.dart';
import 'package:app/services/auth_gate.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/forgot_password_screen.dart';
import 'package:app/screens/enter_otp_screen.dart';
import 'package:app/screens/user setup flow/get_started_screen.dart';
import 'package:app/screens/user setup flow/personal_info_screen.dart';
import 'package:app/screens/user setup flow/health_metrics.dart';
import 'package:app/screens/user setup flow/emergency_contact.dart';
import 'package:app/screens/user setup flow/medical_info.dart';
import 'package:app/screens/user setup flow/upload_pp.dart';
import 'package:app/screens/dashboard flow/dashboard_screen.dart';
import 'package:app/screens/Profile screen/profile_screen.dart';
import 'package:app/screens/Diagnosis%20screens/diagnosis_dashboard.dart';
import 'package:app/screens/Diagnosis%20screens/add_diagnosis.dart';
import 'package:app/screens/Diagnosis%20screens/diagnosis_Detail.dart';
import 'package:app/screens/meds screen/meds_dashboard.dart';
import 'package:app/screens/meds screen/med_detail.dart';
import 'package:app/screens/meds screen/add_medicine.dart';
import 'package:app/screens/meds screen/med_detailedit.dart';
import 'package:app/screens/meds screen/med_reminders.dart';
import 'package:app/screens/meds screen/alarm_ringing_screen.dart';
import 'package:app/screens/Appointment screens/appointments_dashboard.dart';
import 'package:app/screens/Appointment screens/add_appointment.dart';
import 'package:app/screens/Appointment screens/appointment_detail.dart';
import 'package:app/screens/Appointment screens/appointment_edit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/firebase_options.dart';
import 'package:app/services/notification_service.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  await NotificationService().init();

  // Initialize Alarms
  await Alarm.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void toggleDarkMode(bool value) async {
    setState(() {
      isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
    // Listen for alarms ringing to navigate to the ringing screen
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint('ALARM: Ringing triggered for ID: ${alarmSettings.id}');
      navigatorKey.currentState?.pushNamed(
        '/alarmRinging',
        arguments: alarmSettings,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Global key for background navigation
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ... (omitting theme for brevity as I'm using replace_file_content and need to match carefully)
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF277AFF),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF277AFF),
          selectionColor: Color.fromARGB(136, 39, 122, 255),
          selectionHandleColor: Colors.blue,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF152034), // main background
        primaryColor: const Color(0xFF277AFF),
        canvasColor: const Color(0xFF152034), // Drawer, menus
        cardColor: const Color(0xFF152034),
        // bottomAppBarColor: const Color(0xFF152034),
        //backgroundColor: const Color(0xFF152034),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF277AFF),
          selectionColor: Color.fromARGB(150, 68, 137, 255),
          selectionHandleColor: Colors.blue,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF152034),
          selectedItemColor: Color(0xFF277AFF),
          unselectedItemColor: Colors.white70,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF152034),
          hintStyle: TextStyle(color: Colors.white54),
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF277AFF)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: const TextTheme(
          //bodyText1: TextStyle(color: Colors.white),
          //bodyText2: TextStyle(color: Colors.white70),
          //headline6: TextStyle(color: Colors.white),
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF152034)),
        // cardTheme: const CardTheme(
        //   ),
        // ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(toggleDarkMode: toggleDarkMode),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/Enter-Otp': (context) => const EnterOtpScreen(),
        '/getStarted': (context) => const GetStartedScreen(),
        '/personalinfo': (context) => const PersonalInfoScreen(),
        '/healthmetrics': (context) => const HealthMetricsScreen(),
        '/emergencycontact': (context) => const EmergencyContactScreen(),
        '/medicalinfo': (context) => const MedicalInfoSCreen(),
        '/uploadpp': (context) => const UploadPPScreen(),
        '/dashboard': (context) =>
            DashboardScreen(toggleDarkMode: toggleDarkMode),
        '/profile': (context) => const ProfileScreen(),
        '/diagnosisDashboard': (context) => const DiagnosisDashboard(),
        '/addDiagnosis': (context) => const AddDiagnosis(),
        '/diagnosisDetail': (context) => const DiagnosisDetailScreen(),
        '/medsDashboard': (context) => const MedsDashboard(),
        '/addmedicine': (context) => const AddMedicine(),
        '/medDetail': (context) => const MedDetail(),
        '/medDetailEdit': (context) => const MedDetailEdit(),
        '/medReminders': (context) => const MedReminders(),
        '/alarmRinging': (context) {
          final settings =
              ModalRoute.of(context)!.settings.arguments as AlarmSettings;
          return AlarmRingingScreen(alarmSettings: settings);
        },
        '/appointmentsDashboard': (context) => const AppointmentsDashboard(),
        '/addAppointment': (context) => const AddAppointment(),
        '/appointmentDetail': (context) => const AppointmentDetail(),
        '/appointmentEdit': (context) => const AppointmentEdit(),
      },
    );
  }
}

  // class MyApp extends StatefulWidget{
  //   const MyApp({super.key});

  //   @override
  //   State<MyApp> createState() => _MyAppState();
  // }

  // class _MyAppState extends State<MyApp>{
  //   int num1=0;
  //   int num2=0;
  //   int sum=0;
  //   final textfeldController1=TextEditingController();
  //   final textfeldController2=TextEditingController();
  //   void calculate(){
  //     setState((){
  //       num1=int.tryParse(textfeldController1.text)?? 0;
  //       num2=int.tryParse(textfeldController2.text)?? 0;
  //       sum=num1+num2;
  //     });
  //   }
  //   @override
  //   Widget build(BuildContext context){
  //     return MaterialApp(
  //       home:Scaffold(
  //         appBar:AppBar(title:Text("My First App")),
  //         body: Center(
  //           child: 
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       TextField(
  //                         controller: textfeldController1,
  //                         decoration: InputDecoration(
  //                           border: OutlineInputBorder(),
  //                           labelText: "Enter the first number:",
  //                           hintText: "e.g. 42",
  //                         ),

  //                       ),
  //                       SizedBox(height: 20,),
  //                       TextField(
  //                         controller: textfeldController2,
  //                         decoration: InputDecoration(
  //                           border: OutlineInputBorder(),
  //                           labelText: "Enter the second number:",
  //                           hintText: "e.g. 21",
  //                         ),
  //                       ),
  //                       ElevatedButton(
  //                         onPressed: calculate,
  //                         child:Text("Calculate"),
  //                       ),
  //                       SizedBox(height: 20,),
  //                       Text("The sum is: $sum")
  //                     ],
  //                   ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  /*
  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: HomePage(),
      );
    }
  }

  class HomePage extends StatelessWidget {
    final List<String> friends = [
      "Abel",
      "Daniel",
      "Sara",
      "Miki",
      "Bini",
      "Helen",
      "Sami"
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Friends List")),
        body: ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.person),
              title: Text(friends[index]),
              subtitle: Text("Friend #$index"),
            );
          },
        ),
      );
    }
  }
  */
  /*class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: HomePage(),
      );
    }
  }

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    String msg = "Hello from Home Page";
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Home Page")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Go to Second Page"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondPage(
                        message: "wazzaaaaaaaaaup from home page",
                      ),
                    ),
                  );

                  setState(() {
                    msg = result;
                  });
                },
              ),
              Text(msg),
            ],
          ),
        ),
      );
    }
  }


  class SecondPage extends StatelessWidget {
    final String? message;
    const SecondPage({super.key, required this.message});
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Second Page")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[ 
            ElevatedButton(
            child: Text("Go Back"),
            onPressed: () {
              Navigator.pop(context,"wazzaaaaaaaaaup from second page");
            },
          ),
          Text(message ?? "")
          ],
        ),
      )
      );
    }
  }*/
