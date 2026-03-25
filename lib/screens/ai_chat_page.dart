import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../providers/summary_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/connectivity_provider.dart';
import '../services/local_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text': 'Hello! I am your AI Health Assistant. I have access to your goals, history, and body metrics. How can I help you?'
    });
  }

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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final loc = AppLocalizations.of(context)!;
    final isOffline = context.read<ConnectivityProvider>().isOffline;

    if (isOffline) {
      setState(() {
        _messages.add({'role': 'user', 'text': text});
        _messages.add({'role': 'ai', 'text': loc.noInternet});
        _controller.clear();
      });
      _scrollToBottom();
      return;
    }

    final summaryProv = context.read<SummaryProvider>();
    final settings = context.read<SettingsProvider>();
    final localRepo = context.read<LocalRepository>();

    // 1. Получаем историю за последние 7 дней
    final history = localRepo.getLastDays(7);
    String historyText = history.map((s) => 
      "Date: ${s.date.toIso8601String().split('T')[0]}, Steps: ${s.steps}, Water: ${s.waterCups}, Sleep: ${s.sleepHours}, Calories: ${s.calories}"
    ).join("\n");

    // 2. Получаем цели и метрики тела пользователя
    final goals = settings.goals;
    String goalsText = goals.entries.map((e) => "${e.key}: ${e.value}").join(", ");
    
    // Формируем расширенный контекст с данными онбординга
    final bodyContext = """
    User Profile:
    - Name: ${settings.name}
    - Age: ${settings.age ?? 'Not specified'}
    - Weight: ${settings.weight ?? 'Not specified'} ${settings.weightUnit ?? 'kg'}
    - Height: ${settings.height ?? 'Not specified'} ${settings.heightUnit ?? 'cm'}
    - Primary Goal: ${settings.goalType ?? 'Not specified'}
    - Daily Targets: $goalsText
    """;

    // 3. Формируем итоговый промпт
    final contextPrompt = """
    $bodyContext
    
    Recent History (Last 7 days):
    $historyText
    
    Current Stats for Today:
    - Steps: ${summaryProv.today.steps}
    - Water: ${summaryProv.today.waterCups} cups
    - Sleep: ${summaryProv.today.sleepHours} hours
    - Calories: ${summaryProv.today.calories} kcal
    
    User message: $text
    
    Please provide professional health advice based on ALL the data above. If the user asks about their progress or today's norms, use the 'Current Stats for Today' and 'Daily Targets' provided above. Be concise, motivating, and speak in the language of the user's message.
    """;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final responseText = await _geminiService.getResponse(contextPrompt);
      setState(() {
        _messages.add({'role': 'ai', 'text': responseText});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': 'Error: $e'});
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Health Assistant", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Colors.tealAccent.withOpacity(0.8) 
                          : (isDark ? Colors.white10 : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.black : (isDark ? Colors.white : Colors.black87),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask about your progress...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: Colors.tealAccent,
                  child: const Icon(Icons.send_rounded, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
