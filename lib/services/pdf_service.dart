import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PDFService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Get the file bytes for web
      );

      if (result == null || result.files.isEmpty) return null;

      final PlatformFile file = result.files.single;
      final String fileName = file.name;
      final userId = _auth.currentUser?.uid;

      if (userId == null) throw Exception('User not authenticated');
      if (file.bytes == null) throw Exception('No file data available');

      // Reference to the file location in Firebase Storage
      final ref = _storage.ref().child('pdfs/$userId/$fileName');
      
      // Upload the bytes directly (works on both web and mobile)
      final uploadTask = ref.putData(file.bytes!);
      
      // Wait for the upload to complete
      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();

      // Save metadata to Firestore
      await _firestore.collection('users').doc(userId).collection('documents').add({
        'name': fileName,
        'url': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUploadedDocuments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'url': doc['url'],
                'uploadedAt': doc['uploadedAt'],
              })
          .toList();
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }
  
  Future<bool> deleteDocument(String documentId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;
      
      // Get the document to find the storage reference
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId);
          
      final doc = await docRef.get();
      if (!doc.exists) return false;
      
      // Delete from Firestore
      await docRef.delete();
      
      // Try to delete from Storage if possible
      try {
        if (doc.data()?['url'] != null) {
          final ref = _storage.refFromURL(doc.data()!['url']);
          await ref.delete();
        }
      } catch (e) {
        print('Error deleting file from storage: $e');
        // Continue even if storage deletion fails
      }
      
      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }
} 