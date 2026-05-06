import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/services/ai_service.dart';
import 'package:image_picker/image_picker.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final AIService _aiService = AIService();
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _messages = [
    {
      'isAi': true,
      'text': 'Assalamu Alaikum! I am Aafi, your health companion. How can I help you today?',
      'reasoning': null,
      'imagePath': null,
    }
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _messages.add({
        'isAi': false,
        'text': source == ImageSource.camera ? 'Uploaded a photo from camera.' : 'Uploaded a lab report.',
        'reasoning': null,
        'imagePath': image.path,
      });
      _isTyping = true;
    });

    _scrollToBottom();

    final aiResponse = await _aiService.analyzeLabReport(File(image.path));
    
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({
        'isAi': true,
        'text': aiResponse,
        'reasoning': 'Analyzed lab report using Gemini Vision model.',
        'imagePath': null,
      });
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({'isAi': false, 'text': userText, 'reasoning': null, 'imagePath': null});
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    final aiResponse = await _aiService.getCompletion(userText);
    
    String cleanResponse = aiResponse;
    String? reasoning;

    if (aiResponse.contains('Reasoning:')) {
      final parts = aiResponse.split('Reasoning:');
      cleanResponse = parts[0].trim();
      reasoning = parts[1].trim();
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({
        'isAi': true,
        'text': cleanResponse,
        'reasoning': reasoning ?? 'Analyzed query based on general health patterns.',
        'imagePath': null,
      });
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aafi AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildSuggestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isAi = msg['isAi'];
    final String? imagePath = msg['imagePath'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isAi)
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    if (imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath),
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 18,
                      borderColor: isAi ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                      child: Text(
                        msg['text'],
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isAi ? AppColors.textPrimary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAi && msg['reasoning'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: _ReasoningExpansion(reasoning: msg['reasoning']),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: 18,
            child: Row(
              children: List.generate(3, (i) => _TypingDot(index: i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      {'label': 'Analyze Lab Report', 'icon': Icons.description_outlined},
      {'label': 'Hydration Tips', 'icon': Icons.water_drop_outlined},
      {'label': 'Pill Safety', 'icon': Icons.medical_services_outlined},
    ];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(suggestions[index]['icon'] as IconData, size: 16, color: AppColors.primary),
              label: Text(suggestions[index]['label'] as String, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.surface,
              side: BorderSide(color: AppColors.glassBorder),
              onPressed: () {
                if (suggestions[index]['label'] == 'Analyze Lab Report') {
                  _showImageSourceActionSheet();
                } else {
                  _controller.text = suggestions[index]['label'] as String;
                  _sendMessage();
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndAnalyzeImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndAnalyzeImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
            onPressed: _showImageSourceActionSheet,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Ask Aafi anything...',
                hintStyle: AppTextStyles.bodyMedium,
                fillColor: AppColors.surface.withOpacity(0.5),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.background),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasoningExpansion extends StatefulWidget {
  final String reasoning;
  const _ReasoningExpansion({required this.reasoning});

  @override
  State<_ReasoningExpansion> createState() => _ReasoningExpansionState();
}

class _ReasoningExpansionState extends State<_ReasoningExpansion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'View AI Reasoning',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.underline),
              ),
              Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: AppColors.textSecondary),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 12,
                child: Text(
                  widget.reasoning,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int index;
  const _TypingDot({required this.index});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textSecondary.withOpacity(0.3 + (0.7 * _controller.value)),
          ),
        );
      },
    );
  }
}
