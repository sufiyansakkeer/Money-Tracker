import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/snack_bar_extension.dart';
import 'package:money_track/core/widgets/custom_app_bar.dart';
import 'package:money_track/features/auth/presentation/bloc/auth_bloc.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _displayNameController.text = authState.user.displayName ?? '';
      _usernameController.text = authState.user.username ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(
            UpdateProfileEvent(
              displayName: _displayNameController.text.trim().isNotEmpty
                  ? _displayNameController.text.trim()
                  : null,
              username: _usernameController.text.trim().isNotEmpty
                  ? _usernameController.text.trim()
                  : null,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, title: "Profile Settings"),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() {
            _isLoading = false;
          });

          if (state is AuthAuthenticated) {
            'Profile updated successfully!'.showSnack();
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            state.message.showSnack();
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    32.height(),
                    
                    // Title
                    Text(
                      'Edit Profile',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.getTextColor(context),
                          ),
                    ),
                    8.height(),
                    Text(
                      'Update your profile information',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ColorConstants.getTextColor(context)
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    32.height(),

                    // Display Name field
                    Text(
                      "Display Name",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorConstants.getTextColor(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    8.height(),
                    TextFormField(
                      controller: _displayNameController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Enter your display name",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: StyleConstants.textFormFieldBorder(),
                        enabledBorder: StyleConstants.textFormFieldBorder(),
                        focusedBorder:
                            StyleConstants.textFormFieldBorder().copyWith(
                          borderSide: BorderSide(
                            color: ColorConstants.getThemeColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 2) {
                          return 'Display name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    16.height(),

                    // Username field
                    Text(
                      "Username",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: ColorConstants.getTextColor(context)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    8.height(),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: "Enter your username",
                        prefixIcon: const Icon(Icons.alternate_email),
                        border: StyleConstants.textFormFieldBorder(),
                        enabledBorder: StyleConstants.textFormFieldBorder(),
                        focusedBorder:
                            StyleConstants.textFormFieldBorder().copyWith(
                          borderSide: BorderSide(
                            color: ColorConstants.getThemeColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (value.length > 20) {
                            return 'Username must be less than 20 characters';
                          }
                          // Allow letters, numbers, underscores, and dots
                          if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                            return 'Username can only contain letters, numbers, dots, and underscores';
                          }
                        }
                        return null;
                      },
                    ),
                    32.height(),

                    // Update button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: StyleConstants.elevatedButtonStyle(
                            context: context),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : const Text(
                                'Update Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
