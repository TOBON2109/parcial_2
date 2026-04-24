import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/accidentes/accidentes_view.dart';
import 'views/establecimientos/lista_view.dart';
import 'views/establecimientos/formulario_view.dart';
import 'views/establecimientos/detalle_view.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (c, s) => const DashboardView(),
    ),
    GoRoute(
      path: '/accidentes',
      name: 'accidentes',
      builder: (c, s) => const AccidentesView(),
    ),
    GoRoute(
      path: '/establecimientos',
      name: 'establecimientos',
      builder: (c, s) => const ListaView(),
    ),
    GoRoute(
      path: '/establecimientos/crear',
      name: 'crear',
      builder: (c, s) => const FormularioView(),
    ),
    GoRoute(
      path: '/establecimientos/:id',
      name: 'detalle',
      builder: (c, s) => DetalleView(id: s.pathParameters['id']!),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Parcial 2',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: _router,
    );
  }
}
