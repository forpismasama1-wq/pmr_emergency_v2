
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://ohrjcryavbljkpjqcbxc.supabase.co';
const supabaseAnonKey = 'sb_publishable_06FNKGYFiebdBkoVySmrPQ_mQ-CyMll';

const maroon = Color(0xFF801D2B);
const red = Color(0xFFB52235);
const brown = Color(0xFF603A2C);
const cream = Color(0xFFFFF7EB);

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const PmrEmergencyApp());
}

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

// BACKGROUND BATIK

class BatikBackground extends StatelessWidget {
  const BatikBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: BatikPainter()),
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

// LOGIN DAN PENDAFTARAN

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final classController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegister = false;
  bool loading = false;
  bool hidePassword = true;

  Future<void> submit() async {
    final name = nameController.text.trim();
    final className = classController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (isRegister && (name.isEmpty || className.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap dan kelas wajib diisi.'),
        ),
      );
      return;
    }

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
          data: {
            'full_name': name,
            'class_name': className,
          },
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pendaftaran berhasil. Silakan verifikasi email jika diminta, lalu masuk.',
            ),
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
    nameController.dispose();
    classController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF701827),
                  Color(0xFFB65D3E),
                  Color(0xFF4C2B25),
                ],
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

                          if (isRegister) ...[
                            TextField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: fieldDecoration(
                                'Nama lengkap',
                                Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: classController,
                              decoration: fieldDecoration(
                                'Kelas',
                                Icons.school_outlined,
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],

                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: fieldDecoration(
                              'Email',
                              Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: fieldDecoration(
                              'Password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
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
                                      isRegister
                                          ? 'DAFTAR SEKARANG'
                                          : 'MASUK',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () {
                                    setState(() {
                                      isRegister = !isRegister;
                                    });
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

// NAVIGASI UTAMA

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

// DASHBOARD DAN HITUNG MUNDUR DARURAT

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? sosTimer;
  int? countdown;

  void startCountdown() {
    if (countdown != null) return;

    setState(() => countdown = 5);

    sosTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (countdown == 1) {
        timer.cancel();
        setState(() => countdown = null);
        showSosNotActive();
      } else {
        setState(() => countdown = countdown! - 1);
      }
    });
  }

  void cancelCountdown() {
    sosTimer?.cancel();
    setState(() => countdown = null);
  }

  void showSosNotActive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline, color: red, size: 45),
        title: const Text('SOS Belum Aktif'),
        content: const Text(
          'Hitung mundur selesai, tetapi pengiriman SOS belum diaktifkan. '
          'GPS, laporan darurat, dan notifikasi anggota masih dalam tahap pengembangan.',
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
  void dispose() {
    sosTimer?.cancel();
    super.dispose();
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB52235), Color(0xFF791626)],
                      ),
                      borderRadius: BorderRadius.circular(24),
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
                          onTap: countdown == null ? startCountdown : null,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  countdown == null
                                      ? Icons.sos
                                      : Icons.timer,
                                  color: red,
                                  size: 48,
                                ),
                                Text(
                                  countdown == null
                                      ? 'DARURAT'
                                      : '$countdown',
                                  style: const TextStyle(
                                    color: maroon,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        if (countdown != null) ...[
                          const Text(
                            'SOS akan dilanjutkan setelah hitung mundur.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: cancelCountdown,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('BATALKAN'),
                          ),
                        ] else ...[
                          const Text(
                            'Tekan untuk memulai hitung mundur 5 detik.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'PERINGATAN: Jangan menekan tombol DARURAT sembarangan. Gunakan hanya saat terjadi keadaan darurat yang sebenarnya.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
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
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Buka menu Grup di navigasi bawah.',
                              ),
                            ),
                          );
                        },
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

// KARTU MENU

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
        'Bagian ini masih dalam tahap pengembangan.',
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

// GRUP SEKOLAH

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool loading = false;

  Future<List<String>?> askGroupDetails() async {
    final nameController = TextEditingController();
    final districtController = TextEditingController();

    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buat Grup Sekolah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama sekolah',
                hintText: 'Minimal 3 karakter',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: districtController,
              decoration: const InputDecoration(
                labelText: 'Kecamatan (opsional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, [
                nameController.text.trim(),
                districtController.text.trim(),
              ]);
            },
            child: const Text('BUAT'),
          ),
        ],
      ),
    );

    nameController.dispose();
    districtController.dispose();
    return result;
  }

  Future<String?> askInviteCode() async {
    final codeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gabung Grup Sekolah'),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Kode undangan',
            hintText: 'Masukkan kode dari sekolah',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                codeController.text.trim(),
              );
            },
            child: const Text('GABUNG'),
          ),
        ],
      ),
    );

    codeController.dispose();
    return result;
  }

  Future<void> createGroup() async {
    final details = await askGroupDetails();
    if (details == null) return;

    final name = details[0];
    final district = details[1];

    if (name.length < 3) {
      showMessage('Nama sekolah minimal 3 karakter.');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.rpc(
        'create_school_group',
        params: {
          'p_name': name,
          'p_district': district.isEmpty ? null : district,
        },
      );

      if (!mounted) return;

      if (result is List && result.isNotEmpty) {
        final row = Map<String, dynamic>.from(result.first as Map);
        final schoolName = row['school_name']?.toString() ?? name;
        final inviteCode = row['invite_code']?.toString() ?? '-';

        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 45,
            ),
            title: const Text('Grup Berhasil Dibuat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  schoolName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text('KODE UNDANGAN'),
                const SizedBox(height: 5),
                SelectableText(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: maroon,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bagikan kode ini kepada anggota PMR sekolah kamu.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('SELESAI'),
              ),
            ],
          ),
        );
      } else {
        showMessage('Grup dibuat, tetapi kode undangan tidak terbaca.');
      }
    } catch (e) {
      showMessage('Gagal membuat grup: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> joinGroup() async {
    final code = await askInviteCode();
    if (code == null || code.isEmpty) return;

    setState(() => loading = true);

    try {
      await supabase.rpc(
        'join_school_group',
        params: {'p_invite_code': code},
      );

      showMessage('Berhasil bergabung dengan grup sekolah!');
    } catch (e) {
      showMessage('Gagal bergabung: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRUP SEKOLAH')),
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
            onPressed: loading ? null : createGroup,
            icon: const Icon(Icons.add),
            label: const Text('BUAT GRUP SEKOLAH'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: maroon,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: loading ? null : joinGroup,
            icon: const Icon(Icons.login),
            label: const Text('GABUNG DENGAN KODE'),
          ),
          if (loading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 20),
          const Text(
            'Pembuat grup otomatis menjadi admin sekolah. Anggota yang bergabung menggunakan kode akan menjadi member.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

// PROFIL ANGGOTA

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
    final userId = supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL ANGGOTA')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userId == null
            ? Future.value(null)
            : supabase
                .from('profiles')
                .select('full_name, class_name, phone')
                .eq('user_id', userId)
                .maybeSingle(),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = profile?['full_name']?.toString() ?? 'Anggota PMR';
          final className = profile?['class_name']?.toString() ?? '-';
          final phone = profile?['phone']?.toString() ?? '-';

          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFF0DADD),
                child: Icon(Icons.person, color: maroon, size: 55),
              ),
              const SizedBox(height: 15),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
              if (snapshot.hasError)
                const Text(
                  'Data profil belum dapat dimuat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: red),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: maroon),
                  title: const Text('Nama Lengkap'),
                  subtitle: Text(name),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.school, color: maroon),
                  title: const Text('Kelas'),
                  subtitle: Text(className),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email, color: maroon),
                  title: const Text('Email Akun'),
                  subtitle: Text(email),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone, color: maroon),
                  title: const Text('Nomor Telepon'),
                  subtitle: Text(phone),
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
          );
        },
      ),
    );
  }
}
