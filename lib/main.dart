
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';

const supabaseUrl = 'https://ohrjcryavbljkpjqcbxc.supabase.co';
const supabaseAnonKey = 'sb_publishable_06FNKGYFiebdBkoVySmrPQ_mQ-CyMll';

const maroon = Color(0xFF801D2B);
const red = Color(0xFFB52235);
const brown = Color(0xFF603A2C);
const cream = Color(0xFFFFF7EB);

final supabase = Supabase.instance.client;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const PmrEmergencyApp());
}

class PmrEmergencyApp extends StatelessWidget {
  const PmrEmergencyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? supabase.auth.currentSession;
        if (session != null) return const HomePage();
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const LoginPage();
      },
    );
  }
}

class BatikBackground extends StatelessWidget {
  final Widget? child;

  const BatikBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BatikPainter(),
      child: child ?? const SizedBox.expand(),
    );
  }
}

class BatikPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const colors = [Color(0x66801D2B), Color(0x55603A2C), Color(0x44B52235)];
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// LOGIN DAN REGISTRASI

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
  bool isRegister = false, loading = false, hidePassword = true;

  InputDecoration decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

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
      showMessage(context, 'Email wajib diisi dan password minimal 6 karakter.');
      return;
    }

    setState(() => loading = true);
    try {
      if (isRegister) {
        await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name, 'class_name': className},
        );
        if (mounted) {
          showMessage(context, 'Pendaftaran berhasil. Verifikasi email jika diminta.');
        }
      } else {
        await supabase.auth.signInWithPassword(email: email, password: password);
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
      body: Stack(children: [
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
              child: Column(children: [
                const Icon(Icons.health_and_safety, color: Colors.white, size: 65),
                const SizedBox(height: 12),
                const Text('PMR EMERGENCY',
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const Text('SATU TEKANAN, SELURUH ANGGOTA SIAGA',
                    style: TextStyle(color: Colors.white70, fontSize: 10)),
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
                      Text(isRegister ? 'BUAT AKUN' : 'SELAMAT DATANG',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: maroon, fontSize: 23,
                            fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      if (isRegister) ...[
                        TextField(controller: nameController,
                            decoration: decoration('Nama lengkap', Icons.person)),
                        const SizedBox(height: 12),
                        TextField(controller: classController,
                            decoration: decoration('Kelas', Icons.school)),
                        const SizedBox(height: 12),
                      ],
                      TextField(controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: decoration('Email', Icons.email)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: decoration('Password', Icons.lock).copyWith(
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => hidePassword = !hidePassword),
                            icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: maroon, foregroundColor: Colors.white),
                          onPressed: loading ? null : submit,
                          child: loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(isRegister ? 'DAFTAR' : 'MASUK'),
                        ),
                      ),
                      TextButton(
                        onPressed: loading ? null : () => setState(() => isRegister = !isRegister),
                        child: Text(
                          isRegister ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar',
                          style: const TextStyle(color: maroon),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
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

StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  final pages = const [
    DashboardPage(),
    GroupsPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  late final StreamSubscription<String> tokenRefreshSubscription;

  @override
void initState() {
  super.initState();

  registerDeviceToken();

  tokenRefreshSubscription =
      FirebaseMessaging.instance.onTokenRefresh.listen(
    (token) {
      saveDeviceToken(token);
    },
  );

  _foregroundMessageSubscription =
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (!mounted) return;

    final title = message.notification?.title ??
        message.data['title'] ??
        'Notifikasi PMR';

    final body = message.notification?.body ??
        message.data['body'] ??
        'Ada informasi baru.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title\n$body'),
        duration: const Duration(seconds: 5),
      ),
    );
  });
}
  Future<void> registerDeviceToken() async {
    try {
      final settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus ==
          AuthorizationStatus.denied) {
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await saveDeviceToken(token);
      }
    } catch (e) {
      debugPrint('Gagal mengambil token Firebase: $e');
    }
  }

  Future<void> saveDeviceToken(String token) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      await supabase.from('device_tokens').upsert({
        'user_id': user.id,
        'token': token,
        'platform': 'android',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,token');

      debugPrint('Token notifikasi berhasil disimpan.');
    } catch (e) {
      debugPrint('Gagal menyimpan token: $e');
    }
  }

  @override
void dispose() {
  tokenRefreshSubscription.cancel();
  _foregroundMessageSubscription?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) => Scaffold(
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
      setState(() => countdown = 0);
      _sendSos();
    } else {
      setState(() => countdown = countdown! - 1);
    }
  });
}

Future<void> _sendSos() async {
  try {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage(context, 'Silakan login terlebih dahulu.');
      return;
    }

    final profile = await supabase
        .from('profiles')
        .select('active_school_id')
        .eq('user_id', user.id)
        .maybeSingle();

    final schoolId = profile?['active_school_id'];

    if (schoolId == null) {
      showMessage(context, 'Pilih grup sekolah terlebih dahulu.');
      return;
    }

    Position? position;

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (serviceEnabled) {
        LocationPermission permission =
            await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
        }
      }
    } catch (_) {
      position = null;
    }

    final report = await supabase
        .from('emergency_reports')
        .insert({
          'school_id': schoolId,
          'sender_id': user.id,
          'message': 'Permintaan bantuan darurat',
          'latitude': position?.latitude,
          'longitude': position?.longitude,
        })
        .select('id')
        .single();

    bool notificationSent = true;

    try {
      await sendPmrNotification(
        event: 'report_created',
        body: {'report_id': report['id']},
      );
    } catch (_) {
      notificationSent = false;
    }

    if (!mounted) return;

    showMessage(
      context,
      notificationSent
          ? 'SOS berhasil dikirim!'
          : 'SOS tersimpan, tetapi notifikasi gagal dikirim.',
    );
  } catch (e) {
    if (mounted) {
      showMessage(context, 'Gagal mengirim SOS: $e');
    }
  } finally {
    if (mounted) {
      setState(() => countdown = null);
    }
  }
}

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? 'Anggota PMR';
    return Scaffold(
      backgroundColor: cream,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          title: const Text('PMR EMERGENCY'),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [maroon, red, brown])),
              child: const Stack(children: [BatikBackground()]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF5E2E3),
                  child: Icon(Icons.person, color: maroon)),
                title: const Text('Akun Anggota'),
                subtitle: Text(email),
              )),
              const SizedBox(height: 20),
              const Text('PUSAT DARURAT',
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [red, Color(0xFF791626)]),
                  borderRadius: BorderRadius.circular(24)),
                child: Column(children: [
                  const Text('BUTUH BANTUAN?',
                      style: TextStyle(color: Colors.white, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: countdown == null ? startCountdown : null,
                    child: Container(
                      width: 135, height: 135,
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFC5C9), width: 7)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(countdown == null ? Icons.sos : Icons.timer,
                              color: red, size: 48),
                          Text(countdown == null ? 'DARURAT' : '$countdown',
                            style: const TextStyle(color: maroon,
                                fontWeight: FontWeight.w900, fontSize: 22)),
                        ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (countdown != null) ...[
                    const Text('Hitung mundur sedang berjalan.',
                        style: TextStyle(color: Colors.white)),
                    OutlinedButton(
                      onPressed: () {
                        timer?.cancel();
                        setState(() => countdown = null);
                      },
                      child: const Text('BATALKAN',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ] else
                    const Text('Tekan untuk memulai hitung mundur 5 detik.',
                        style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  const Text(
                    'Gunakan tombol DARURAT hanya saat keadaan darurat sebenarnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 24),
              const Text('MENU UTAMA',
                  style: TextStyle(color: maroon, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.45,
                children: [
                  menuCard(Icons.groups, 'Grup Sekolah', 'Kelola komunitas',
                    () => showMessage(context, 'Buka menu Grup di navigasi bawah.')),
                  menuCard(Icons.map, 'Peta Lokasi', 'Lokasi kejadian',
                    () => showMessage(context, 'Fitur peta belum diaktifkan.')),
                  menuCard(Icons.medical_services, 'Edukasi P3K', 'Panduan pertolongan',
                    () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FirstAidPage()))),
                  menuCard(Icons.notifications_active, 'Notifikasi', 'Informasi siaga',
                    () => showMessage(context, 'Notifikasi belum diaktifkan.')),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E5D8),
                  borderRadius: BorderRadius.circular(18)),
                child: const Row(children: [
                  Icon(Icons.favorite, color: maroon, size: 32),
                  SizedBox(width: 12),
                  Expanded(child: Text(
                    'SIAGA • PEDULI • TANGGAP\nMenjadi relawan berarti siap membantu sesama.',
                    style: TextStyle(color: brown))),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

Widget menuCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDDD5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: maroon, size: 29),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(
            color: maroon, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(
            color: Colors.black54, fontSize: 10)),
        ],
      ),
    ),
  );
}

// EDUKASI P3K OFFLINE

class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});

  static const materials = [
    {'title':'Luka dan Perdarahan','icon':Icons.bloodtype,'body':
      '1. Pastikan lokasi aman.\n2. Tekan luka langsung dengan kasa atau kain bersih.\n3. Pertahankan tekanan sampai perdarahan terkendali.\n4. Jika darah menembus kain, tambahkan kain di atasnya.\n5. Jangan mencabut benda yang tertancap.\n6. Cari bantuan medis untuk perdarahan berat.'},
    {'title':'Mimisan','icon':Icons.face,'body':
      '1. Dudukkan korban dengan posisi tegak.\n2. Condongkan kepala sedikit ke depan.\n3. Jepit bagian lunak hidung selama 10–15 menit.\n4. Bernapas melalui mulut.\n5. Jangan mendongakkan kepala atau memasukkan tisu jauh ke hidung.\nCari bantuan medis jika perdarahan tidak berhenti.'},
    {'title':'Luka Bakar','icon':Icons.local_fire_department,'body':
      '1. Jauhkan korban dari sumber panas jika aman.\n2. Alirkan air bersih yang sejuk selama 20 menit.\n3. Lepaskan perhiasan atau pakaian jika tidak menempel.\n4. Tutup luka secara longgar dengan penutup bersih.\n5. Jangan gunakan es, pasta gigi, mentega, atau minyak.\nCari bantuan medis untuk luka luas atau dalam.'},
    {'title':'Pingsan','icon':Icons.air,'body':
      '1. Pastikan lingkungan aman.\n2. Baringkan korban jika tidak ada dugaan cedera.\n3. Periksa respons dan pernapasan.\n4. Jika belum sadar tetapi bernapas normal, posisikan miring jika aman.\n5. Jangan memberikan makanan atau minuman kepada orang yang belum sadar.\n6. Jika tidak bernapas normal, hubungi layanan darurat dan mulai CPR jika mampu.'},
    {'title':'Keseleo','icon':Icons.healing,'body':
      '1. Hentikan aktivitas dan lindungi bagian yang cedera.\n2. Istirahatkan bagian tersebut.\n3. Gunakan kompres dingin berlapis kain selama 15–20 menit.\n4. Balut jika tersedia, jangan terlalu ketat.\n5. Tinggikan bagian yang cedera jika memungkinkan.\nPeriksakan jika nyeri berat atau bentuk anggota tubuh berubah.'},
    {'title':'Tersedak','icon':Icons.warning,'body':
      '1. Jika korban masih bisa batuk kuat, dorong untuk terus batuk.\n2. Jika tidak dapat berbicara, batuk, atau bernapas, minta bantuan darurat.\n3. Penolong terlatih dapat menggunakan teknik tepukan punggung dan dorongan sesuai usia korban.\n4. Bayi di bawah 1 tahun tidak boleh diberi dorongan perut.\n5. Jika korban tidak sadar, hubungi layanan darurat dan mulai CPR jika mampu.\n6. Jangan mengorek mulut secara membabi buta.'},
    {'title':'Kejang','icon':Icons.monitor_heart,'body':
      '1. Jauhkan benda berbahaya.\n2. Lindungi kepala dengan benda lembut.\n3. Catat lama kejang.\n4. Jangan menahan gerakan tubuh.\n5. Jangan memasukkan benda atau jari ke mulut.\n6. Setelah kejang berhenti, periksa pernapasan.\nHubungi bantuan darurat jika kejang lebih dari 5 menit, berulang, atau korban sulit bernapas.'},
    {'title':'CPR dan AED','icon':Icons.favorite,'body':
      '1. Pastikan tempat aman.\n2. Periksa respons korban.\n3. Minta orang lain menghubungi layanan darurat dan mengambil AED.\n4. Jika korban tidak responsif dan tidak bernapas normal, mulai CPR jika mampu.\n5. Untuk orang dewasa, penolong awam dapat melakukan kompresi dada di tengah dada dengan kecepatan 100–120 kali per menit.\n6. Gunakan AED dan ikuti instruksi alat.\nTeknik untuk bayi dan anak berbeda dari orang dewasa.'},
    {'title':'Isi Kotak P3K','icon':Icons.medical_services,'body':
      'Perlengkapan yang dapat disiapkan:\n• Kasa steril\n• Perban gulung\n• Plester luka\n• Sarung tangan sekali pakai\n• Gunting kecil\n• Masker pelindung CPR\n• Cairan pembersih luka yang sesuai\nPeriksa kondisi dan tanggal kedaluwarsa perlengkapan.'},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('EDUKASI P3K')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: maroon, borderRadius: BorderRadius.circular(18)),
          child: const Column(children: [
            Icon(Icons.medical_services, color: Colors.white, size: 42),
            SizedBox(height: 8),
            Text('PANDUAN PERTOLONGAN PERTAMA',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 17)),
            SizedBox(height: 5),
            Text('Materi tersimpan di aplikasi dan dapat dibuka tanpa internet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 18),
        for (final item in materials)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Icon(item['icon'] as IconData, color: maroon, size: 30),
              title: Text(item['title'] as String,
                style: const TextStyle(color: maroon, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FirstAidDetailPage(
                  title: item['title'] as String,
                  body: item['body'] as String,
                  icon: item['icon'] as IconData,
                ),
              )),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'Materi ini merupakan panduan dasar, bukan pengganti pelatihan P3K atau tenaga medis. Dalam keadaan darurat, hubungi layanan darurat setempat.',
          style: TextStyle(color: brown, fontSize: 12)),
      ],
    ),
  );
}

class FirstAidDetailPage extends StatelessWidget {
  final String title, body;
  final IconData icon;
  const FirstAidDetailPage({
    super.key, required this.title, required this.body, required this.icon,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(icon, color: maroon, size: 65),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center,
          style: const TextStyle(color: maroon,
              fontWeight: FontWeight.bold, fontSize: 23)),
        const SizedBox(height: 20),
        Card(child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(body, style: const TextStyle(fontSize: 15, height: 1.6)),
        )),
      ],
    ),
  );
}


// ===============================
// GRUP SEKOLAH
// ===============================

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> groups = [];
  bool loading = true;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      final result = await supabase.rpc('get_my_school_groups');

      if (!mounted) return;

      setState(() {
        groups = List<Map<String, dynamic>>.from(
          result ?? [],
        );
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(context, 'Gagal memuat grup: $e');
    }
  }

  Future<void> activateGroup(String schoolId) async {
    if (processing) return;

    setState(() => processing = true);

    try {
      await supabase.rpc(
        'set_active_school_group',
        params: {'p_school_id': schoolId},
      );

      await loadGroups();

      if (!mounted) return;
      showMessage(context, 'Grup berhasil dipilih sebagai grup aktif.');
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal memilih grup: $e');
    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
  }

  Future<void> createGroup() async {
    if (processing) return;

    if (groups.length >= 5) {
      showMessage(context, 'Maksimal hanya 5 grup.');
      return;
    }

    final nameController = TextEditingController();
    final districtController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buat Grup Sekolah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama sekolah / grup',
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('BUAT GRUP'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (nameController.text.trim().isEmpty) {
      showMessage(context, 'Nama grup wajib diisi.');
      return;
    }

    setState(() => processing = true);

    try {
      final result = await supabase.rpc(
        'create_school_group',
        params: {
          'p_name': nameController.text.trim(),
          'p_district': districtController.text.trim().isEmpty
              ? null
              : districtController.text.trim(),
        },
      );

      String? schoolId;

      if (result is List && result.isNotEmpty) {
        schoolId = result.first['school_id']?.toString();
      } else if (result is Map) {
        schoolId = result['school_id']?.toString();
      }

      await loadGroups();

      if (schoolId != null && schoolId.isNotEmpty) {
        await supabase.rpc(
          'set_active_school_group',
          params: {'p_school_id': schoolId},
        );

        await loadGroups();

        if (!mounted) return;

        showMessage(context, 'Grup berhasil dibuat dan dipilih.');

        final selectedGroup = groups.firstWhere(
          (g) => g['school_id'].toString() == schoolId,
          orElse: () => {},
        );

        if (selectedGroup.isNotEmpty) {
          openGroup(selectedGroup);
        }
      } else {
        if (!mounted) return;
        showMessage(
          context,
          'Grup dibuat, tetapi ID grup tidak ditemukan. Pilih grup dari daftar.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal membuat grup: $e');
    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
  }

  Future<void> joinGroup() async {
    if (processing) return;

    if (groups.length >= 5) {
      showMessage(context, 'Maksimal hanya 5 grup.');
      return;
    }

    final codeController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gabung Grup'),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Kode undangan',
            hintText: 'Masukkan kode grup',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('GABUNG'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final inviteCode = codeController.text.trim().toUpperCase();

    if (inviteCode.isEmpty) {
      showMessage(context, 'Kode undangan wajib diisi.');
      return;
    }

    final oldIds = groups
        .map((g) => g['school_id'].toString())
        .toSet();

    setState(() => processing = true);

    try {
      await supabase.rpc(
        'join_school_group',
        params: {'p_invite_code': inviteCode},
      );

      await loadGroups();

      final joinedGroup = groups.cast<Map<String, dynamic>?>().firstWhere(
        (g) =>
            g != null &&
            !oldIds.contains(g['school_id'].toString()),
        orElse: () => null,
      );

      if (joinedGroup != null) {
        await supabase.rpc(
          'set_active_school_group',
          params: {
            'p_school_id': joinedGroup['school_id'],
          },
        );

        await loadGroups();

        if (!mounted) return;
        showMessage(context, 'Berhasil bergabung dan memilih grup aktif.');
      } else {
        if (!mounted) return;
        showMessage(
          context,
          'Proses gabung selesai. Jika grup belum aktif, pilih dari daftar grup.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal bergabung: $e');
    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
  }

  void openGroup(Map<String, dynamic> group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(group: group),
      ),
    );

    if (mounted) loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = groups.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grup Sekolah'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: BatikBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: loadGroups,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'GRUP SAYA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$activeCount / 5 grup digunakan',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Pilih satu grup aktif. Laporan SOS nantinya hanya akan dikirim ke grup yang kamu pilih.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: processing || groups.length >= 5
                                ? null
                                : createGroup,
                            icon: const Icon(Icons.add),
                            label: const Text('BUAT GRUP'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: processing || groups.length >= 5
                                ? null
                                : joinGroup,
                            icon: const Icon(Icons.group_add),
                            label: const Text('GABUNG'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (groups.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Kamu belum bergabung dengan grup mana pun.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ...groups.map((group) {
                      final isActive = group['is_active'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: maroon,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      group['school_name']?.toString() ??
                                          'Tanpa nama',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    const Chip(
                                      label: Text('AKTIF'),
                                      backgroundColor: Color(0xFFD9F2DD),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kecamatan: ${group['district'] ?? '-'}',
                              ),
                              Text(
                                'Peran: ${group['member_role'] ?? 'anggota'}',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => openGroup(group),
                                      child: const Text('DETAIL GRUP'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isActive)
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: processing
                                            ? null
                                            : () => activateGroup(
                                                  group['school_id'].toString(),
                                                ),
                                        child: const Text('GUNAKAN'),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}



// ===============================
// DETAIL GRUP DAN ANGGOTA
// ===============================

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> group;

  const GroupDetailPage({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> members = [];
  bool loading = true;
  bool refreshing = false;
  bool processing = false;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  bool get isAdmin {
    final role = widget.group['member_role']?.toString().toLowerCase();
    return role == 'school_admin' || role == 'admin';
  }

  Future<void> loadMembers() async {
    try {
      final result = await supabase.rpc(
        'get_school_group_members',
        params: {
          'p_school_id': widget.group['school_id'],
        },
      );

      if (!mounted) return;

      setState(() {
        members = List<Map<String, dynamic>>.from(result ?? []);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage(context, 'Gagal memuat anggota: $e');
    }
  }

  Future<void> refreshInviteCode() async {
    if (refreshing || processing) return;

    setState(() => refreshing = true);

    try {
      final result = await supabase.rpc(
        'refresh_school_invite_code',
        params: {
          'p_school_id': widget.group['school_id'],
        },
      );

      if (!mounted) return;

      setState(() {
        widget.group['invite_code'] = result.toString();
      });

      showMessage(context, 'Kode undangan berhasil diperbarui.');
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal memperbarui kode: $e');
    } finally {
      if (mounted) setState(() => refreshing = false);
    }
  }

  Future<bool> confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<void> leaveGroup() async {
    if (processing) return;

    final confirmed = await confirmAction(
      title: 'Keluar dari grup?',
      message:
          'Kamu akan keluar dari grup ini. '
          'Kamu akan keluar dari grup ini dan tidak lagi dapat mengakses riwayat grup.',
      confirmText: 'YA, KELUAR',
    );

    if (!confirmed || !mounted) return;

    setState(() => processing = true);

    try {
      await supabase.rpc(
        'leave_school_group',
        params: {
          'p_school_id': widget.group['school_id'],
        },
      );

      if (!mounted) return;

      showMessage(context, 'Kamu berhasil keluar dari grup.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal keluar dari grup: $e');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  Future<void> archiveGroup() async {
    if (!isAdmin || processing) return;

    final confirmed = await confirmAction(
      title: 'Arsipkan grup?',
      message:
          'Grup tidak bisa digunakan untuk bergabung atau '
          'mengirim laporan SOS baru. '
          'Riwayat laporan dan tanggapan tetap disimpan.',
      confirmText: 'ARSIPKAN',
    );

    if (!confirmed || !mounted) return;

    setState(() => processing = true);

    try {
      await supabase.rpc(
        'archive_school_group',
        params: {
          'p_school_id': widget.group['school_id'],
        },
      );

      if (!mounted) return;

      showMessage(context, 'Grup berhasil diarsipkan.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal mengarsipkan grup: $e');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  // ===============================
  // HAPUS PERMANEN GRUP
  // ===============================

  Future<void> deleteGroup() async {
    if (!isAdmin || processing) return;

    final firstConfirm = await confirmAction(
      title: 'Hapus grup permanen?',
      message:
          'Grup "${
            widget.group['school_name'] ?? 'Grup Sekolah'
          }" akan dihapus untuk semua anggota.\n\n'
          'Seluruh laporan SOS, tanggapan, dan keanggotaan '
          'grup ini juga akan terhapus permanen.\n\n'
          'Profil akun pengguna tetap aman. '
          'Tindakan ini tidak bisa dibatalkan.',
      confirmText: 'LANJUTKAN',
    );

    if (!firstConfirm || !mounted) return;

    final controller = TextEditingController();
    final groupName =
        widget.group['school_name']?.toString() ?? 'Grup Sekolah';

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi terakhir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ketik nama grup di bawah ini untuk '
                'mengonfirmasi penghapusan:',
              ),
              const SizedBox(height: 12),
              Text(
                groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ketik nama grup',
                  border: OutlineInputBorder(),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim() == groupName,
                );
              },
              child: const Text('HAPUS PERMANEN'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (secondConfirm != true || !mounted) {
      if (mounted) {
        showMessage(context, 'Konfirmasi nama grup tidak sesuai.');
      }
      return;
    }

    setState(() => processing = true);

    try {
      await supabase.rpc(
        'delete_school_group',
        params: {
          'p_school_id': widget.group['school_id'],
        },
      );

      if (!mounted) return;

      showMessage(context, 'Grup berhasil dihapus permanen.');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal menghapus grup: $e');
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName =
        widget.group['school_name']?.toString() ?? 'Grup Sekolah';

    final inviteCode =
        widget.group['invite_code']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Grup'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: BatikBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      color: maroon,
                      size: 48,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      groupName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kecamatan: ${widget.group['district'] ?? '-'}',
                    ),
                    const Divider(height: 28),
                    const Text(
                      'KODE UNDANGAN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      inviteCode,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                        color: maroon,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: processing
                          ? null
                          : () {
                              showMessage(
                                context,
                                'Kode undangan: $inviteCode',
                              );
                            },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('LIHAT KODE'),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: refreshing || processing
                            ? null
                            : refreshInviteCode,
                        icon: const Icon(Icons.refresh),
                        label: const Text('GANTI KODE UNDANGAN'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ANGGOTA GRUP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: loading || processing
                              ? null
                              : loadMembers,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (members.isEmpty)
                      const Text('Belum ada data anggota.')
                    else
                      ...members.map((member) {
                        final name =
                            member['full_name']?.toString() ??
                                'Anggota PMR';
                        final role =
                            member['role']?.toString() ?? 'anggota';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: maroon,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(role),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'KELOLA GRUP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: processing ? null : leaveGroup,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: maroon,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('KELUAR DARI GRUP'),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: processing ? null : archiveGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('ARSIPKAN GRUP'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: processing ? null : deleteGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('HAPUS PERMANEN'),
                      ),
                    ],
                    if (processing) ...[
                      const SizedBox(height: 12),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// RIWAYAT LAPORAN SOS
// ===============================

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  String formatDate(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> loadReports() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      // Mengambil grup aktif dan grup yang diarsipkan.
      final groups =
          await supabase.rpc('get_my_history_school_groups');

      final groupList =
          List<Map<String, dynamic>>.from(groups ?? []);

      final schoolIds = groupList
          .map((group) => group['school_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      if (schoolIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          reports = [];
          loading = false;
        });
        return;
      }

      final result = await supabase
          .from('emergency_reports')
          .select()
          .inFilter('school_id', schoolIds)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        reports = List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(context, 'Gagal memuat riwayat: $e');
    }
  }

  Future<void> openReport(
    Map<String, dynamic> report,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailPage(report: report),
      ),
    );

    if (mounted) {
      loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loading ? null : loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BatikBackground(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : reports.isEmpty
                ? const Center(
                    child: Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history,
                              size: 55,
                              color: maroon,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum Ada Laporan',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Laporan SOS dari grup sekolahmu akan muncul di sini.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadReports,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];

                        final message =
                            report['message']?.toString() ??
                                'Laporan darurat';

                        final sender =
                            report['sender_id']?.toString() ??
                                '-';

                        final date =
                            formatDate(report['created_at']);

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(14),
                            leading: const CircleAvatar(
                              backgroundColor: maroon,
                              child: Icon(
                                Icons.warning_amber,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              message,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Pengirim: $sender'),
                                  Text('Waktu: $date'),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () => openReport(report),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

// ===============================
// DETAIL LAPORAN DAN TANGGAPAN
// ===============================

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailPage({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailPage> createState() =>
      _ReportDetailPageState();
}

class _ReportDetailPageState
    extends State<ReportDetailPage> {
  final supabase = Supabase.instance.client;
  final responseController = TextEditingController();

  List<Map<String, dynamic>> responses = [];

  bool loading = true;
  bool sending = false;

  String formatDate(dynamic value) {
    if (value == null) return '-';

    try {
      final date = DateTime.parse(value.toString()).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    loadResponses();
  }

  @override
  void dispose() {
    responseController.dispose();
    super.dispose();
  }

  Future<void> loadResponses() async {
    try {
      final result = await supabase
          .from('emergency_responses')
          .select()
          .eq('report_id', widget.report['id'])
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        responses =
            List<Map<String, dynamic>>.from(result);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(context, 'Gagal memuat tanggapan: $e');
    }
  }

  Future<void> sendResponse() async {
    final message = responseController.text.trim();

    if (message.isEmpty || sending) return;

    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage(context, 'Silakan login terlebih dahulu.');
      return;
    }

    setState(() => sending = true);

    try {
      final result = await supabase
          .from('emergency_responses')
          .insert({
            'report_id': widget.report['id'],
            'user_id': user.id,
            'response': message,
          })
          .select()
          .single();

      responseController.clear();

      if (!mounted) return;

      await loadResponses();

      try {
        await sendPmrNotification(
          event: 'response_created',
          body: {
            'response_id': result['id'],
          },
        );

        if (!mounted) return;

        showMessage(
          context,
          'Tanggapan berhasil dikirim dan notifikasi diproses.',
        );
      } catch (notificationError) {
        if (!mounted) return;

        showMessage(
          context,
          'Tanggapan tersimpan, tetapi notifikasi gagal dikirim.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        context,
        'Gagal mengirim tanggapan: $e',
      );
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final message =
        widget.report['message']?.toString() ??
            'Laporan darurat';

    final sender =
        widget.report['sender_id']?.toString() ?? '-';

    final date = formatDate(widget.report['created_at']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: BatikBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'LAPORAN SOS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Pengirim: $sender'),
                          Text('Waktu: $date'),
                          if (widget.report['latitude'] != null &&
                              widget.report['longitude'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: ${widget.report['latitude']}',
                            ),
                            Text(
                              'Longitude: ${widget.report['longitude']}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'TANGGAPAN ANGGOTA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (loading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (responses.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Belum ada tanggapan untuk laporan ini.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...responses.map((response) {
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: maroon,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            response['response']?.toString() ??
                                '-',
                          ),
                          subtitle: Text(
                            'Pengirim: ${response['user_id'] ?? '-'}\n'
                            '${formatDate(response['created_at'])}',
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: responseController,
                        minLines: 1,
                        maxLines: 3,
                        enabled: !sending,
                        decoration: const InputDecoration(
                          hintText: 'Tulis tanggapan...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: sending ? null : sendResponse,
                      style: IconButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: Colors.white,
                      ),
                      icon: sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// PROFIL PENGGUNA
// ===============================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final classController = TextEditingController();

  Map<String, dynamic>? profile;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Pengguna belum login');
      }

      final result = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      profile = result;

      nameController.text =
          result?['full_name']?.toString() ?? '';

      classController.text =
          result?['class_name']?.toString() ?? '';

      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);
      showMessage(context, 'Gagal memuat profil: $e');
    }
  }

  Future<void> saveProfile() async {
    if (saving) return;

    if (nameController.text.trim().isEmpty) {
      showMessage(context, 'Nama wajib diisi.');
      return;
    }

    setState(() => saving = true);

    try {
      await supabase.rpc(
        'update_my_profile',
        params: {
          'p_full_name': nameController.text.trim(),
          'p_class_name': classController.text.trim(),
        },
      );

      if (!mounted) return;

      showMessage(context, 'Profil berhasil diperbarui.');
      await loadProfile();
    } catch (e) {
      if (!mounted) return;
      showMessage(context, 'Gagal menyimpan profil: $e');
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('KELUAR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: maroon,
        foregroundColor: Colors.white,
      ),
      body: BatikBackground(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: maroon,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      email,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INFORMASI PENGGUNA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: classController,
                            decoration: const InputDecoration(
                              labelText: 'Kelas',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.school),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: saving ? null : saveProfile,
                              icon: const Icon(Icons.save),
                              label: Text(
                                saving ? 'MENYIMPAN...' : 'SIMPAN PROFIL',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('KELUAR DARI AKUN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'PMR EMERGENCY V2',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: maroon,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Future<void> sendPmrNotification({
  required String event,
  required Map<String, dynamic> body,
}) async {
  await supabase.functions.invoke(
  'send-pmr-notification',
    body: {
      'event': event,
      ...body,
    },
  );
}