import 'package:flutter/material.dart';
import 'package:insights/upload_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://pvotaaukwfeabaqtahfu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2b3RhYXVrd2ZlYWJhcXRhaGZ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDI5OTQwMDcsImV4cCI6MjAxODU3MDAwN30.Xv5gQJklMkH9NKq222NHYdGLlE722QemDe8__Bg2pl4',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
      ),
      debug: false,
      storageOptions: const StorageClientOptions(
        retryAttempts: 3,
      ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UploadPage(),
    );
  }
}
