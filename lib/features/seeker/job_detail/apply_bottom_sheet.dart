import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/cloudinary_upload_service.dart';
import '../../../core/services/application_service.dart';

class ApplyBottomSheet extends ConsumerStatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String employerId;

  const ApplyBottomSheet({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.employerId,
  });

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _expectedSalaryController = TextEditingController();
  final _coverLetterController = TextEditingController();

  File? _selectedFile;
  String? _uploadedCvUrl;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _uploadCompleted = false;
  String? _uploadError;

  @override
  void dispose() {
    _expectedSalaryController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        _uploadError = null;
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Enhanced file validation
        if (!await file.exists()) {
          setState(() {
            _uploadError = 'Selected file does not exist.';
          });
          return;
        }

        final fileSize = await file.length();
        if (fileSize == 0) {
          setState(() {
            _uploadError = 'Selected file is empty.';
          });
          return;
        }

        if (fileSize > 10 * 1024 * 1024) {
          setState(() {
            _uploadError =
                'File size exceeds 10MB limit. Please select a smaller file.';
          });
          return;
        }

        if (!CloudinaryUploadService.isValidCVFile(file)) {
          setState(() {
            _uploadError =
                'Invalid file type. Please select a PDF, DOC, or DOCX file.';
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _uploadCompleted = false;
          _uploadedCvUrl = null;
          _uploadError = null;
        });

        // Start upload immediately after file selection
        await _uploadFile();
      }
    } catch (e) {
      setState(() {
        _uploadError = _getFriendlyErrorMessage('Error picking file: $e');
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadError = null;
    });

    try {
      // Validate file before upload
      if (!await _selectedFile!.exists()) {
        throw Exception('Selected file no longer exists');
      }

      final fileSize = await _selectedFile!.length();
      if (fileSize == 0) {
        throw Exception('Selected file is empty');
      }

      // Show initial progress
      setState(() {
        _uploadProgress = 0.1;
      });

      final result = await CloudinaryUploadService.uploadCV(
        file: _selectedFile!,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      // Validate upload result
      if (result.secureUrl.isEmpty) {
        throw Exception('Upload completed but no URL returned');
      }

      setState(() {
        _uploadedCvUrl = result.secureUrl;
        _uploadCompleted = true;
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('CV uploaded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadError = _getFriendlyErrorMessage(e.toString());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Upload failed: ${_getFriendlyErrorMessage(e.toString())}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _uploadFile,
            ),
          ),
        );
      }
    }
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('size') || error.contains('10MB')) {
      return 'File is too large. Please select a file smaller than 10MB.';
    } else if (error.contains('type') || error.contains('format')) {
      return 'Invalid file format. Please select a PDF, DOC, or DOCX file.';
    } else if (error.contains('preset') || error.contains('configuration')) {
      return 'Upload service temporarily unavailable. Please try again later.';
    } else {
      return 'Upload failed. Please try again.';
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_uploadedCvUrl == null || !_uploadCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Please upload your CV first'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final expectedSalary = _expectedSalaryController.text.isNotEmpty
          ? int.tryParse(_expectedSalaryController.text.replaceAll(',', ''))
          : null;

      // Validate CV URL before submission
      if (_uploadedCvUrl!.isEmpty) {
        throw Exception('CV upload URL is invalid');
      }

      await ApplicationService.createApplication(
        jobId: widget.jobId,
        employerId: widget.employerId,
        cvUrl: _uploadedCvUrl!,
        coverLetter: _coverLetterController.text.isNotEmpty
            ? _coverLetterController.text
            : null,
        expectedSalary: expectedSalary,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Application submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_getFriendlyErrorMessage(
                        'Failed to submit application: $e'))),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitApplication,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apply for ${widget.jobTitle}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'at ${widget.companyName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Form Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      children: [
                        // CV Upload Section
                        _buildCVUploadSection(),

                        const SizedBox(height: 24),

                        // Expected Salary
                        TextFormField(
                          controller: _expectedSalaryController,
                          decoration: const InputDecoration(
                            labelText: 'Expected Salary (PKR)',
                            hintText: 'e.g., 150,000',
                            prefixText: 'PKR ',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final salary =
                                  int.tryParse(value.replaceAll(',', ''));
                              if (salary == null || salary <= 0) {
                                return 'Please enter a valid salary amount';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Cover Letter
                        TextFormField(
                          controller: _coverLetterController,
                          decoration: const InputDecoration(
                            labelText: 'Cover Letter (Optional)',
                            hintText:
                                'Tell the employer why you\'re perfect for this role...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          maxLength: 1000,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                Container(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _canSubmit() ? _submitApplication : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCVUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload CV *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your CV in PDF, DOC, or DOCX format (max 10MB)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 16),

        // Upload Button or File Info
        if (_selectedFile == null) ...[
          _buildUploadButton(),
        ] else ...[
          _buildFileInfo(),
        ],

        // Error Display
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _uploadError!,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload CV',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, DOC, DOCX up to 10MB',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    final fileName = _selectedFile!.path.split('/').last;
    final fileSize =
        CloudinaryUploadService.getFileSize(_selectedFile!.lengthSync());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _uploadCompleted ? Colors.green[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _uploadCompleted ? Icons.check_circle : Icons.description,
                  color:
                      _uploadCompleted ? Colors.green[600] : Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fileSize,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_uploadCompleted && !_isUploading)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                      _uploadedCvUrl = null;
                      _uploadError = null;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
            ],
          ),

          // Progress Indicator
          if (_isUploading) ...[
            const SizedBox(height: 12),
            Column(
              children: [
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uploading... ${(_uploadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],

          // Success Indicator
          if (_uploadCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Upload completed',
                  style: TextStyle(
                    color: Colors.green[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _uploadCompleted &&
        !_isUploading &&
        !_isSubmitting &&
        _uploadedCvUrl != null;
  }
}
