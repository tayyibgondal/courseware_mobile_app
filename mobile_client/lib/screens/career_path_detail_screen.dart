import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/career_path_provider.dart';
import '../providers/course_provider.dart';
import '../providers/auth_provider.dart';
import '../models/career_path.dart';
import 'course_detail_screen.dart';
import 'edit_career_path_screen.dart';

class CareerPathDetailScreen extends StatefulWidget {
  final String careerPathId;

  const CareerPathDetailScreen({super.key, required this.careerPathId});

  @override
  State<CareerPathDetailScreen> createState() => _CareerPathDetailScreenState();
}

class _CareerPathDetailScreenState extends State<CareerPathDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerPathProvider>(context, listen: false)
          .fetchCareerPathById(widget.careerPathId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Show confirmation dialog before deleting
  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Career Path'),
        content: const Text('Are you sure you want to delete this career path? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteCareerPath(id);
    }
  }

  // Delete the career path
  Future<void> _deleteCareerPath(String id) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await Provider.of<CareerPathProvider>(context, listen: false)
          .deleteCareerPath(id);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Career path deleted successfully')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
  
  // Navigate to edit screen
  void _editCareerPath(CareerPath careerPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCareerPathScreen(careerPath: careerPath),
      ),
    ).then((_) {
      // Refresh data when returning from edit screen
      if (mounted) {
        Provider.of<CareerPathProvider>(context, listen: false).fetchCareerPathById(widget.careerPathId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser != null;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Career Path Details'),
      ),
      body: Consumer<CareerPathProvider>(
        builder: (context, careerPathProvider, child) {
          if (careerPathProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (careerPathProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${careerPathProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      careerPathProvider
                          .fetchCareerPathById(widget.careerPathId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final careerPath = careerPathProvider.selectedCareerPath;
          if (careerPath == null) {
            return const Center(child: Text('Career path not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and image
                if (careerPath.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      careerPath.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.trending_up, size: 80),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  careerPath.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  careerPath.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 24),

                // Skills
                if (careerPath.skills.isNotEmpty) ...[
                  const Text(
                    'Required Skills',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: careerPath.skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recommended Courses
                if (careerPath.courses.isNotEmpty) ...[
                  const Text(
                    'Recommended Courses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: careerPath.courses.length,
                    itemBuilder: (context, index) {
                      final courseId = careerPath.courses[index];
                      return _buildCourseItem(courseId);
                    },
                  ),
                ],
                
                // Admin actions - only shown if user is logged in
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit button
                      ElevatedButton.icon(
                        onPressed: () => _editCareerPath(careerPath),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      // Delete button
                      ElevatedButton.icon(
                        onPressed: _isDeleting ? null : () => _confirmDelete(careerPath.id),
                        icon: _isDeleting 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseItem(String courseId) {
    // For now, we'll just show a placeholder
    // In a real app, we would fetch course details from the API
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.school),
          title: Text('Course $courseId'),
          subtitle: const Text('Click to view course details'),
          onTap: () {
            // In a real app, we would navigate to the course details screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Course $courseId details coming soon')),
            );
          },
        ),
      ),
    );
  }
}
