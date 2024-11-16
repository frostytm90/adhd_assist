import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  TaskCategory _selectedCategory = TaskCategory.daily;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;
  bool _isRecurring = false;
  Recurrence? _selectedRecurrence;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.medium;
  bool _showAdvancedOptions = false;
  bool _showTemplates = true;
  late AnimationController _confettiController;
  late Animation<double> _confettiAnimation;

  int get _currentStep {
    if (_titleController.text.isEmpty) return 0;
    if (_selectedDate == null) return 1;
    return 2;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Task templates
  final List<TaskTemplate> _templates = [
    TaskTemplate(
      icon: Icons.calendar_today,
      name: 'Daily Routine',
      emoji: '📅',
      priority: TaskPriority.medium,
      category: TaskCategory.daily,
    ),
    TaskTemplate(
      icon: Icons.star,
      name: 'Important',
      emoji: '⭐',
      priority: TaskPriority.high,
      category: TaskCategory.important,
    ),
    TaskTemplate(
      icon: Icons.flag,
      name: 'Goal',
      emoji: '🎯',
      priority: TaskPriority.medium,
      category: TaskCategory.goals,
    ),
  ];

  void _applyTemplate(TaskTemplate template) {
    setState(() {
      _titleController.text = template.name;
      _selectedCategory = template.category;
      _selectedPriority = template.priority;
      _showTemplates = false;
    });
    HapticFeedback.lightImpact();
  }

  void _updatePriority(TaskPriority priority) {
    setState(() => _selectedPriority = priority);
    HapticFeedback.selectionClick();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      // Start confetti animation
      _confettiController.forward(from: 0.0);
      
      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDate,
        recurrence: _isRecurring ? _selectedRecurrence : null,
        difficulty: _selectedDifficulty,
      );

      // Short delay for animation
      await Future.delayed(const Duration(milliseconds: 500));
      
      widget.onTaskAdded(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProgressDot(isActive: _currentStep >= 0),
                          const SizedBox(width: 8),
                          _ProgressDot(isActive: _currentStep >= 1),
                          const SizedBox(width: 8),
                          _ProgressDot(isActive: _currentStep >= 2),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_showTemplates) ...[
                        Text(
                          'Quick Start',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _templates.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final template = _templates[index];
                              return _TemplateCard(
                                template: template,
                                onTap: () => _applyTemplate(template),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'What do you need to do?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          if (_showTemplates) {
                            setState(() => _showTemplates = false);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority Selection with XP Preview
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PriorityButton(
                                  label: '!',
                                  isSelected: _selectedPriority == TaskPriority.low,
                                  onTap: () => _updatePriority(TaskPriority.low),
                                  color: Colors.green,
                                  xp: '+10 XP',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PriorityButton(
                                  label: '!!',
                                  isSelected: _selectedPriority == TaskPriority.medium,
                                  onTap: () => _updatePriority(TaskPriority.medium),
                                  color: Colors.orange,
                                  xp: '+20 XP',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _PriorityButton(
                                  label: '!!!',
                                  isSelected: _selectedPriority == TaskPriority.high,
                                  onTap: () => _updatePriority(TaskPriority.high),
                                  color: Colors.red,
                                  xp: '+30 XP',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Due Date Selection
                      Wrap(
                        spacing: 8,
                        children: [
                          _DateChip(
                            label: 'Today',
                            isSelected: _selectedDate?.day == DateTime.now().day,
                            onTap: () {
                              setState(() => _selectedDate = DateTime.now());
                              HapticFeedback.selectionClick();
                            },
                          ),
                          _DateChip(
                            label: 'Tomorrow',
                            isSelected: _selectedDate?.day == DateTime.now().add(const Duration(days: 1)).day,
                            onTap: () {
                              setState(() => _selectedDate = DateTime.now().add(const Duration(days: 1)));
                              HapticFeedback.selectionClick();
                            },
                          ),
                          _DateChip(
                            label: 'Pick Date',
                            isSelected: _selectedDate != null && 
                                      _selectedDate!.day != DateTime.now().day && 
                                      _selectedDate!.day != DateTime.now().add(const Duration(days: 1)).day,
                            onTap: () {
                              _pickDate();
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Advanced Options
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showAdvancedOptions = !_showAdvancedOptions);
                          HapticFeedback.selectionClick();
                        },
                        icon: Icon(_showAdvancedOptions ? Icons.expand_less : Icons.expand_more),
                        label: Text(_showAdvancedOptions ? 'Less Options' : 'More Options'),
                      ),

                      if (_showAdvancedOptions) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Add details (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('Repeat this task?'),
                                value: _isRecurring,
                                onChanged: (value) {
                                  setState(() {
                                    _isRecurring = value;
                                    if (!value) _selectedRecurrence = null;
                                  });
                                  HapticFeedback.selectionClick();
                                },
                              ),
                              if (_isRecurring)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildRecurrenceDropdown(),
                                ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            HapticFeedback.mediumImpact();
                            _saveTask();
                          }
                        },
                        icon: const Icon(Icons.add_task),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Add Task'),
                            const SizedBox(width: 8),
                            Text(
                              '+${_selectedPriority == TaskPriority.low ? 10 : _selectedPriority == TaskPriority.medium ? 20 : 30} XP',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Confetti Animation Overlay
            if (_confettiController.isAnimating)
              Positioned.fill(
                child: FadeTransition(
                  opacity: _confettiAnimation,
                  child: const _ConfettiOverlay(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<TaskCategory>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.category),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedCategory,
      items: TaskCategory.values.map((TaskCategory category) {
        return DropdownMenuItem<TaskCategory>(
          value: category,
          child: Text(
            category.toString().split('.').last,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    );
  }

  Widget _buildRecurrenceDropdown() {
    return DropdownButtonFormField<Recurrence>(
      decoration: InputDecoration(
        labelText: 'Recurrence',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.update),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _selectedRecurrence,
      items: Recurrence.values.map((Recurrence recurrence) {
        return DropdownMenuItem<Recurrence>(
          value: recurrence,
          child: Text(
            recurrence.toString().split('.').last,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedRecurrence = newValue;
        });
      },
      validator: (value) {
        if (_isRecurring && value == null) {
          return 'Please select recurrence';
        }
        return null;
      },
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool isActive;

  const _ProgressDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
      ),
    );
  }
}

class _ConfettiOverlay extends StatelessWidget {
  const _ConfettiOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConfettiPainter(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = Random();
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final color = colors[random.nextInt(colors.length)];
      paint.color = color;

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 4 + 1,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}

class TaskTemplate {
  final IconData icon;
  final String name;
  final String emoji;
  final TaskPriority priority;
  final TaskCategory category;

  TaskTemplate({
    required this.icon,
    required this.name,
    required this.emoji,
    required this.priority,
    required this.category,
  });
}

class _TemplateCard extends StatelessWidget {
  final TaskTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(template.icon, size: 24),
              const SizedBox(height: 4),
              Text(
                template.name,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                template.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final String xp;

  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                xp,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
        ),
      ),
      backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
      onPressed: onTap,
    );
  }
}
