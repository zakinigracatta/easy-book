import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/business/business_image_picker.dart';
import '../../providers/owner_providers.dart';
import '../../models/staff_model.dart';

class AddEditEmployeeScreen extends ConsumerStatefulWidget {
  final StaffModel? initialStaff;

  const AddEditEmployeeScreen({super.key, this.initialStaff});

  @override
  ConsumerState<AddEditEmployeeScreen> createState() =>
      _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState
    extends ConsumerState<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _experienceController;
  late TextEditingController _avatarUrlController;

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final st = widget.initialStaff;
    _nameController = TextEditingController(text: st?.name ?? '');
    _roleController =
        TextEditingController(text: st?.roleTitle ?? 'Master Specialist');
    _experienceController = TextEditingController(
        text: st != null ? '${st.experienceYears}' : '5');
    _avatarUrlController = TextEditingController(text: st?.avatarUrl ?? '');
    _isActive = st?.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialStaff != null;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/employee-management');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/employee-management');
              }
            },
          ),
          title: Text(isEditing ? 'Edit Employee' : 'Add New Employee'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    label: 'Employee Full Name *',
                    prefixIcon: Icons.person_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter employee name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _roleController,
                    label: 'Job Title / Specialty *',
                    prefixIcon: Icons.badge_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter job title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    prefixIcon: Icons.workspace_premium_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  BusinessImagePicker(
                    label: 'Employee Avatar / Photo',
                    currentImageUrl: _avatarUrlController.text,
                    onPickImage: () {
                      _avatarUrlController.text =
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';
                      setState(() {});
                    },
                    onDeleteImage: () {
                      _avatarUrlController.clear();
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _isActive,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Active Status',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark),
                    ),
                    subtitle: const Text(
                      'Toggle off when employee is on extended leave or inactive.',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMutedDark),
                    ),
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: isEditing ? 'Update Employee' : 'Add Employee to Team',
                    isLoading: _isLoading,
                    onPressed: _saveEmployee,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final bizId = ref.read(currentBusinessIdProvider);
      final expYears = int.tryParse(_experienceController.text.trim()) ?? 5;

      final staff = StaffModel(
        id: widget.initialStaff?.id ??
            'st_${DateTime.now().millisecondsSinceEpoch}',
        businessId: bizId,
        name: _nameController.text.trim(),
        roleTitle: _roleController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
        rating: widget.initialStaff?.rating ?? 5.0,
        reviewCount: widget.initialStaff?.reviewCount ?? 0,
        experienceYears: expYears,
        isActive: _isActive,
      );

      await ref.read(ownerEmployeesProvider.notifier).saveEmployee(staff);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialStaff != null
                ? 'Employee updated!'
                : 'Employee added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/employee-management');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save employee: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
