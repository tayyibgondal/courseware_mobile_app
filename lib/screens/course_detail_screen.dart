import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../services/course_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService _courseService = CourseService();
  bool _isEnrolled = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.course.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: widget.course.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.course.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.blue[100],
                      child: Center(
                        child: Icon(
                          Icons.school,
                          size: 80,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.course.category),
                        backgroundColor: Colors.blue[100],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.course.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.course.enrollmentCount} students',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Instructor',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.course.instructor,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About this course',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'What you\'ll learn',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLearningPoints(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _toggleEnrollment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEnrolled ? Colors.red : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _isEnrolled ? 'Unenroll' : 'Enroll Now',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPoints() {
    // Dynamic learning points based on course category
    List<String> learningPoints = [];
    
    switch (widget.course.category) {
      case 'Computer Science':
        learningPoints = [
          'Understand core programming concepts and algorithms',
          'Apply theoretical knowledge to real-world coding projects',
          'Develop problem-solving skills through practical examples',
          'Build a portfolio of software applications',
        ];
        break;
      case 'Mathematics':
        learningPoints = [
          'Master mathematical concepts and theorems',
          'Apply mathematical reasoning to solve complex problems',
          'Develop abstract thinking and logical deduction skills',
          'Connect mathematical principles to real-world applications',
        ];
        break;
      case 'Physics':
        learningPoints = [
          'Understand fundamental physical laws and theories',
          'Develop skills in experimental design and data analysis',
          'Apply physics concepts to explain natural phenomena',
          'Solve complex physical problems through mathematical modeling',
        ];
        break;
      case 'Engineering':
        learningPoints = [
          'Apply engineering principles to design innovative solutions',
          'Develop technical skills in specialized engineering domains',
          'Learn project management and system integration',
          'Understand ethical considerations in engineering practice',
        ];
        break;
      case 'Business':
        learningPoints = [
          'Understand key business principles and strategies',
          'Develop analytical skills for business decision-making',
          'Learn effective communication and negotiation techniques',
          'Apply business theories to real-world case studies',
        ];
        break;
      case 'Arts':
        learningPoints = [
          'Develop creative expression and artistic techniques',
          'Understand historical and contemporary art movements',
          'Learn to analyze and critique artistic works',
          'Create a portfolio showcasing your artistic development',
        ];
        break;
      default:
        learningPoints = [
          'Understand the core concepts of the subject',
          'Apply theoretical knowledge to practical problems',
          'Develop critical thinking skills',
          'Complete hands-on projects to reinforce learning',
        ];
    }

    return Column(
      children: learningPoints.map((point) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  point,
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _toggleEnrollment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This is a placeholder for the actual enrollment logic
      // In a real app, you would call a service method here
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isEnrolled = !_isEnrolled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEnrolled ? 'Successfully enrolled!' : 'Successfully unenrolled'),
          backgroundColor: _isEnrolled ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 