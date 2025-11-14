import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/auth/quick_login_user.dart';
import 'login_controller.dart';

class QuickLoginController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  static const String _storageKey = 'saved_login_users';
  static const int _maxUsers = 5;

  final savedUsers = <QuickLoginUser>[].obs;
  final currentIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedUsers();
    _setupIndexListener();
  }

  void _setupIndexListener() {
    ever(currentIndex, (_) => _syncToLoginController());
    ever(savedUsers, (_) => _syncToLoginController());
  }

  void _syncToLoginController() {
    try {
      final loginController = Get.find<LoginController>();
      final user = currentUser;

      if (user != null) {
        loginController.selectQuickUser(user.username);
      } else {
        loginController.clearQuickLogin();
      }
    } catch (e) {
      // LoginController 可能还未初始化
    }
  }

  void _loadSavedUsers() {
    final data = _storage.getString(_storageKey);
    if (data != null && data.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        final users = decoded
            .map((json) => QuickLoginUser.fromJson(json))
            .toList();
        savedUsers.value = users;
      } catch (e) {
        savedUsers.value = [];
      }
    } else {
      savedUsers.value = [];
    }
  }

  Future<void> addUser(String username, String? name) async {
    if (username.isEmpty) return;

    final displayName = name ?? username;
    final users = List<QuickLoginUser>.from(savedUsers);

    users.removeWhere((u) => u.username == username);
    users.insert(0, QuickLoginUser(username: username, name: displayName));

    if (users.length > _maxUsers) {
      users.removeRange(_maxUsers, users.length);
    }

    final jsonList = users.map((u) => u.toJson()).toList();
    await _storage.setString(_storageKey, jsonEncode(jsonList));
    savedUsers.value = users;
    currentIndex.value = 0;
  }

  Future<void> removeUser(int index) async {
    if (index < 0 || index >= savedUsers.length) return;

    final users = List<QuickLoginUser>.from(savedUsers);
    users.removeAt(index);

    final jsonList = users.map((u) => u.toJson()).toList();
    await _storage.setString(_storageKey, jsonEncode(jsonList));

    savedUsers.value = users;

    if (currentIndex.value >= savedUsers.length && savedUsers.isNotEmpty) {
      currentIndex.value = savedUsers.length - 1;
    }
    if (currentIndex.value >= savedUsers.length) {
      currentIndex.value = -1;
    }
  }

  int get totalCount => savedUsers.length + 1;

  void nextUser() {
    currentIndex.value = (currentIndex.value + 1) % totalCount;
  }

  void previousUser() {
    currentIndex.value = (currentIndex.value - 1 + totalCount) % totalCount;
  }

  void setCurrentIndex(int index) {
    if (index >= -1 && index < savedUsers.length) {
      currentIndex.value = index;
    }
  }

  QuickLoginUser? get currentUser {
    if (currentIndex.value < 0 || currentIndex.value >= savedUsers.length) {
      return null;
    }
    return savedUsers[currentIndex.value];
  }

  /// 重置快捷登录状态（用于退出登录时）
  void reset() {
    currentIndex.value = -1;
  }
}
