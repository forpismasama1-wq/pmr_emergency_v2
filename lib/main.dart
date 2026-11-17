
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://ohrjcryavbljkpjqcbxc.supabase.co/rest/v1/';
const supabaseAnonKey = 'sb_publishable_06FNKGYFiebdBkoVySmrPQ_mQ-CyMll';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const PmrEmergencyApp());
}

final supabase = Supabase.instance.client;

class PmrEmergencyApp extends StatelessWidget {
  const PmrEmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMR EMERGENCY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;
  bool loading = false;
  bool hidePassword = true;

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan email dan password minimal 6 karakter.'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (isRegister) {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.health_and_safety,
                color: Colors.red,
                size: 85,
              ),
              const SizedBox(height: 12),
              const Text(
                'PMR EMERGENCY',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const Text('Satu Tekanan, Seluruh Anggota Siaga.'),
              const SizedBox(height: 35),
              Text(
                isRegister ? 'Buat Akun Baru' : 'Selamat Datang',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isRegister ? 'DAFTAR' : 'MASUK'),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => isRegister = !isRegister);
                },
                child: Text(
                  isRegister
                      ? 'Sudah punya akun? Masuk'
                      : 'Belum punya akun? Daftar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('PMR EMERGENCY'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, color: Colors.green, size: 75),
            const SizedBox(height: 15),
            const Text(
              'Login Berhasil!',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(email),
            const SizedBox(height: 20),
            const Text('Selamat datang di PMR EMERGENCY.'),
          ],
        ),
      ),
    );
  }
}
