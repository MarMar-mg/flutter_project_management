import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/admin/home_page/pages/home_page.dart';
import 'features/register/login/pages/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}
final SupaBase = SupabaseClient(
  'https://gedtkszijsgnzzdgbbka.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdlZHRrc3ppanNnbnp6ZGdiYmthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxMzg4NjIsImV4cCI6MjA1MDcxNDg2Mn0.KloVWeauDqAp50WBuKwEqFdDJ86Mw4eREewgyuAS9zI',
);
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectManagement',
      scrollBehavior:
      ScrollConfiguration.of(context).copyWith(scrollbars: false),
      localizationsDelegates: const [
        DefaultWidgetsLocalizations.delegate,
      ],
      builder: (_, child) => child == null
          ? const SizedBox()
          : Directionality(textDirection: TextDirection.rtl, child: child),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}