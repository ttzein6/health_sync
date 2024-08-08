import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_sync/blocs/auth/auth_bloc.dart';
import 'package:health_sync/models/user.dart';
import 'package:health_sync/services/auth_service.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SafeArea(
        child: BlocSelector<AuthBloc, AuthState, User?>(
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
                        child: Stack(
                          children: [
                            Flex(
                              direction: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user.imageUrl ?? "",
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Opacity(
                                        opacity: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : 1,
                                        child: const Icon(
                                          Icons.account_circle_outlined,
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name ?? "",
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        user.email ?? "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Column(
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        //TODO: Implement edit profile
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
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
      ),
    );
  }
}
