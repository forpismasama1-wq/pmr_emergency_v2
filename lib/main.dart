
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
      title: 'PMR EMERGENCY V2',
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
      home: const AuthGate(),
    );
  }
}

// LOGIN OTOMATIS

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) return const HomePage();

        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const LoginPage();
      },
    );
  }
}

// MOTIF BATIK

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

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void showInfo(BuildContext context, String title) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: const Text('Bagian ini masih dalam tahap pengembangan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('TUTUP'),
        ),
      ],
    ),
  );
}

// LOGIN DAN DAFTAR

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

  InputDecoration decoration(String label, IconData icon) {
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

  Future<void> submit() async {
    final name = nameController.text.trim();
    final className = classController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (isRegister && (name.isEmpty || className.isEmpty)) {
      showMessage(context, 'Nama dan kelas wajib diisi.');
      return;
    }

    if (email.isEmpty || password.length < 6) {
      showMessage(context, 'Email dan password minimal 6 karakter.');
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

        if (mounted) {
          showMessage(
            context,
            'Pendaftaran berhasil. Verifikasi email jika diminta, lalu masuk.',
          );
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      if (mounted) showMessage(context, e.message);
    } catch (e) {
      if (mounted) showMessage(context, 'Terjadi kesalahan: $e');
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
                    const Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 65,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'PMR EMERGENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'SATU TEKANAN, SELURUH ANGGOTA SIAGA',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(25),
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
                          const SizedBox(height: 20),
                          if (isRegister) ...[
                            TextField(
                              controller: nameController,
                              decoration: decoration(
                                'Nama lengkap',
                                Icons.person,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: classController,
                              decoration: decoration(
                                'Kelas',
                                Icons.school,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: decoration('Email', Icons.email),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            decoration: decoration(
                              'Password',
                              Icons.lock,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroon,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: loading ? null : submit,
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(isRegister ? 'DAFTAR' : 'MASUK'),
                            ),
                          ),
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

// DASHBOARD

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? timer;
  int? countdown;

  void startCountdown() {
    if (countdown != null) return;

    setState(() => countdown = 5);

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (countdown == 1) {
        t.cancel();
        setState(() => countdown = null);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            icon: const Icon(Icons.info_outline, color: red, size: 45),
            title: const Text('SOS Belum Aktif'),
            content: const Text(
              'Hitung mundur selesai, tetapi pengiriman SOS, GPS, '
              'dan notifikasi anggota belum diaktifkan.',
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
      } else {
        setState(() => countdown = countdown! - 1);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
            expandedHeight: 180,
            pinned: true,
            title: const Text('PMR EMERGENCY'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [maroon, red, brown],
                  ),
                ),
                child: const BatikBackground(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF5E2E3),
                        child: Icon(Icons.person, color: maroon),
                      ),
                      title: const Text('Akun Anggota'),
                      subtitle: Text(email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'PUSAT DARURAT',
                    style: TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [red, Color(0xFF791626)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BUTUH BANTUAN?',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: countdown == null ? startCountdown : null,
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
                        const SizedBox(height: 12),
                        if (countdown != null) ...[
                          const Text(
                            'SOS akan dilanjutkan setelah hitung mundur.',
                            style: TextStyle(color: Colors.white),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              timer?.cancel();
                              setState(() => countdown = null);
                            },
                            child: const Text(
                              'BATALKAN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ] else
                          const Text(
                            'Tekan untuk memulai hitung mundur 5 detik.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gunakan tombol DARURAT hanya saat keadaan darurat sebenarnya.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
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
                        Icons.groups,
                        'Grup Sekolah',
                        'Kelola komunitas',
                        () => showMessage(
                          context,
                          'Buka menu Grup di navigasi bawah.',
                        ),
                      ),
                      menuCard(
                        Icons.map,
                        'Peta Lokasi',
                        'Lokasi kejadian',
                        () => showInfo(context, 'Peta Lokasi'),
                      ),
                      menuCard(
                        Icons.medical_services,
                        'Edukasi P3K',
                        'Panduan pertolongan',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FirstAidPage(),
                          ),
                        ),
                      ),
                      menuCard(
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
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: maroon, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'SIAGA • PEDULI • TANGGAP\n'
                            'Menjadi relawan berarti siap membantu sesama.',
                            style: TextStyle(color: brown),
                          ),
                        ),
                      ],
                    ),
                  ),
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

// EDUKASI P3K OFFLINE

class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});

  static const materials = [
    {
      'title': 'Luka dan Perdarahan',
      'icon': Icons.bloodtype,
      'body': '''
1. Pastikan lokasi aman dan gunakan sarung tangan jika tersedia.
2. Tekan luka langsung menggunakan kasa atau kain bersih.
3. Pertahankan tekanan sampai perdarahan terkendali.
4. Jika darah menembus kain, tambahkan kain di atasnya.
5. Jangan mencabut benda yang tertancap pada luka.
6. Segera cari bantuan medis jika perdarahan berat atau korban lemas.
''',
    },
    {
      'title': 'Mimisan',
      'icon': Icons.face,
      'body': '''
1. Dudukkan korban dengan posisi tegak.
2. Condongkan kepala sedikit ke depan.
3. Jepit bagian lunak hidung selama 10–15 menit tanpa dilepas.
4. Minta korban bernapas melalui mulut.
5. Jangan mendongakkan kepala.
6. Jangan memasukkan tisu jauh ke dalam hidung.

Cari bantuan medis jika perdarahan tidak berhenti atau sangat banyak.
''',
    },
    {
      'title': 'Luka Bakar',
      'icon': Icons.local_fire_department,
      'body': '''
1. Jauhkan korban dari sumber panas jika aman.
2. Alirkan air bersih yang sejuk selama 20 menit.
3. Lepaskan perhiasan atau pakaian di sekitar luka jika tidak menempel.
4. Tutup luka secara longgar dengan penutup bersih.
5. Jangan gunakan es, pasta gigi, mentega, atau minyak.
6. Jangan memecahkan lepuhan.

Cari bantuan medis untuk luka luas, dalam, atau mengenai area sensitif.
''',
    },
    {
      'title': 'Pingsan',
      'icon': Icons.air,
      'body': '''
1. Pastikan lingkungan aman.
2. Baringkan korban jika tidak ada dugaan cedera.
3. Periksa respons dan pernapasannya.
4. Jika bernapas normal tetapi belum sadar, posisikan miring jika aman.
5. Jangan memberikan makanan atau minuman kepada orang yang belum sadar.
6. Jika tidak bernapas normal, minta bantuan darurat dan mulai CPR jika mampu.

Cari bantuan segera jika korban tidak cepat sadar atau sulit bernapas.
''',
    },
    {
      'title': 'Keseleo',
      'icon': Icons.healing,
      'body': '''
1. Hentikan aktivitas dan lindungi bagian yang cedera.
2. Istirahatkan bagian tubuh tersebut.
3. Gunakan kompres dingin yang dibungkus kain selama 15–20 menit.
4. Gunakan balutan elastis jika tersedia, jangan terlalu ketat.
5. Tinggikan bagian yang cedera jika memungkinkan.
6. Jangan memijat atau memaksakan bagian yang sakit.

Periksakan jika nyeri berat, bentuk anggota tubuh berubah, atau tidak bisa menapak.
''',
    },
    {
      'title': 'Tersedak',
      'icon': Icons.warning,
      'body': '''
1. Jika korban masih bisa batuk kuat, dorong untuk terus batuk.
2. Jika tidak dapat berbicara, batuk, atau bernapas, minta bantuan darurat.
3. Pada orang dewasa dan anak di atas 1 tahun dengan sumbatan berat, penolong terlatih dapat memberikan 5 tepukan punggung dan 5 dorongan perut secara bergantian.
4. Untuk bayi di bawah 1 tahun, gunakan teknik tepukan punggung dan dorongan dada khusus bayi. Jangan melakukan dorongan perut.
5. Jika korban tidak sadar, hubungi layanan darurat dan mulai CPR sesuai kemampuan.
6. Jangan mengorek mulut secara membabi buta.

Teknik pertolongan tersedak perlu dipelajari melalui pelatihan langsung.
''',
    },
    {
      'title': 'Kejang',
      'icon': Icons.monitor_heart,
      'body': '''
1. Jauhkan benda berbahaya dari sekitar korban.
2. Lindungi kepala dengan benda lembut.
3. Catat berapa lama kejang berlangsung.
4. Jangan menahan gerakan tubuh korban.
5. Jangan memasukkan benda atau jari ke mulut.
6. Setelah kejang berhenti, periksa pernapasan dan posisikan miring jika bernapas normal.

Hubungi bantuan darurat jika kejang lebih dari 5 menit, berulang, pertama kali terjadi, atau korban sulit bernapas.
''',
    },
    {
      'title': 'CPR dan AED',
      'icon': Icons.favorite,
      'body': '''
1. Pastikan tempat aman.
2. Periksa respons korban.
3. Minta orang lain menghubungi layanan darurat dan mengambil AED jika tersedia.
4. Jika korban tidak responsif dan tidak bernapas normal, mulai CPR jika mampu.
5. Untuk orang dewasa, penolong awam yang tidak terlatih dapat melakukan kompresi dada di tengah dada dengan kecepatan 100–120 kali per menit.
6. Gunakan AED segera setelah tersedia dan ikuti instruksi alat.

Pelatihan CPR langsung sangat dianjurkan. Teknik untuk bayi dan anak berbeda dari orang dewasa.
''',
    },
    {
      'title': 'Isi Kotak P3K',
      'icon': Icons.medical_services,
      'body': '''
Perlengkapan yang dapat disiapkan:
• Kasa steril.
• Perban gulung.
• Plester luka.
• Plester perekat medis.
• Sarung tangan sekali pakai.
• Gunting kecil.
• Cairan pembersih luka yang sesuai.
• Masker pelindung CPR.
• Selimut darurat.
• Kantong sampah medis.

Periksa tanggal kedaluwarsa dan kondisi perlengkapan secara berkala.
''',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EDUKASI P3K')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: maroon,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 8),
                Text(
                  'PANDUAN PERTOLONGAN PERTAMA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Materi tersimpan di aplikasi dan dapat dibuka tanpa internet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final item in materials)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Icon(
                  item['icon'] as IconData,
                  color: maroon,
                  size: 30,
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FirstAidDetailPage(
                        title: item['title'] as String,
                        body: item['body'] as String,
                        icon: item['icon'] as IconData,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Catatan: Materi ini merupakan panduan dasar, bukan pengganti pelatihan P3K atau tenaga medis. Dalam keadaan darurat, hubungi layanan darurat setempat.',
            style: TextStyle(
              color: brown,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class FirstAidDetailPage extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const FirstAidDetailPage({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(icon, color: maroon, size: 65),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: maroon,
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// GRUP SEKOLAH

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  bool loading = false;

  Future<void> createGroup() async {
    final nameController = TextEditingController();
    final districtController = TextEditingController();

    final details = await showDialog<List<String>>(
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
              ),
            ),
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

    if (details == null) return;

    if (details[0].length < 3) {
      showMessage(context, 'Nama sekolah minimal 3 karakter.');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.rpc(
        'create_school_group',
        params: {
          'p_name': details[0],
          'p_district': details[1].isEmpty ? null : details[1],
        },
      );

      if (!mounted) return;

      if (result is List && result.isNotEmpty) {
        final row = Map<String, dynamic>.from(result.first as Map);
        final schoolName = row['school_name']?.toString() ?? details[0];
        final inviteCode = row['invite_code']?.toString() ?? '-';

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 45,
            ),
            title: const Text('Grup Berhasil Dibuat'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(schoolName),
                const SizedBox(height: 12),
                const Text('KODE UNDANGAN'),
                SelectableText(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 24,
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('SELESAI'),
              ),
            ],
          ),
        );
      } else {
        showMessage(context, 'Kode undangan tidak terbaca.');
      }
    } catch (e) {
      showMessage(context, 'Gagal membuat grup: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> joinGroup() async {
    final controller = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gabung Grup Sekolah'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Kode undangan',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('GABUNG'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (code == null || code.isEmpty) return;

    setState(() => loading = true);

    try {
      await supabase.rpc(
        'join_school_group',
        params: {'p_invite_code': code},
      );

      if (mounted) {
        showMessage(context, 'Berhasil bergabung dengan grup sekolah!');
      }
    } catch (e) {
      if (mounted) showMessage(context, 'Gagal bergabung: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRUP SEKOLAH')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.groups, size: 75, color: maroon),
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
            'Pembuat grup menjadi admin sekolah. Anggota yang bergabung menggunakan kode menjadi member.',
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
                'Riwayat laporan akan muncul setelah sistem laporan darurat diaktifkan.',
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> profileFuture;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() {
    final userId = supabase.auth.currentUser?.id;

    profileFuture = userId == null
        ? Future.value(null)
        : supabase
            .from('profiles')
            .select('full_name, class_name, phone')
            .eq('user_id', userId)
            .maybeSingle();
  }

  Future<void> editProfile(
    String currentName,
    String currentClass,
  ) async {
    final nameController = TextEditingController(text: currentName);
    final classController = TextEditingController(text: currentClass);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('EDIT PROFIL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama lengkap',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: 'Kelas',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );

    if (result != true) {
      nameController.dispose();
      classController.dispose();
      return;
    }

    final name = nameController.text.trim();
    final className = classController.text.trim();

    nameController.dispose();
    classController.dispose();

    if (name.isEmpty || className.isEmpty) {
      showMessage(context, 'Nama dan kelas wajib diisi.');
      return;
    }

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('profiles').upsert({
        'user_id': userId,
        'full_name': name,
        'class_name': className,
      }, onConflict: 'user_id');

      if (!mounted) return;

      setState(loadProfile);
      showMessage(context, 'Profil berhasil diperbarui!');
    } catch (e) {
      showMessage(context, 'Gagal memperbarui profil: $e');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL ANGGOTA')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: profileFuture,
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
              const SizedBox(height: 25),
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
              const SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: snapshot.connectionState ==
                        ConnectionState.waiting
                    ? null
                    : () => editProfile(
                          name,
                          className == '-' ? '' : className,
                        ),
                icon: const Icon(Icons.edit),
                label: const Text('EDIT PROFIL'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: maroon,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: logout,
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