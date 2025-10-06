import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// auth controller removed; using AuthBloc instead
import '../../../auth/app/bloc/auth_bloc.dart';
import '../../../auth/app/bloc/auth_state.dart';
import '../../../auth/app/bloc/auth_event.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Auth placeholder - Phone + OTP flow'),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, dynamic>(
              bloc: authBloc,
              builder: (context, state) {
                final loggedIn = state is Authenticated;
                return ElevatedButton(
                  onPressed: () {
                    authBloc.add(ToggleAuthEvent());
                  },
                  child: Text(loggedIn ? 'Log out (demo)' : 'Log in (demo)'),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // navigate to home for manual test
                GoRouter.of(context).go('/home');
              },
              child: const Text('Go to Home (bypass)'),
            ),
          ],
        ),
      ),
    );
  }
}
