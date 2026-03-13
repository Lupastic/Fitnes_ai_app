// lib/screens/users_api_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart'; // Убедитесь, что это правильный путь к user_model.dart

// Если это отдельная страница для отображения пользователей из API
class UsersApiPage extends StatefulWidget { // Переименовал класс
  const UsersApiPage({super.key});

  @override
  State<UsersApiPage> createState() => _UsersApiPageState(); // Переименовал класс состояния
}

class _UsersApiPageState extends State<UsersApiPage> {
  List<User> _usersFromAPI = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsersFromAPI();
  }

  Future<void> _fetchUsersFromAPI() async {
    setState(() {
      _error = null; // Сбрасываем ошибку перед новой попыткой
    });
    try {
      final response = await http.get(Uri.parse('https://reqres.in/api/users?page=1')); // Добавил page=1

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic>? jsonData = responseData['data']; // 'data' может быть null

        if (jsonData != null) {
          final users = jsonData.map((e) => User.fromJson(e)).toList();
          setState(() {
            _usersFromAPI = users;
          });
        } else {
          throw Exception('API error: "data" field is missing or null.');
        }
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading users: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи API')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchUsersFromAPI,
              child: const Text('Загрузить пользователей из API'),
            ),
            const Divider(height: 40),
            const Text('Пользователи из API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_usersFromAPI.isEmpty)
              const CircularProgressIndicator() // Показываем индикатор загрузки
            else
              ..._usersFromAPI.map((user) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}