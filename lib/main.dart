import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crud/screens/login_screen.dart'; // Thêm đường dẫn đến màn hình đăng nhập

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Sản Phẩm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // Thiết lập trang đăng nhập làm trang mặc định
    );
  }
}
