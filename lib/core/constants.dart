import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFE50914);
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF141414);
  static const Color textStorage = Color(0xFFB3B3B3);
}

class AppConstants {
  // TODO: Substitua pelas suas credenciais do Supabase
  static const String supabaseUrl = 'https://qyagfghcnzenvbhbtsvd.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YWdmZ2hjbnplbnZiaGJ0c3ZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDU2NjksImV4cCI6MjA4MzMyMTY2OX0.k_cVE7tLn23NIuuMJlCdWw97F_ZkPpz7SS7d-MleJVc';

  // URL do serviço de pagamento (VPS)
  // Ajuste o protocolo (http/https) e a porta conforme configuração da VPS
  static const String vpsUrl =
      'https://adminweb-kappa.vercel.app/api/payment-manager';
}

const List<String> kAvatars = [
  'https://mir-s3-cdn-cf.behance.net/project_modules/disp/84c20033850498.56ba69ac290ea.png',
  'https://mir-s3-cdn-cf.behance.net/project_modules/disp/64623a33850498.56ba69ac2a6f7.png',
  'https://mir-s3-cdn-cf.behance.net/project_modules/disp/1bdc9a33850498.56ba69ac2ba5b.png',
  'https://mir-s3-cdn-cf.behance.net/project_modules/disp/f9eb8133850498.56ba69ac2f94e.png',
  'https://pro2-bar-s3-cdn-cf1.myportfolio.com/dddb0c1b4ab6b284bbc4c046dd14eac9/931268bc-a745-429d-8c17-3bf79b4a159f_rw_600.png?h=560ee95495570221389acb37373f728c',
];
