import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_tutor_provider.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<AITutorProvider>().clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Consumer<AITutorProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      children: [
                        Switch(
                          value: provider.showSources,
                          onChanged: (val) => provider.setShowSources(val),
                        ),
                        const Text('Show related sources'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AITutorProvider>(
              builder: (context, provider, child) {
                final streamingText = context.watch<AITutorProvider>().streamingText;
                final messages = provider.messages;
                final itemCount = streamingText != null ? messages.length + 1 : messages.length;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Ask anything from your AI Tutor!',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (streamingText != null && index == itemCount - 1) {
                      // Show the streaming/typing AI message
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Linkify(
                            onOpen: (link) async {
                              final url = Uri.parse(link.url);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            text: streamingText.isEmpty ? 'AI is typing...' : streamingText,
                            style: const TextStyle(color: Colors.black),
                            linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            options: const LinkifyOptions(humanize: false),
                          ),
                        ),
                      );
                    }
                    final message = messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: message.isUser
                            ? Text(
                                message.text,
                                style: const TextStyle(color: Colors.white),
                              )
                            : Linkify(
                                onOpen: (link) async {
                                  final url = Uri.parse(link.url);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                                text: message.text,
                                style: const TextStyle(color: Colors.black),
                                linkStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                options: const LinkifyOptions(humanize: false),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your question...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<AITutorProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(),
                            )
                          : const Icon(Icons.send),
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              if (_messageController.text.trim().isNotEmpty) {
                                provider.sendMessage(_messageController.text);
                                _messageController.clear();
                                _scrollToBottom();
                              }
                            },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 