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

// 导入 Repository
import 'data/repositories/user_repository.dart';
import 'data/repositories/meal_repository.dart';

// 导入 ViewModel
import 'presentation/viewmodels/user_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

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

  // 运行应用
  runApp(
    HealthyEatsApp(
      userRepository: userRepository,
      mealRepository: mealRepository,
    ),
  );
}

class HealthyEatsApp extends StatelessWidget {
  final UserRepository userRepository;
  final MealRepository mealRepository;

  const HealthyEatsApp({
    super.key,
    required this.userRepository,
    required this.mealRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 用户ViewModel - 移除 ..initialize()
        ChangeNotifierProvider(
          create: (_) => UserViewModel(userRepository),
        ),
        // 首页ViewModel - 移除 ..initialize()
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(userRepository, mealRepository),
        ),
      ],
      child: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
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
            locale: Locale(userViewModel.currentUser?.language ?? 'zh'),

            // 启动页
            home: const AppInitializerPage(),

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
  const AppInitializerPage({super.key});

  @override
  State<AppInitializerPage> createState() => _AppInitializerPageState();
}

class _AppInitializerPageState extends State<AppInitializerPage> {
  bool _isInitialized = false;
  String _statusMessage = '正在初始化...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
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

      setState(() {
        _statusMessage = '初始化完成！';
        _isInitialized = true;
      });

      // 延迟一下让用户看到"完成"消息
      await Future.delayed(const Duration(milliseconds: 500));

      // 跳转到主页（这里先用临时页面）
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TemporaryHomePage(),
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

/// 临时首页
///
/// 这是一个占位页面，用于验证应用可以正常启动
/// 后续需要替换为真正的 HomeScreen
class TemporaryHomePage extends StatelessWidget {
  const TemporaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

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

              const SizedBox(height: 32),

              // 应用名称
              Text(
                l10n.appName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: ThemeConfig.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 副标题
              Text(
                'AI智能健康饮食管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ThemeConfig.textSecondaryColor,
                ),
              ),

              const SizedBox(height: 48),

              // 成功提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeConfig.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: ThemeConfig.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '应用启动成功！\n核心架构已就绪',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 功能列表
              _buildFeatureCard(
                context,
                icon: Icons.analytics_outlined,
                title: '情绪ROI分析',
                description: '基于营养素的情绪调节评估',
                status: '✓ 已就绪',
              ),

              const SizedBox(height: 16),

              _buildFeatureCard(
                context,
                icon: Icons.insights_outlined,
                title: 'LQI生活质量指数',
                description: '综合健康、情绪、预算、便捷性',
                status: '✓ 已就绪',
              ),

              const SizedBox(height: 16),

              _buildFeatureCard(
                context,
                icon: Icons.psychology_outlined,
                title: 'AI智能推荐',
                description: '个性化餐食方案生成',
                status: '待开发',
              ),

              const SizedBox(height: 32),

              // 下一步提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '下一步开发',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 实现底部导航栏\n'
                      '• 创建首页布局\n'
                      '• 添加餐食记录功能\n'
                      '• 实现AI推荐接口',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConfig.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 版本信息
              Text(
                'Version 1.0.0 (Build 1)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeConfig.textHintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String status,
  }) {
    final bool isReady = status.contains('✓');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeConfig.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ThemeConfig.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isReady
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: isReady ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}