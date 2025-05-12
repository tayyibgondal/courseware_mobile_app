import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get a stream of all courses
  Stream<List<Course>> getCourses() {
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList());
  }

  // Get courses by category
  Stream<List<Course>> getCoursesByCategory(String category) {
    if (category == 'All') {
      return getCourses();
    }
    
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList());
  }

  // Get courses by user
  Stream<List<Course>> getMyCourses() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('courses')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList());
  }

  // Get a single course by ID
  Future<Course?> getCourse(String courseId) async {
    final doc = await _firestore.collection('courses').doc(courseId).get();
    if (!doc.exists) {
      return null;
    }
    return Course.fromFirestore(doc);
  }

  // Add a new course
  Future<String> addCourse(Course course) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Use a regular timestamp instead of serverTimestamp
      // This ensures the createdAt field is set immediately
      final timestamp = Timestamp.now();
      
      // Create a new document with the course data
      final docRef = await _firestore.collection('courses').add({
        ...course.toFirestore(),
        'authorId': userId,
        'createdAt': timestamp,
        'isPublished': true,
      });
      
      // Return the ID of the newly created document
      return docRef.id;
    } catch (e) {
      print('Error adding course: $e');
      throw Exception('Failed to add course: $e');
    }
  }

  // Update an existing course
  Future<void> updateCourse(Course course) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Check if the user is the author of the course
    final doc = await _firestore.collection('courses').doc(course.id).get();
    if (!doc.exists) {
      throw Exception('Course not found');
    }
    
    final data = doc.data() as Map<String, dynamic>;
    if (data['authorId'] != userId) {
      throw Exception('You do not have permission to edit this course');
    }
    
    await _firestore.collection('courses').doc(course.id).update(course.toFirestore());
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Check if the user is the author of the course
    final doc = await _firestore.collection('courses').doc(courseId).get();
    if (!doc.exists) {
      throw Exception('Course not found');
    }
    
    final data = doc.data() as Map<String, dynamic>;
    if (data['authorId'] != userId) {
      throw Exception('You do not have permission to delete this course');
    }
    
    await _firestore.collection('courses').doc(courseId).delete();
  }

  // Search courses by title or description
  Future<List<Course>> searchCourses(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    // Search in title
    final titleSnapshot = await _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    // Search in description
    final descriptionSnapshot = await _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .where('description', isGreaterThanOrEqualTo: query)
        .where('description', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    // Combine results and remove duplicates
    final courses = <Course>[];
    final courseIds = <String>{};
    
    for (final doc in titleSnapshot.docs) {
      if (!courseIds.contains(doc.id)) {
        courses.add(Course.fromFirestore(doc));
        courseIds.add(doc.id);
      }
    }
    
    for (final doc in descriptionSnapshot.docs) {
      if (!courseIds.contains(doc.id)) {
        courses.add(Course.fromFirestore(doc));
        courseIds.add(doc.id);
      }
    }
    
    return courses;
  }
} 