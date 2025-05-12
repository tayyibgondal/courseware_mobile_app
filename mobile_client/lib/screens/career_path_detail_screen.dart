import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/career_path_provider.dart';
import '../providers/course_provider.dart';
import 'course_detail_screen.dart';

class CareerPathDetailScreen extends StatefulWidget {
  final String careerPathId;

  const CareerPathDetailScreen({super.key, required this.careerPathId});

  @override
  State<CareerPathDetailScreen> createState() => _CareerPathDetailScreenState();
}

class _CareerPathDetailScreenState extends State<CareerPathDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CareerPathProvider>(context, listen: false)
          .fetchCareerPathById(widget.careerPathId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      careerPathProvider.fetchCareerPathById(widget.careerPathId);
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
    return Card(
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
    );
  }
} 