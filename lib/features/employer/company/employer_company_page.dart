import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/services/cloudinary_upload_service.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerCompanyPage extends ConsumerStatefulWidget {
  const EmployerCompanyPage({super.key});
  @override
  ConsumerState<EmployerCompanyPage> createState() =>
      _EmployerCompanyPageState();
}

class _EmployerCompanyPageState extends ConsumerState<EmployerCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _website = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _about = TextEditingController();
  String? _logoUrl;
  bool _saving = false;

  @override
  void dispose() {
    _companyName.dispose();
    _website.dispose();
    _city.dispose();
    _country.dispose();
    _about.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userAsync = ref.watch(userStreamProvider(uid));

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Company Profile'),
      body: userAsync.when(
        data: (u) {
          if (u != null) {
            _companyName.text = u.companyName ?? _companyName.text;
            _website.text = u.website ?? _website.text;
            _city.text = u.city ?? _city.text;
            _country.text = u.country ?? _country.text;
            _about.text = u.about ?? _about.text;
            _logoUrl ??= u.companyLogoUrl;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage:
                            _logoUrl != null ? NetworkImage(_logoUrl!) : null,
                        child: _logoUrl == null
                            ? const Icon(Icons.apartment_outlined, size: 44)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _uploadLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload Logo'),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _companyName,
                    decoration:
                        const InputDecoration(labelText: 'Company Name')),
                TextFormField(
                    controller: _website,
                    decoration: const InputDecoration(labelText: 'Website')),
                TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City')),
                TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(labelText: 'Country')),
                TextFormField(
                    controller: _about,
                    decoration: const InputDecoration(labelText: 'About'),
                    maxLines: 5),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : () => _save(uid),
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _uploadLogo() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked == null) return;
    final file = File(picked.files.single.path!);
    final res = await CloudinaryUploadService.uploadCompanyLogo(
      file: file,
      customPublicId:
          'jobhunt-dev/company_logos/${FirebaseAuth.instance.currentUser!.uid}',
    );
    setState(() => _logoUrl = res.secureUrl);
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    final partial = <String, dynamic>{
      'companyName': _companyName.text,
      'website': _website.text,
      'city': _city.text,
      'country': _country.text,
      'about': _about.text,
      if (_logoUrl != null) 'companyLogoUrl': _logoUrl,
    };
    await ref.read(userRepositoryProvider).updateUser(uid, partial);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile updated')),
      );
    }
  }
}
