import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text(
              'Open Courseware',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Open Courseware',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFeaturedSection(context),
                  const SizedBox(height: 24),
                  _buildQuickAccessSection(context),
                  const SizedBox(height: 24),
                  _buildRecentCoursesSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Content',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFeaturedCard(
                context,
                'Computer Science',
                'Introduction to Programming',
                Icons.computer,
              ),
              _buildFeaturedCard(
                context,
                'Mathematics',
                'Calculus I',
                Icons.functions,
              ),
              _buildFeaturedCard(
                context,
                'Physics',
                'Classical Mechanics',
                Icons.science,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    String subject,
    String title,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 16),
            Text(
              subject,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildQuickAccessCard(
              context,
              'AI Tutor',
              Icons.smart_toy,
              Colors.blue,
            ),
            _buildQuickAccessCard(
              context,
              'Library',
              Icons.library_books,
              Colors.green,
            ),
            _buildQuickAccessCard(
              context,
              'Learning Paths',
              Icons.timeline,
              Colors.orange,
            ),
            _buildQuickAccessCard(
              context,
              'Donate',
              Icons.favorite,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate based on the card title
          if (title == 'AI Tutor') {
            // Navigate to AI Tutor (index 2 in the bottom navigation)
            _navigateToIndex(context, 2);
          } else if (title == 'Library') {
            // TODO: Implement library navigation
          } else if (title == 'Learning Paths') {
            // TODO: Implement learning paths navigation
          } else if (title == 'Donate') {
            // TODO: Implement donate navigation
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to navigate to a specific bottom navigation index
  void _navigateToIndex(BuildContext context, int index) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false, arguments: index);
  }

  Widget _buildRecentCoursesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Courses',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.school),
                ),
                title: Text(
                  'Course ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Continue learning',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement course navigation
                },
              ),
            );
          },
        ),
      ],
    );
  }
} 