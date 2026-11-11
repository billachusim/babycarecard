import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/child.dart';
import '../../../data/models/care_entities.dart';
import '../../../data/repositories/providers.dart';
import '../../home/presentation/home_providers.dart';
import '../../../core/theme/app_theme.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final String _childId = const Uuid().v4();

  // Basic Info
  final _nameController = TextEditingController();
  String _ageGroup = 'Infant';
  final _allergiesController = TextEditingController();
  final _personalityController = TextEditingController();

  // Feeding (Simple for now, one entry)
  final _foodNameController = TextEditingController();
  final _foodAmountController = TextEditingController();
  final _foodTimeController = TextEditingController();

  // Routine
  final _napScheduleController = TextEditingController();
  final _sleepRoutineController = TextEditingController();

  // Emergency
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _allergiesController.dispose();
    _personalityController.dispose();
    _foodNameController.dispose();
    _foodAmountController.dispose();
    _foodTimeController.dispose();
    _napScheduleController.dispose();
    _sleepRoutineController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveChild();
    }
  }

  Future<void> _saveChild() async {
    if (_nameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your child's name")),
      );
      return;
    }

    final repository = ref.read(childRepositoryProvider);

    final child = Child(
      id: _childId,
      name: _nameController.text,
      ageGroup: _ageGroup,
      allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
      personality: _personalityController.text.isEmpty ? null : _personalityController.text,
    );

    await repository.insertChild(child);

    if (_foodNameController.text.isNotEmpty) {
      await repository.insertFeedingSchedule(FeedingSchedule(
        id: const Uuid().v4(),
        childId: _childId,
        name: 'Daily feeding',
        time: _foodTimeController.text.isEmpty ? 'Scheduled' : _foodTimeController.text,
        amount: _foodAmountController.text.isEmpty ? 'Normal' : _foodAmountController.text,
        instructions: _foodNameController.text,
      ));
    }

    if (_napScheduleController.text.isNotEmpty) {
      await repository.insertCareRoutine(CareRoutine(
        id: const Uuid().v4(),
        childId: _childId,
        title: 'Naps',
        instructions: _napScheduleController.text,
      ));
    }

    if (_sleepRoutineController.text.isNotEmpty) {
      await repository.insertCareRoutine(CareRoutine(
        id: const Uuid().v4(),
        childId: _childId,
        title: 'Bedtime',
        instructions: _sleepRoutineController.text,
      ));
    }

    if (_emergencyNameController.text.isNotEmpty) {
      await repository.insertEmergencyContact(EmergencyContact(
        id: const Uuid().v4(),
        childId: _childId,
        name: _emergencyNameController.text,
        phone: _emergencyPhoneController.text,
      ));
    }

    await ref.read(childrenListProvider.notifier).loadChildren();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 5'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey.shade200,
            color: AppTheme.primaryColor,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildBasicInfo(),
                _buildFeeding(),
                _buildRoutine(),
                _buildEmergency(),
                _buildSummary(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == 4 ? 'Complete' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text("Child's name *"),
          const SizedBox(height: 8),
          TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'e.g. Mia')),
          const SizedBox(height: 24),
          const Text('Age group'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _ageGroup,
            decoration: const InputDecoration(),
            items: const ['Newborn', 'Infant', 'Toddler', 'Preschooler', 'School age', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _ageGroup = v!),
          ),
          const SizedBox(height: 24),
          const Text('Allergies (optional)'),
          const SizedBox(height: 8),
          TextField(controller: _allergiesController, decoration: const InputDecoration(hintText: 'e.g. Peanuts, penicillin')),
          const SizedBox(height: 24),
          const Text('Personality'),
          const SizedBox(height: 8),
          TextField(
            controller: _personalityController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'e.g. Cheerful, shy with new people at first'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeding() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Feeding Instructions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tell the caregiver what, how much and when to feed.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          const Text('Food, formula or milk'),
          const SizedBox(height: 8),
          TextField(controller: _foodNameController, decoration: const InputDecoration(hintText: 'e.g. Formula, expressed breast milk, purées')),
          const SizedBox(height: 24),
          const Text('Amount'),
          const SizedBox(height: 8),
          TextField(controller: _foodAmountController, decoration: const InputDecoration(hintText: 'e.g. 6 oz bottle')),
          const SizedBox(height: 24),
          const Text('Times'),
          const SizedBox(height: 8),
          TextField(controller: _foodTimeController, decoration: const InputDecoration(hintText: 'e.g. 7am, noon and 6pm')),
        ],
      ),
    );
  }

  Widget _buildRoutine() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Routine', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Describe naps, bedtime and anything that helps them settle.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          const Text('Naps'),
          const SizedBox(height: 8),
          TextField(
            controller: _napScheduleController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'e.g. Nap 1–3pm in the cot with the sound machine on'),
          ),
          const SizedBox(height: 24),
          const Text('Bedtime routine'),
          const SizedBox(height: 8),
          TextField(
            controller: _sleepRoutineController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'e.g. Bath at 6:30, bottle, story, lights out by 7:30'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergency() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Emergency Info', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('Emergency Contact Name'),
          const SizedBox(height: 8),
          TextField(controller: _emergencyNameController, decoration: const InputDecoration(hintText: 'e.g. Jane Doe')),
          const SizedBox(height: 24),
          const Text('Phone Number'),
          const SizedBox(height: 8),
          TextField(controller: _emergencyPhoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'e.g. +1 234 567 890')),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 100, color: AppTheme.secondaryColor),
            const SizedBox(height: 32),
            const Text('Almost Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'We have all the basic info needed to create your child\'s care card. You can add more details later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
