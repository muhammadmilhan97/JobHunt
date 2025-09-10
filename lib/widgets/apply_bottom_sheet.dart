import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../core/models/job.dart';
import '../core/services/firebase_service.dart';
import '../core/services/analytics_service.dart';
import '../core/providers/app_providers.dart';

class ApplyBottomSheet extends ConsumerStatefulWidget {
  final Job job;

  const ApplyBottomSheet({super.key, required this.job});

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();
  final _expectedSalaryController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    _expectedSalaryController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      // Get signed upload URL from Cloud Function
      final response = await http.post(
        Uri.parse(
            'https://us-central1-jobhunt-dev.cloudfunctions.net/signCloudinaryUpload'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'folder': 'jobhunt-dev/cv',
          'preset': 'jobhunt_cv_signed',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get upload URL');
      }

      final uploadData = json.decode(response.body);
      final uploadUrl = uploadData['uploadUrl'];
      final publicId = uploadData['publicId'];

      // Upload file to Cloudinary
      final uploadRequest = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      uploadRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ),
      );

      final uploadResponse = await uploadRequest.send();
      if (uploadResponse.statusCode != 200) {
        throw Exception('Failed to upload file');
      }

      return 'https://res.cloudinary.com/jobhunt-dev/image/upload/v1/$publicId';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a CV file')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload CV file
      final cvUrl = await _uploadFile();
      if (cvUrl == null) return;

      // Create application document
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to apply')),
        );
        return;
      }

      final applicationData = {
        'jobId': widget.job.id,
        'jobSeekerId': currentUser.uid,
        'employerId': widget.job.employerId,
        'status': 'pending',
        'cvUrl': cvUrl,
        'coverLetter': _coverLetterController.text.trim(),
        'expectedSalary': _expectedSalaryController.text.isNotEmpty
            ? int.tryParse(_expectedSalaryController.text)
            : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'jobTitle': widget.job.title,
        'employerName': widget.job.company,
      };

      await FirebaseService.firestore
          .collection('applications')
          .add(applicationData);

      // Log analytics
      await AnalyticsService.logApply(jobId: widget.job.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Apply for ${widget.job.title}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'at ${widget.job.company}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // CV Upload
                      Text(
                        'CV/Resume *',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            if (_selectedFile != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.description,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedFile!.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedFile = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Icon(
                                Icons.upload_file,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload your CV/Resume',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF, DOC, or DOCX (max 10MB)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (_selectedFile == null)
                              FilledButton.icon(
                                onPressed: _isUploading ? null : _pickFile,
                                icon: const Icon(Icons.upload),
                                label: Text(_isUploading
                                    ? 'Uploading...'
                                    : 'Choose File'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Cover Letter
                      Text(
                        'Cover Letter',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _coverLetterController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText:
                              'Tell us why you\'re a great fit for this role...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Expected Salary
                      Text(
                        'Expected Salary (Optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _expectedSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter your expected salary',
                          border: OutlineInputBorder(),
                          prefixText: '\$',
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final salary = int.tryParse(value);
                            if (salary == null || salary < 0) {
                              return 'Please enter a valid salary';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _isSubmitting || _isUploading ? null : _submitApplication,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Application',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
