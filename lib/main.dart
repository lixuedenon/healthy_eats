// lib/main.dart
// 应用入口文件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

import 'config/theme_config.dart';

import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ai_recommendation_service.dart';

import 'data/repositories/user_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/token_stats_repository.dart';

import 'presentation/viewmodels/user_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

import 'presentation/widgets/bottom_nav_bar.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/statistics_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final storageService = await StorageService.getInstance();

  await NotificationService.initialize();

  final userRepository = UserRepository(storageService);
  final mealRepository = MealRepository(storageService);
  final tokenStatsRepository = TokenStatsRepository(storageService);

  String initialLanguage = 'zh';
  try {
    final user = await storageService.getUserProfile();
    if (user != null && user.language.isNotEmpty) {
      initialLanguage = user.language;
    }
  } catch (e) {
    print('Failed to load user language preference: $e');
  }

  runApp(
    HealthyEatsApp(
      storageService: storageService,
      userRepository: userRepository,
      mealRepository: mealRepository,
      tokenStatsRepository: tokenStatsRepository,
      initialLanguage: initialLanguage,
    ),
  );
}

class HealthyEatsApp extends StatelessWidget {
  final StorageService storageService;
  final UserRepository userRepository;
  final MealRepository mealRepository;
  final TokenStatsRepository tokenStatsRepository;
  final String initialLanguage;

  const HealthyEatsApp({
    super.key,
    required this.storageService,
    required this.userRepository,
    required this.mealRepository,
    required this.tokenStatsRepository,
    required this.initialLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(userRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(userRepository, mealRepository),
        ),
      ],
      child: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          final currentLanguage = userViewModel.currentUser?.language ?? initialLanguage;

          return MaterialApp(
            title: 'Healthy Eats',

            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'),
              Locale('en'),
              Locale('ja'),
              Locale('ko'),
              Locale('fr'),
              Locale('de'),
              Locale('es'),
            ],
            locale: Locale(currentLanguage),

            home: AppInitializerPage(
              storageService: storageService,
              tokenStatsRepository: tokenStatsRepository,
            ),

            routes: {
              '/home': (context) => const MainNavigationScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/statistics': (context) => const StatisticsScreen(),
            },

            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppInitializerPage extends StatefulWidget {
  final StorageService storageService;
  final TokenStatsRepository tokenStatsRepository;

  const AppInitializerPage({
    super.key,
    required this.storageService,
    required this.tokenStatsRepository,
  });

  @override
  State<AppInitializerPage> createState() => _AppInitializerPageState();
}

class _AppInitializerPageState extends State<AppInitializerPage> {
  bool _isInitialized = false;
  String _statusMessage = '正在初始化...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      if (!widget.storageService.hasApiKey()) {
        setState(() {
          _statusMessage = '请输入API Key...';
        });

        final apiKey = await _showApiKeyInputDialog();
        if (apiKey == null || apiKey.isEmpty) {
          setState(() {
            _statusMessage = '未设置API Key，部分功能将不可用';
          });
          await Future.delayed(const Duration(seconds: 2));
        } else {
          await widget.storageService.saveApiKey(apiKey);
        }
      }

      setState(() {
        _statusMessage = '加载用户信息...';
      });

      final userViewModel = context.read<UserViewModel>();
      final homeViewModel = context.read<HomeViewModel>();

      await userViewModel.initialize();

      setState(() {
        _statusMessage = '加载餐食数据...';
      });

      await homeViewModel.initialize();

      final apiKey = widget.storageService.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        final aiService = AIRecommendationService(
          apiKey,
          widget.tokenStatsRepository,
        );
        homeViewModel.setAIService(aiService);
      }

      setState(() {
        _statusMessage = '初始化完成！';
        _isInitialized = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = '初始化失败: $e';
      });
      print('App initialization failed: $e');
    }
  }

  Future<String?> _showApiKeyInputDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('设置 OpenAI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请输入您的 OpenAI API Key 以启用AI推荐功能。\n\n'
              '获取地址：https://platform.openai.com/api-keys',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'sk-...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('跳过'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: ThemeConfig.cardShadow,
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 48),

                if (!_isInitialized) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: ThemeConfig.primaryColor,
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeConfig.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}