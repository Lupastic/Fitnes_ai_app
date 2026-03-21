import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data_service.dart';
import 'navigation_wrapper.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String _selectedGoal = 'Lose Weight';
  bool _isLoading = false;

  Future<void> _saveData() async {
    if (_weightController.text.isEmpty || _heightController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = context.read<UserDataService>();
      await service.updateProfileData(
        weight: double.tryParse(_weightController.text),
        weightUnit: _weightUnit,
        height: double.tryParse(_heightController.text),
        heightUnit: _heightUnit,
        age: int.tryParse(_ageController.text),
        goalType: _selectedGoal,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationWrapper()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tell us about yourself", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("This helps us personalize your experience", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // WEIGHT
              _buildInputCard(
                "Weight",
                _weightController,
                _weightUnit,
                ['kg', 'lbs'],
                (val) => setState(() => _weightUnit = val),
              ),
              const SizedBox(height: 20),

              // HEIGHT
              _buildInputCard(
                "Height",
                _heightController,
                _heightUnit,
                ['cm', 'inch'],
                (val) => setState(() => _heightUnit = val),
              ),
              const SizedBox(height: 20),

              // AGE
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              // GOAL
              const Text("Your Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildGoalOption('Lose Weight', Icons.trending_down),
              _buildGoalOption('Gain Weight', Icons.trending_up),
              _buildGoalOption('Get Fit', Icons.fitness_center),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finish", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller, String currentUnit, List<String> units, Function(String) onUnitChanged) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        ToggleButtons(
          isSelected: units.map((u) => u == currentUnit).toList(),
          onPressed: (index) => onUnitChanged(units[index]),
          borderRadius: BorderRadius.circular(15),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 55),
          children: units.map((u) => Text(u)).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalOption(String goal, IconData icon) {
    bool isSelected = _selectedGoal == goal;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.tealAccent.shade700.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.tealAccent.shade700 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.tealAccent.shade700 : Colors.grey),
            const SizedBox(width: 15),
            Text(goal, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: Colors.tealAccent.shade700),
          ],
        ),
      ),
    );
  }
}