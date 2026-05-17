import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../core/theme/app_theme.dart';
import '../models/job_model.dart';
import '../providers/app_state.dart';
import '../widgets/glass_card.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _payController = TextEditingController();
  final _addressController = TextEditingController();
  final _tagsController = TextEditingController();

  JobCategory _selectedCategory = JobCategory.other;
  String _payUnit = 'fixed';
  int _workersNeeded = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _durationController = TextEditingController(text: '120');
  JobType _jobType = JobType.oneTime;
  bool _isSubmitting = false;
  double? _detectedLat;
  double? _detectedLng;
  bool _detectingLocation = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _payController.dispose();
    _addressController.dispose();
    _tagsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // Background — flat
          Container(color: const Color(0xFF050505)),

          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(6),
                        borderRadius: 12,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Create Gig',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Tiny hint badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 12, color: AppColors.accentCyan.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              'Post',
                              style: TextStyle(
                                color: AppColors.accentCyan.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // Description text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Fill in the details to find the best talent in your local area. Highly specific descriptions attract better results.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 50.ms, duration: 400.ms),
                const SizedBox(height: 8),

                // Form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 8),

                        // Category selector
                        _buildSectionLabel('Category', Icons.category_rounded),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: JobCategory.values.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final cat = JobCategory.values[index];
                              final isSelected = cat == _selectedCategory;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cat.color.withValues(alpha: 0.15)
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? cat.color : AppColors.divider,
                                      width: isSelected ? 1.5 : 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        cat.icon,
                                        color: isSelected ? cat.color : AppColors.textMuted,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cat.label,
                                        style: TextStyle(
                                          color: isSelected ? cat.color : AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Title
                        _buildSectionLabel('Job Title', Icons.title_rounded),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: 'e.g., Math Tutor for Class 10',
                          validator: (v) => v == null || v.trim().length < 5 ? 'Min 5 characters required' : null,
                        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Description
                        _buildSectionLabel('Description', Icons.description_rounded),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descController,
                          hint: 'Describe the job in detail...',
                          maxLines: 4,
                          validator: (v) => v == null || v.trim().length < 10 ? 'Min 10 characters required' : null,
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Pay
                        _buildSectionLabel('Pay Rate', Icons.currency_rupee_rounded),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _payController,
                                hint: '₹ Amount',
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Required';
                                  final amount = int.tryParse(v.trim());
                                  if (amount == null || amount <= 0) return 'Must be a positive integer';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _payUnit,
                                    isExpanded: true,
                                    dropdownColor: AppColors.cardBg,
                                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                    items: ['fixed', 'per hour', 'per day'].map((unit) {
                                      return DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setState(() => _payUnit = v!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Date, Time, Duration
                        _buildSectionLabel('Schedule', Icons.schedule_rounded),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                onTap: () => _pickDate(),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: AppColors.accentCyan),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassCard(
                                onTap: () => _pickTime(),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: AppColors.accentPurple),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
                                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                        const SizedBox(height: 12),

                        // Duration
                        _buildSectionLabel('Duration (mins)', Icons.timer_rounded),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _durationController,
                          hint: 'e.g., 120',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final mins = int.tryParse(v.trim());
                            if (mins == null || mins < 15 || mins > 480) return 'Must be 15-480 mins';
                            return null;
                          },
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Workers needed
                        _buildSectionLabel('Workers Needed', Icons.people_rounded),
                        const SizedBox(height: 8),
                        GlassCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_workersNeeded > 1) {
                                    setState(() => _workersNeeded--);
                                  }
                                },
                                icon: Icon(Icons.remove_circle_outline, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$_workersNeeded',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () => setState(() => _workersNeeded++),
                                icon: Icon(Icons.add_circle_outline, color: AppColors.accentCyan),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Location
                        _buildSectionLabel('Location', Icons.location_on_rounded),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _addressController,
                          hint: 'Enter address or use auto-detect',
                          suffixIcon: Icon(Icons.my_location_rounded, color: AppColors.accentCyan, size: 20),
                        ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _detectingLocation ? null : _autoDetectLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentCyan.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_detectingLocation)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accentCyan,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.accentCyan,
                                    size: 18,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _detectingLocation
                                      ? 'Detecting your location...'
                                      : _detectedLat != null
                                          ? '✓ Location detected'
                                          : 'Use Current Location',
                                  style: const TextStyle(
                                    color: AppColors.accentCyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 470.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Job type
                        _buildSectionLabel('Job Type', Icons.repeat_rounded),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeChip('One-time', JobType.oneTime),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeChip('Recurring', JobType.recurring),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                        const SizedBox(height: 20),

                        // Tags
                        _buildSectionLabel('Tags / Keywords', Icons.tag_rounded),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _tagsController,
                          hint: 'e.g., tutor, math, board exam',
                        ).animate().fadeIn(delay: 550.ms, duration: 400.ms),
                        const SizedBox(height: 30),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitJob,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentCyan,
                              foregroundColor: const Color(0xFF0A0A0A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryDark,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Post Live Gig',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                        const SizedBox(height: 12),
                        // Terms text
                        const Center(
                          child: Text(
                            'By posting, you agree to our Gig Service\nAgreement.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildTypeChip(String label, JobType type) {
    final isSelected = _jobType == type;
    return GestureDetector(
      onTap: () => setState(() => _jobType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentCyan.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : AppColors.divider,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accentCyan : AppColors.textMuted,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _autoDetectLocation() async {
    setState(() => _detectingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled. Please enable GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permission permanently denied. Enable in Settings.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _detectedLat = position.latitude;
        _detectedLng = position.longitude;
      });

      // Reverse geocode
      try {
        final placemarks = await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.subLocality?.isNotEmpty == true) parts.add(p.subLocality!);
          if (p.locality?.isNotEmpty == true) parts.add(p.locality!);
          if (p.subAdministrativeArea?.isNotEmpty == true) parts.add(p.subAdministrativeArea!);
          final address = parts.join(', ');
          setState(() {
            _addressController.text = address;
          });
        }
      } catch (_) {
        if (mounted) {
          _addressController.text = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        }
      }
    } catch (e) {
      _showLocationError('Failed to detect location. Try again.');
    } finally {
      if (mounted) setState(() => _detectingLocation = false);
    }
  }

  void _showLocationError(String msg) {
    if (mounted) {
      setState(() => _detectingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCyan,
              surface: AppColors.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentCyan,
              surface: AppColors.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      final state = context.read<AppState>();
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final job = GigJob(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        payRate: double.tryParse(_payController.text) ?? 0,
        payUnit: _payUnit,
        duration: Duration(minutes: int.tryParse(_durationController.text) ?? 120),
        dateTime: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        latitude: _detectedLat ?? 19.2183,
        longitude: _detectedLng ?? 72.9781,
        address: _addressController.text,
        category: _selectedCategory,
        type: _jobType,
        workersNeeded: _workersNeeded,
        tags: tags,
        posterId: state.currentUser.id,
        posterName: state.currentUser.name,
        posterRating: state.currentUser.rating,
        createdAt: DateTime.now(),
      );

      state.addJob(job);

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.accentGreen),
              const SizedBox(width: 8),
              const Text('Gig posted successfully!'),
            ],
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    });
  }
}
