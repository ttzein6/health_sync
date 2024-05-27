import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/models/user.dart';
import 'package:health_sync/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: BlocSelector<AuthBloc, AuthState, User?>(
        selector: (state) => state.user,
        builder: (context, user) {
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: CircleAvatar(
                              backgroundImage: Image.network(
                                user.imageUrl ?? "",
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  return const Icon(
                                      Icons.account_circle_outlined);
                                },
                              ).image,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? "",
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                user.email ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              //TODO: Implement edit profile
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Auth.signOut();
                    },
                    label: const Text("Sign Out"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
