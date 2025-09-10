import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/services/cloudinary_upload_service.dart';
import '../../../core/widgets/app_logo.dart';

class SeekerProfilePage extends ConsumerStatefulWidget {
  const SeekerProfilePage({super.key});
  @override
  ConsumerState<SeekerProfilePage> createState() => _SeekerProfilePageState();
}

class _SeekerProfilePageState extends ConsumerState<SeekerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _cnic = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _address = TextEditingController();
  final _experienceYears = TextEditingController();
  final _skills = TextEditingController();
  final _expectedSalary = TextEditingController();
  // Preferences
  final Set<String> _preferredCategories = {};
  final List<String> _preferredCities = [];
  double _minSalaryPref = 0;
  String? _cvUrl;
  String? _photoUrl;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _cnic.dispose();
    _city.dispose();
    _country.dispose();
    _address.dispose();
    _experienceYears.dispose();
    _skills.dispose();
    _expectedSalary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userAsync = ref.watch(userStreamProvider(uid));

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Edit Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: userAsync.when(
        data: (u) {
          // Initialize fields once
          if (u != null) {
            _name.text = u.name ?? _name.text;
            _phone.text = u.phone ?? _phone.text;
            _cnic.text = u.cnic ?? _cnic.text;
            _city.text = u.city ?? _city.text;
            _country.text = u.country ?? _country.text;
            _address.text = u.address ?? _address.text;
            _experienceYears.text = (u.experienceYears ?? 0).toString();
            _skills.text = (u.skills ?? []).join(', ');
            _expectedSalary.text = (u.expectedSalary ?? 0).toString();
            _cvUrl ??= u.cvUrl;
            _photoUrl ??= u.profilePhotoUrl;
            _preferredCategories
              ..clear()
              ..addAll(u.preferredCategories);
            _preferredCities
              ..clear()
              ..addAll(u.preferredCities);
            _minSalaryPref = (u.minSalaryPreferred ?? 0).toDouble();
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage:
                            _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                        child: _photoUrl == null
                            ? const Icon(Icons.person, size: 44)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          icon: const Icon(Icons.camera_alt_outlined),
                          onPressed: _uploadPhoto,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextFormField(
                    controller: _phone,
                    decoration: const InputDecoration(labelText: 'Phone')),
                TextFormField(
                    controller: _cnic,
                    decoration: const InputDecoration(labelText: 'CNIC')),
                TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'City')),
                TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(labelText: 'Country')),
                TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address')),
                TextFormField(
                    controller: _experienceYears,
                    decoration:
                        const InputDecoration(labelText: 'Experience Years'),
                    keyboardType: TextInputType.number),
                TextFormField(
                    controller: _skills,
                    decoration: const InputDecoration(
                        labelText: 'Skills (comma-separated)')),
                TextFormField(
                    controller: _expectedSalary,
                    decoration:
                        const InputDecoration(labelText: 'Expected Salary'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Text('Job Preferences',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in [
                      'Engineering',
                      'Design',
                      'Marketing',
                      'Sales',
                      'Finance',
                      'HR'
                    ])
                      FilterChip(
                        label: Text(c),
                        selected: _preferredCategories.contains(c),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _preferredCategories.add(c);
                            } else {
                              _preferredCategories.remove(c);
                            }
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _CityTags(
                  initial: _preferredCities,
                  onChanged: (v) {
                    setState(() {
                      _preferredCities
                        ..clear()
                        ..addAll(v);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text('Minimum Salary Preference'),
                Slider(
                  value: _minSalaryPref,
                  min: 0,
                  max: 500000,
                  divisions: 100,
                  label: _minSalaryPref.round().toString(),
                  onChanged: (v) => setState(() => _minSalaryPref = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          _cvUrl == null ? 'No CV uploaded' : 'CV attached'),
                    ),
                    TextButton.icon(
                      onPressed: _uploadCV,
                      icon: const Icon(Icons.upload_file),
                      label: Text(_cvUrl == null ? 'Upload CV' : 'Replace CV'),
                    ),
                  ],
                ),
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

  Future<void> _uploadPhoto() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked == null) return;
    final file = File(picked.files.single.path!);
    final res = await CloudinaryUploadService.uploadProfileImage(
      file: file,
      customPublicId:
          'jobhunt-dev/profile/${FirebaseAuth.instance.currentUser!.uid}',
    );
    setState(() => _photoUrl = res.secureUrl);
  }

  Future<void> _uploadCV() async {
    final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (picked == null) return;
    final file = File(picked.files.single.path!);
    final res = await CloudinaryUploadService.uploadCV(
      file: file,
      customPublicId:
          'jobhunt-dev/profile/${FirebaseAuth.instance.currentUser!.uid}/cv',
    );
    setState(() => _cvUrl = res.secureUrl);
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    final skills = _skills.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final partial = <String, dynamic>{
      'name': _name.text,
      'phone': _phone.text,
      'cnic': _cnic.text,
      'city': _city.text,
      'country': _country.text,
      'address': _address.text,
      'experienceYears': int.tryParse(_experienceYears.text),
      'skills': skills,
      'expectedSalary': int.tryParse(_expectedSalary.text),
      if (_cvUrl != null) 'cvUrl': _cvUrl,
      if (_photoUrl != null) 'profilePhotoUrl': _photoUrl,
      'preferredCategories': _preferredCategories.toList(),
      'preferredCities': _preferredCities,
      'minSalaryPreferred': _minSalaryPref.round(),
    };
    await ref.read(userRepositoryProvider).updateUser(uid, partial);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }
  }
}

class _CityTags extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>> onChanged;
  const _CityTags({required this.initial, required this.onChanged});
  @override
  State<_CityTags> createState() => _CityTagsState();
}

class _CityTagsState extends State<_CityTags> {
  late final TextEditingController _ctrl;
  late List<String> _tags;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _tags = List.of(widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    setState(() {
      if (!_tags.contains(v)) _tags.add(v);
      _ctrl.clear();
    });
    widget.onChanged(_tags);
  }

  void _removeTag(String v) {
    setState(() => _tags.remove(v));
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          decoration: const InputDecoration(
            labelText: 'Preferred Cities',
            hintText: 'Type a city and press Enter',
          ),
          onSubmitted: _addTag,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _tags)
              Chip(
                label: Text(t),
                onDeleted: () => _removeTag(t),
              ),
          ],
        )
      ],
    );
  }
}
