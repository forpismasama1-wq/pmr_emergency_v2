
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://ohrjcryavbljkpjqcbxc.supabase.co';
const supabaseAnonKey = 'sb_publishable_06FNKGYFiebdBkoVySmrPQ_mQ-CyMll';

const maroon = Color(0xFF801D2B);
const red = Color(0xFFB52235);
const brown = Color(0xFF603A2C);
const cream = Color(0xFFFFF7EB);

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: maroon),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// BATIK BACKGROUND

class BatikBackground extends StatelessWidget {
  const BatikBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: BatikPainter(),
      ),
    );
  }
}

class BatikPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const colors = [
      Color(0x66801D2B),
      Color(0x55603A2C),
      Color(0x44B52235),
    ];

    for (int i = 0; i < 45; i++) {
      final x = (i % 6) * 85.0 - 25;
      final y = (i ~/ 6) * 105.0 - 20;

      paint.color = colors[i % colors.length];

      final path = Path()
        ..moveTo(x, y - 20)
        ..lineTo(x + 20, y)
        ..lineTo(x, y + 20)
        ..lineTo(x - 20, y)
        ..close();

      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(x, y), 7, paint);
      canvas.drawCircle(Offset(x, y), 28, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// LOGO SEMENTARA

class BrandLogo extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const BrandLogo({
    super.key,
    required this.text,
    required this.icon,
    this.color = maroon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            color: brown,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// LOGIN

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

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil. Silakan masuk jika diminta verifikasi email.'),
          ),
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF701827), Color(0xFFB65D3E), Color(0xFF4C2B25)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const BatikBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        BrandLogo(
                          text: 'PMI',
                          icon: Icons.health_and_safety,
                        ),
                        SizedBox(width: 28),
                        BrandLogo(
                          text: 'FORPIS MASAMA',
                          icon: Icons.groups,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'PMR EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'SATU TEKANAN, SELURUH ANGGOTA SIAGA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: cream.withOpacity(0.96),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white70),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isRegister ? 'BUAT AKUN' : 'SELAMAT DATANG',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: maroon,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            isRegister
                                ? 'Daftarkan akun anggota kamu'
                                : 'Masuk untuk melanjutkan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: brown),
                          ),
                          const SizedBox(height: 25),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => hidePassword = !hidePassword);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          SizedBox(
                            height: 53,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: loading ? null : submit,
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isRegister ? 'DAFTAR SEKARANG' : 'MASUK',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setState(() => isRegister = !isRegister);
                            },
                            child: Text(
                              isRegister
                                  ? 'Sudah punya akun? Masuk'
                                  : 'Belum punya akun? Daftar',
                              style: const TextStyle(color: maroon),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SIAGA • PEDULI • TANGGAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// DASHBOARD

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    DashboardPage(),
    GroupsPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF4DDE0),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: maroon),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: maroon),
            label: 'Grup',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history, color: maroon),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: maroon),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void showSosInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: const Icon(Icons.warning_rounded, color: red, size: 45),
        title: const Text('Fitur DARURAT'),
        content: const Text(
          'Tampilan tombol darurat sudah tersedia. '
          'Pengiriman SOS, GPS, dan notifikasi anggota masih perlu diaktifkan '
          'dan diuji sebelum digunakan dalam keadaan darurat.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('MENGERTI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? 'Anggota PMR';

    return Scaffold(
      backgroundColor: cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: maroon,
            title: const Text(
              'PMR EMERGENCY',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi belum diaktifkan.'),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [maroon, red, brown],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const BatikBackground(),
                  const Positioned(
                    left: 22,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELAMAT DATANG',
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Relawan Siaga!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          'Bersama kita peduli dan tanggap.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: brown.withOpacity(0.08),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFFF5E2E3),
                          child: Icon(
                            Icons.person,
                            color: maroon,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Akun Anggota',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: brown,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_user, color: Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'PUSAT DARURAT',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB52235), Color(0xFF791626)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: red.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BUTUH BANTUAN?',
                          style: TextStyle(
                            color: Colors.white70,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () => showSosInfo(context),
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 135,
                            height: 135,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFC5C9),
                                width: 7,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sos,
                                  color: red,
                                  size: 55,
                                ),
                                Text(
                                  'DARURAT',
                                  style: TextStyle(
                                    color: maroon,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'Tekan untuk membuka informasi bantuan',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MENU UTAMA',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      menuCard(
                        context,
                        Icons.groups,
                        'Grup Sekolah',
                        'Kelola komunitas',
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buka menu Grup di navigasi bawah.'),
                          ),
                        ),
                      ),
                      menuCard(
                        context,
                        Icons.map,
                        'Peta Lokasi',
                        'Lokasi kejadian',
                        () => showInfo(context, 'Peta Lokasi'),
                      ),
                      menuCard(
                        context,
                        Icons.medical_services,
                        'Edukasi P3K',
                        'Panduan pertolongan',
                        () => showInfo(context, 'Edukasi P3K'),
                      ),
                      menuCard(
                        context,
                        Icons.notifications_active,
                        'Notifikasi',
                        'Informasi siaga',
                        () => showInfo(context, 'Notifikasi'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E5D8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2CBB6)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: maroon, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIAGA • PEDULI • TANGGAP',
                                style: TextStyle(
                                  color: maroon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Menjadi relawan berarti siap membantu sesama.',
                                style: TextStyle(
                                  color: brown,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget menuCard(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: maroon, size: 29),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}

void showInfo(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Bagian ini sudah disiapkan dalam tampilan aplikasi. '
        'Fungsinya akan disambungkan pada tahap pengembangan berikutnya.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('TUTUP'),
        ),
      ],
    ),
  );
}

// GRUP

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GRUP SEKOLAH'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.groups_rounded, size: 75, color: maroon),
          const SizedBox(height: 15),
          const Text(
            'Komunitas PMR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bergabunglah dengan grup sekolah untuk terhubung dengan anggota PMR lainnya.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () => showInfo(context, 'Buat Grup Sekolah'),
            icon: const Icon(Icons.add),
            label: const Text('BUAT GRUP SEKOLAH'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: maroon,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () => showInfo(context, 'Gabung Grup'),
            icon: const Icon(Icons.login),
            label: const Text('GABUNG DENGAN KODE'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fitur grup dan kode undangan akan disambungkan ke database Supabase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// RIWAYAT

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RIWAYAT DARURAT')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.history, size: 75, color: maroon),
              SizedBox(height: 15),
              Text(
                'Belum Ada Riwayat',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: maroon,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Riwayat laporan akan muncul di sini setelah sistem laporan darurat diaktifkan.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PROFIL

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL ANGGOTA')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFF0DADD),
            child: Icon(Icons.person, color: maroon, size: 55),
          ),
          const SizedBox(height: 15),
          const Text(
            'Anggota PMR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: maroon,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 30),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: maroon),
              title: const Text('Email Akun'),
              subtitle: Text(email),
            ),
          ),
          Card(
            child: const ListTile(
              leading: Icon(Icons.groups, color: maroon),
              title: Text('Grup Sekolah'),
              subtitle: Text('Belum terhubung'),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(15),
            ),
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('KELUAR DARI AKUN'),
          ),
        ],
      ),
    );
  }
}
