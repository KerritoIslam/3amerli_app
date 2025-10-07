import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// auth controller removed; using AuthBloc instead
import '../../../auth/app/bloc/auth_bloc.dart';
import '../../../auth/app/bloc/auth_state.dart';
import '../../../auth/app/bloc/auth_event.dart';
import 'package:go_router/go_router.dart';
import '../../../../utils/helpers/logger.dart';
import '../../../../widgets/app_text_feild.dart';
import '../../../../widgets/app_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 12),

            // Reusable input field (e.g., phone or email)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AppTextField(
                controller: _controller,
                hintText: 'Phone number or email',
                labelText: null,
                keyboardType: TextInputType.emailAddress,
                leading: const Icon(Icons.person),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    logInfo('[AuthPage] current auth state: ${authBloc.state}');
                  },
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (v) {
                  // Optionally submit or validate
                },
              ),
            ),

            const SizedBox(height: 16),

            // Demo switch that toggles authentication state
            BlocBuilder<AuthBloc, AuthState>(
              bloc: authBloc,
              builder: (context, state) {
                final loggedIn = state is Authenticated;
                return SwitchListTile(
                  title: Text(loggedIn ? 'Logged in (demo)' : 'Logged out (demo)'),
                  value: loggedIn,
                  onChanged: (value) {
                    if (value) {
                      authBloc.add(LogInEvent());
                    } else {
                      authBloc.add(LogOutEvent());
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // manual toggle — keeps compatibility with older flow
                authBloc.add(ToggleAuthEvent());
              },
              child: const Text('Toggle Auth (demo)'),
            ),

            const SizedBox(height: 8),
            // Demo app-styled button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AppButton(
                text: 'Passer',
                onPressed: () {
                  GoRouter.of(context).go('/home');
                },
                // default full circular primary-filled style
                tooltip: 'Passer (demo)',
                height: 48,
              ),
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
