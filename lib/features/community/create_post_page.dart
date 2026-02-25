import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_app_bar.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String? selectedCourse;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> courses = [
    'Credit Mastery',
    'Business 101',
    'Smart Decisions',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(title: 'Create a post', showBackButton: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Title *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hintText: "What's your question or topic?",
                ),
                const SizedBox(height: 24),
                _buildInputLabel('Course Name *'),
                const SizedBox(height: 8),
                _buildDropdownField(),
                const SizedBox(height: 24),
                _buildInputLabel('Description *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _descController,
                  hintText: 'Provide more details...',
                  maxLines: 6,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit action
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE09F3E), // Gold
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF34495E),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCourse,
          isExpanded: true,
          dropdownColor: const Color(0xFF5A5A5A), // Dark grey background
          borderRadius: BorderRadius.circular(8),
          hint: Text(
            'Select Course Name',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500),
          // Custom builder for the selected item (when dropdown is closed)
          selectedItemBuilder: (BuildContext context) {
            return courses.map<Widget>((String item) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 15,
                  ),
                ),
              );
            }).toList();
          },
          items: courses.map((String value) {
            bool isSelected = selectedCourse == value;
            return DropdownMenuItem<String>(
              value: value,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF869277)
                      : Colors.transparent, // Sage highlight
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedCourse = newValue;
            });
          },
        ),
      ),
    );
  }
}
