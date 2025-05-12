import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import 'package:uuid/uuid.dart';

class DummyDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Check if dummy data already exists
  Future<bool> dummyDataExists() async {
    final snapshot = await _firestore.collection('courses').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  // Add dummy courses to Firestore
  Future<void> addDummyCourses() async {
    if (await dummyDataExists()) {
      print('Dummy data already exists, skipping initialization');
      return;
    }
    
    print('Adding dummy courses...');
    
    // Computer Science courses
    await _addDummyCourse(
      title: 'Introduction to Programming',
      description: 'Learn the fundamentals of programming using Python. This course covers variables, control structures, functions, and basic data structures.',
      instructor: 'Dr. Alan Turing',
      category: 'Computer Science',
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
      rating: 4.8,
      enrollmentCount: 1205,
    );
    
    await _addDummyCourse(
      title: 'Web Development Bootcamp',
      description: 'Comprehensive course on modern web development covering HTML, CSS, JavaScript, React, and Node.js. Build fully functional web applications.',
      instructor: 'Sarah Johnson',
      category: 'Computer Science',
      imageUrl: 'https://images.unsplash.com/photo-1547658719-da2b51169166',
      rating: 4.7,
      enrollmentCount: 980,
    );
    
    // Mathematics courses
    await _addDummyCourse(
      title: 'Calculus I',
      description: 'Introduction to differential and integral calculus. Topics include limits, derivatives, applications of differentiation, and basic integration techniques.',
      instructor: 'Prof. Isaac Newton',
      category: 'Mathematics',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb',
      rating: 4.5,
      enrollmentCount: 752,
    );
    
    await _addDummyCourse(
      title: 'Linear Algebra',
      description: 'Study of vectors, vector spaces, linear transformations, and matrices. Applications in computer graphics, data science, and physics.',
      instructor: 'Dr. Emmy Noether',
      category: 'Mathematics',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb',
      rating: 4.6,
      enrollmentCount: 630,
    );
    
    // Physics courses
    await _addDummyCourse(
      title: 'Classical Mechanics',
      description: 'Study of motion of bodies under the action of forces according to Newton\'s laws. Includes kinematics, dynamics, and conservation laws.',
      instructor: 'Dr. Richard Feynman',
      category: 'Physics',
      imageUrl: 'https://images.unsplash.com/photo-1636466497217-26a42372b686',
      rating: 4.9,
      enrollmentCount: 520,
    );
    
    await _addDummyCourse(
      title: 'Quantum Physics',
      description: 'Introduction to quantum mechanics. Topics include wave-particle duality, Schrödinger equation, and quantum states.',
      instructor: 'Prof. Marie Curie',
      category: 'Physics',
      imageUrl: 'https://images.unsplash.com/photo-1635002930836-1a593c3dbafb',
      rating: 4.7,
      enrollmentCount: 410,
    );
    
    // Engineering courses
    await _addDummyCourse(
      title: 'Introduction to Robotics',
      description: 'Learn the fundamentals of robotics including kinematics, dynamics, and control. Build simple robot models and program them.',
      instructor: 'Dr. Grace Hopper',
      category: 'Engineering',
      imageUrl: 'https://images.unsplash.com/photo-1535378620166-273708d44e4c',
      rating: 4.6,
      enrollmentCount: 780,
    );
    
    await _addDummyCourse(
      title: 'Electrical Circuit Analysis',
      description: 'Study of electrical circuits, components, and analysis techniques. Learn about Ohm\'s law, Kirchhoff\'s laws, and circuit theorems.',
      instructor: 'Prof. Nikola Tesla',
      category: 'Engineering',
      imageUrl: 'https://images.unsplash.com/photo-1623479322729-28b25c16b011',
      rating: 4.5,
      enrollmentCount: 620,
    );
    
    // Business courses
    await _addDummyCourse(
      title: 'Introduction to Marketing',
      description: 'Learn the fundamentals of marketing including market research, segmentation, targeting, and positioning. Develop effective marketing strategies.',
      instructor: 'Prof. Philip Kotler',
      category: 'Business',
      imageUrl: 'https://images.unsplash.com/photo-1520607162513-77705c0f0d4a',
      rating: 4.4,
      enrollmentCount: 910,
    );
    
    await _addDummyCourse(
      title: 'Financial Management',
      description: 'Study of financial decision-making in corporations. Topics include capital budgeting, capital structure, dividend policy, and risk management.',
      instructor: 'Dr. Warren Buffett',
      category: 'Business',
      imageUrl: 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e',
      rating: 4.8,
      enrollmentCount: 840,
    );
    
    // Arts courses
    await _addDummyCourse(
      title: 'Introduction to Digital Photography',
      description: 'Learn the fundamentals of digital photography including composition, lighting, exposure, and post-processing techniques.',
      instructor: 'Ansel Adams',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32',
      rating: 4.7,
      enrollmentCount: 730,
    );
    
    await _addDummyCourse(
      title: 'Music Theory Fundamentals',
      description: 'Introduction to music theory including notation, scales, intervals, and chords. Develop skills in music reading and analysis.',
      instructor: 'Prof. Johann Bach',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d',
      rating: 4.6,
      enrollmentCount: 590,
    );
    
    print('Dummy courses added successfully');
  }
  
  // Helper method to add a single course
  Future<void> _addDummyCourse({
    required String title,
    required String description,
    required String instructor,
    required String category,
    required String imageUrl,
    required double rating,
    required int enrollmentCount,
  }) async {
    try {
      final timestamp = Timestamp.now();
      final id = const Uuid().v4();
      
      await _firestore.collection('courses').doc(id).set({
        'title': title,
        'description': description,
        'instructor': instructor,
        'category': category,
        'imageUrl': imageUrl,
        'rating': rating,
        'enrollmentCount': enrollmentCount,
        'createdAt': timestamp,
        'tags': [category.toLowerCase(), instructor.split(' ').last.toLowerCase()],
        'isPublished': true,
        'authorId': 'system',
      });
    } catch (e) {
      print('Error adding dummy course "$title": $e');
    }
  }
} 