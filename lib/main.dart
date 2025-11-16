// lib/main.dart
// 应用入口文件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// 导入本地生成的国际化文件
import 'l10n/app_localizations.dart';

// 导入配置
import 'config/theme_config.dart';

// 导入服务
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/ai_recommendation_service.dart';

// 导入 Repository
import 'data/repositories/user_repository.dart';
import 'data/repositories/meal_repository.dart';
import 'data/repositories/token_stats_repository.dart';

// 导入 ViewModel
import 'presentation/viewmodels/user_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

// 导入主导航页面
import 'presentation/widgets/bottom_nav_bar.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化本地存储服务
  final storageService = await StorageService.getInstance();

  // 初始化通知服务
  await NotificationService.initialize();

  // 初始化 Repository
  final userRepository = UserRepository(storageService);
  final mealRepository = MealRepository(storageService);
  final tokenStatsRepository = TokenStatsRepository(storageService);

  // 提前加载用户语言偏好
  String initialLanguage = 'zh'; // 默认中文
  try {
    final user = await storageService.getUserProfile();
    if (user != null && user.language.isNotEmpty) {
      initialLanguage = user.language;
    }
  } catch (e) {
    print('Failed to load user language preference: $e');
  }

  // 运行应用
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
        // 用户ViewModel
        ChangeNotifierProvider(
          create: (_) => UserViewModel(userRepository),
        ),
        // 首页ViewModel
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(userRepository, mealRepository),
        ),
      ],
      child: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          final currentLanguage = userViewModel.currentUser?.language ?? initialLanguage;

          return MaterialApp(
            title: 'Healthy Eats',

            // 主题配置
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,

            // 国际化配置
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh'), // 中文
              Locale('en'), // 英文
              Locale('ja'), // 日文
              Locale('ko'), // 韩文
              Locale('fr'), // 法文
              Locale('de'), // 德文
              Locale('es'), // 西班牙文
            ],
            locale: Locale(currentLanguage),

            // 启动页
            home: AppInitializerPage(
              storageService: storageService,
              tokenStatsRepository: tokenStatsRepository,
            ),

            // 关闭调试横幅
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

/// 应用初始化页面
///
/// 负责在后台初始化 ViewModel，完成后跳转到主页
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
      // 检查API Key
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

      // 获取 ViewModel
      final userViewModel = context.read<UserViewModel>();
      final homeViewModel = context.read<HomeViewModel>();

      // 初始化用户信息
      await userViewModel.initialize();

      setState(() {
        _statusMessage = '加载餐食数据...';
      });

      // 初始化首页数据
      await homeViewModel.initialize();

      // ⭐ 初始化AI服务（但不在启动时加载推荐）
      final apiKey = widget.storageService.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        final aiService = AIRecommendationService(
          apiKey,
          widget.tokenStatsRepository,
        );
        homeViewModel.setAIService(aiService);

        // ⭐ 不在这里加载推荐，而是在进入主页后后台加载
        // 注释掉原来的代码：
        // setState(() {
        //   _statusMessage = '加载推荐餐食...';
        // });
        // await homeViewModel.loadRecommendations();
      }

      setState(() {
        _statusMessage = '初始化完成！';
        _isInitialized = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // 跳转到主导航页面
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

  /// 显示API Key输入对话框
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
                // 应用图标
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

                // 加载指示器
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

                // 状态消息
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