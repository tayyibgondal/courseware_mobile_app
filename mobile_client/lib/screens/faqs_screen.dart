import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/faq_provider.dart';
import '../providers/auth_provider.dart';
import '../models/faq.dart';
import 'add_faq_screen.dart';
import 'edit_faq_screen.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({super.key});

  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  Map<String, bool> _deletingFaqs = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFAQs();
      _animationController.forward();
    });
  }

  void _fetchFAQs() {
    Provider.of<FAQProvider>(context, listen: false).fetchFAQs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  // Show confirmation dialog before deleting
  Future<void> _confirmDelete(FAQ faq) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FAQ'),
        content: const Text('Are you sure you want to delete this FAQ? This action cannot be undone.'),
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
      _deleteFAQ(faq);
    }
  }

  // Delete the FAQ
  Future<void> _deleteFAQ(FAQ faq) async {
    setState(() {
      _deletingFaqs[faq.id] = true;
    });

    try {
      final success = await Provider.of<FAQProvider>(context, listen: false)
          .deleteFAQ(faq.id);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('FAQ deleted successfully')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _deletingFaqs[faq.id] = false;
        });
      }
    }
  }
  
  // Navigate to edit screen
  void _editFAQ(FAQ faq) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFAQScreen(faq: faq),
      ),
    ).then((_) => _fetchFAQs());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.currentUser != null;
    
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search FAQs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                ),
                onChanged: _performSearch,
              ),
            ),
            Expanded(
              child: Consumer<FAQProvider>(
                builder: (context, faqProvider, child) {
                  if (faqProvider.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading FAQs...'),
                        ],
                      ),
                    );
                  }

                  if (faqProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${faqProvider.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchFAQs,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final faqs = _searchQuery.isEmpty
                      ? faqProvider.faqs
                      : faqProvider.searchFAQs(_searchQuery);

                  if (faqs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.question_answer,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No FAQs found',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchFAQs,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: faqs.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final faq = faqs[index];
                      final delay = index * 0.1;
                      final isDeleting = _deletingFaqs[faq.id] ?? false;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 500 + (index * 100)),
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
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text(
                                  faq.question,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'General FAQ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.all(16),
                                children: [
                                  Text(
                                    faq.answer,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  
                                  // Admin actions
                                  if (isAdmin) ...[
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Edit button
                                        TextButton.icon(
                                          onPressed: () => _editFAQ(faq),
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          label: const Text('Edit', style: TextStyle(color: Colors.orange)),
                                        ),
                                        const SizedBox(width: 8),
                                        // Delete button
                                        TextButton.icon(
                                          onPressed: isDeleting ? null : () => _confirmDelete(faq),
                                          icon: isDeleting
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(Icons.delete, color: Colors.red),
                                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddFAQScreen(),
                ),
              ).then((_) =>
                  _fetchFAQs()); // Refresh FAQs after returning from add screen
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
