import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:http/http.dart' as http;

// ================= YouTube 教程跳转 =================

Future<void> launchExerciseTutorial(String exerciseName) async {
  // 中文搜索加上"教程"，英文加上"tutorial form"
  final query = S.isZh
      ? '$exerciseName 健身教程 动作讲解'
      : '$exerciseName exercise tutorial proper form';
  final url = Uri.parse(
    'https://www.youtube.com/results?search_query=${Uri.encodeQueryComponent(query)}',
  );
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

// ================= 全局通知器 =================

final ValueNotifier<String> _langNotifier = ValueNotifier('zh');
final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  _langNotifier.value = prefs.getString('language') ?? 'zh';
  final themeStr = prefs.getString('theme_mode') ?? 'dark';
  _themeNotifier.value = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
  runApp(const MyApp());
}

// ================= 多语言字符串 =================

class S {
  static String get _l => _langNotifier.value;
  static bool get isZh => _l == 'zh';

  // App
  static String get appTitle => isZh ? '健身记录' : 'FitLog';

  // 导航
  static String get navTraining => isZh ? '力量训练' : 'Strength';
  static String get navRunning => isZh ? '有氧跑步' : 'Running';
  static String get navSettings => isZh ? '设置' : 'Settings';
  static String get navCalendar => isZh ? '日历' : 'Calendar';

  // 通用
  static String get cancel => isZh ? '取消' : 'Cancel';
  static String get save => isZh ? '保存' : 'Save';
  static String get add => isZh ? '添加' : 'Add';
  static String get delete => isZh ? '删除' : 'Delete';
  static String get confirm => isZh ? '确认' : 'Confirm';
  static String get notSet => isZh ? '未设置' : 'Not set';

  // 训练页
  static String get training => isZh ? '训练' : 'Training';
  static String get addExercise => isZh ? '添加动作' : 'Add Exercise';
  static String get noTrainingPlan => isZh ? '今天还没有训练计划' : 'No workout plan for today';
  static String get tapToAdd => isZh ? '点击下方按钮添加训练动作' : 'Tap the button below to add exercises';
  static String get selectExercise => isZh ? '选择训练动作' : 'Select Exercise';
  static String get setsHeader => isZh ? '组' : 'Set';
  static String get weightKg => isZh ? '重量(kg)' : 'Weight(kg)';
  static String get repsHeader => isZh ? '次数' : 'Reps';
  static String get doneHeader => isZh ? '完成' : 'Done';
  static String get addSet => isZh ? '添加一组' : 'Add Set';
  static String setsCompleted(int n) => isZh ? '$n 组完成' : '$n sets done';

  // 跑步页
  static String get startRun => isZh ? '开始跑步' : 'Start Run';
  static String get pauseRun => isZh ? '暂停' : 'Pause';
  static String get resumeRun => isZh ? '继续' : 'Resume';
  static String get stopRun => isZh ? '结束跑步' : 'Stop Run';
  static String get saveRun => isZh ? '保存记录' : 'Save Run';
  static String get discardRun => isZh ? '丢弃' : 'Discard';
  static String get distance => isZh ? '距离' : 'Distance';
  static String get pace => isZh ? '配速' : 'Pace';
  static String get cadence => isZh ? '步频' : 'Cadence';
  static String get aqiLabel => isZh ? '空气质量' : 'Air Quality';
  static String get weatherLabel => isZh ? '天气' : 'Weather';
  static String get runHistory => isZh ? '历史记录' : 'Run History';
  static String get envReadiness => isZh ? '环境适宜性' : 'Run Readiness';
  static String get aqiGood => isZh ? '优' : 'Good';
  static String get aqiModerate => isZh ? '良' : 'Moderate';
  static String get aqiUnhealthy => isZh ? '不健康' : 'Unhealthy';
  static String get aqiVeryUnhealthy => isZh ? '非常不健康' : 'Very Unhealthy';
  static String get aqiHazardous => isZh ? '危险' : 'Hazardous';
  static String get noRunHistory => isZh ? '还没有跑步记录' : 'No runs yet';
  static String get runSummary => isZh ? '跑步总结' : 'Run Summary';
  static String get fetchingEnv => isZh ? '获取环境数据...' : 'Fetching environment data...';
  static String get envUnavailable => isZh ? '环境数据不可用' : 'Environment data unavailable';
  static String get locating => isZh ? '正在定位...' : 'Locating...';
  static String get steps => isZh ? '步数' : 'Steps';
  static String get calories => isZh ? '卡路里' : 'Calories';
  static String get duration => isZh ? '时长' : 'Duration';

  // 设置页
  static String get settings => isZh ? '设置' : 'Settings';
  static String get dietSettings => isZh ? '饮食设置' : 'Diet Settings';
  static String get dailyCalTarget => isZh ? '每日热量目标' : 'Daily Calorie Target';
  static String currentKcal(int n) => isZh ? '当前: $n 千卡' : 'Current: $n kcal';
  static String get setDailyTarget => isZh ? '设置每日热量目标' : 'Set Daily Calorie Target';
  static String get calTargetLabel => isZh ? '热量目标 (千卡)' : 'Calorie target (kcal)';
  static String get calTargetHint => isZh ? '例：2000' : 'e.g. 2000';
  static String get languageSettings => isZh ? '语言设置' : 'Language';
  static String get languageLabel => isZh ? '语言 / Language' : 'Language / 语言';
  static String get chinese => isZh ? '中文' : 'Chinese';
  static String get english => isZh ? '英文' : 'English';
  static String get about => isZh ? '关于' : 'About';
  static String get version => isZh ? '版本' : 'Version';

  // BMR
  static String get bodyDataSettings => isZh ? '身体数据' : 'Body Data';
  static String get bmrTitle => isZh ? '基础代谢 (BMR)' : 'Basal Metabolic Rate (BMR)';
  static String get bmrSubtitle => isZh ? '用于计算每日所需热量' : 'Used to estimate daily calorie needs';
  static String get setBmr => isZh ? '设置身体数据' : 'Set Body Data';
  static String get gender => isZh ? '性别' : 'Gender';
  static String get male => isZh ? '男' : 'Male';
  static String get female => isZh ? '女' : 'Female';
  static String get height => isZh ? '身高 (cm)' : 'Height (cm)';
  static String get weightLabel => isZh ? '体重 (kg)' : 'Weight (kg)';
  static String get age => isZh ? '年龄 (岁)' : 'Age (years)';
  static String get heightHint => isZh ? '例：175' : 'e.g. 175';
  static String get weightHint => isZh ? '例：70' : 'e.g. 70';
  static String get ageHint => isZh ? '例：25' : 'e.g. 25';
  static String bmrResult(int bmr) => isZh ? '基础代谢: $bmr 千卡/天' : 'BMR: $bmr kcal/day';
  static String get useAsDailyTarget => isZh ? '将推荐热量设为目标' : 'Set recommended calories as target';
  static String get activityLevel => isZh ? '活动量' : 'Activity Level';
  static String get sedentary => isZh ? '久坐（几乎不运动）' : 'Sedentary (little/no exercise)';
  static String get lightlyActive => isZh ? '轻度活动（每周1-3天）' : 'Lightly active (1-3 days/week)';
  static String get moderatelyActive => isZh ? '中度活动（每周3-5天）' : 'Moderately active (3-5 days/week)';
  static String get veryActive => isZh ? '高度活动（每周6-7天）' : 'Very active (6-7 days/week)';
  static String tdeeResult(int tdee) => isZh ? '推荐摄入: $tdee 千卡/天' : 'Recommended: $tdee kcal/day';
  static String get bmrNotSetHint => isZh ? '点击设置身高体重以计算' : 'Tap to set height & weight';

  // 训练消耗热量
  static String get trainingCalories => isZh ? '训练消耗' : 'Calories Burned';
  static String get caloriesUnit => isZh ? '千卡' : 'kcal';
  static String get setWeightForCalc => isZh ? '在设置中填写体重以提高精度' : 'Set weight in Settings for accuracy';

  // 步数系统
  static String get stepsToday => isZh ? '今日步数' : "Today's Steps";
  static String get stepsCalories => isZh ? '步行消耗' : 'Walk Calories';
  static String get stepsUnit => isZh ? '步' : 'steps';
  static String get stepsPermissionDenied => isZh ? '请授权运动权限以统计步数' : 'Grant motion permission to count steps';
  static String get stepsNotAvailable => isZh ? '此设备不支持步数统计' : 'Step sensor unavailable on this device';
  static String get stepsLoading => isZh ? '正在读取步数…' : 'Reading steps…';
  static String get dailyStepsGoal => isZh ? '目标步数' : 'Daily Goal';
  static String stepCaloriesVal(int cal) => isZh ? '$cal 千卡' : '$cal kcal';
}

// ================= 动作数据库（双语） =================

// 二级分类：大肌群 -> 子分类 -> 动作列表
Map<String, Map<String, List<String>>> getExerciseDatabase() {
  if (!S.isZh) {
    return {
      'Chest': {
        'Mid/Lower': ['Bench Press', 'Dumbbell Press', 'Pec Dec', 'Cable Fly', 'Dips', 'Push-ups'],
        'Upper': ['Incline Press', 'Incline DB Press', 'Incline DB Fly', 'Incline Cable Fly'],
      },
      'Back': {
        'Upper Back': ['Pull-ups', 'Lat Pulldown', 'Seated Row', 'Single-arm Row', 'Bent-over Row', 'T-bar Row'],
        'Lower Back': ['Deadlift', 'Romanian Deadlift', 'Good Morning', 'Superman'],
      },
      'Legs': {
        'Quadriceps': ['Squat', 'Leg Press', 'Leg Extension', 'Lunge', 'Bulgarian Split Squat', 'Hack Squat'],
        'Hamstrings': ['Leg Curl', 'Romanian Deadlift', 'Stiff-leg Deadlift', 'Nordic Curl', 'Calf Raise'],
      },
      'Shoulder': {
        'Front Delt': ['DB Front Raise', 'Barbell Front Raise', 'Arnold Press'],
        'Side Delt': ['Lateral Raise', 'Seated Press', 'Cable Lateral Raise', 'Smith Press'],
        'Rear Delt': ['Reverse Fly', 'Reverse Pec Dec', 'Face Pull', 'Cable Reverse Fly'],
      },
      'Abs': {
        'Upper': ['Crunch', 'Cable Crunch', 'Sit-up', 'Ab Wheel'],
        'Lower': ['Hanging Leg Raise', 'Lying Leg Raise', 'Reverse Crunch', 'Mountain Climber'],
        'Obliques': ['Russian Twist', 'Side Bend', 'Cable Side Bend', 'Windmill'],
      },
      'Arms': {
        'Biceps': ['Barbell Curl', 'Dumbbell Curl', 'Hammer Curl', 'Preacher Curl', 'Cable Curl'],
        'Triceps': ['Rope Pushdown', 'Skull Crusher', 'Overhead Extension', 'Close-grip Press', 'Dips'],
      },
    };
  }
  return {
    '胸部': {
      '中下胸': ['平板卧推', '哑铃卧推', '蝴蝶机夹胸', '绳索夹胸', '双杠臂屈伸', '俯卧撑'],
      '上胸': ['上斜卧推', '上斜哑铃卧推', '上斜哑铃飞鸟', '上斜绳索夹胸'],
    },
    '背部': {
      '上背': ['引体向上', '高位下拉', '坐姿划船', '单臂哑铃划船', '俯身杠铃划船', 'T杠划船'],
      '下背': ['硬拉', '罗马尼亚硬拉', '早安式', '超人式'],
    },
    '腿部': {
      '股四头': ['深蹲', '腿举', '腿伸展', '哑铃弓步', '保加利亚深蹲', '黑克深蹲'],
      '腘绳肌': ['腿弯举', '罗马尼亚硬拉', '直腿硬拉', '北欧腿弯举', '小腿提踵'],
    },
    '肩部': {
      '前束': ['哑铃前平举', '杠铃前平举', '上斜推举', '阿诺德推举'],
      '中束': ['哑铃侧平举', '坐姿推举', '绳索侧平举', '史密斯推举'],
      '后束': ['俯身飞鸟', '反向蝴蝶机', '面拉', '绳索反向飞鸟'],
    },
    '腹部': {
      '上腹': ['卷腹', '绳索卷腹', '仰卧起坐', '健腹轮'],
      '下腹': ['悬垂举腿', '仰卧举腿', '反向卷腹', '登山者式'],
      '侧腹': ['俄罗斯转体', '侧弯', '绳索侧弯', '风车式'],
    },
    '手臂': {
      '二头肌': ['杠铃弯举', '哑铃弯举', '锤式弯举', '托臂弯举', '绳索弯举'],
      '三头肌': ['绳索下压', '仰卧臂屈伸', '过头臂屈伸', '窄距卧推', '双杠臂屈伸'],
    },
  };
}

// ================= 数据模型 =================

class WorkoutExercise {
  String name;
  String muscleGroup;
  List<WorkoutSet> sets;

  WorkoutExercise({required this.name, required this.muscleGroup, List<WorkoutSet>? sets})
      : sets = sets ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'muscleGroup': muscleGroup,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
        name: json['name'],
        muscleGroup: json['muscleGroup'],
        sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
      );
}

class WorkoutSet {
  double weight;
  int reps;
  bool isDone;

  WorkoutSet({this.weight = 0, this.reps = 0, this.isDone = false});

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps, 'isDone': isDone};

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'],
        isDone: json['isDone'] ?? false,
      );
}

// 训练模版
class WorkoutTemplate {
  String id;
  String name;
  List<String> muscleGroups;
  List<WorkoutExercise> exercises;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroups': muscleGroups,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) => WorkoutTemplate(
    id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    name: json['name'] as String? ?? '',
    muscleGroups: List<String>.from(json['muscleGroups'] as List? ?? []),
    exercises: (json['exercises'] as List? ?? [])
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Future<List<WorkoutTemplate>> _loadTemplates() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('workout_templates');
  if (raw == null) return [];
  try {
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => WorkoutTemplate.fromJson(e)).toList();
  } catch (_) {
    return [];
  }
}

Future<void> _saveTemplates(List<WorkoutTemplate> templates) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('workout_templates',
      jsonEncode(templates.map((t) => t.toJson()).toList()));
}


// ================= 主 App =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _langNotifier,
      builder: (_, lang, child) => ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeNotifier,
        builder: (_, themeMode, child) => MaterialApp(
          title: S.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B35),
              secondary: Color(0xFFFF6B35),
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1A1A1A),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFFFF6B35),
              unselectedItemColor: Colors.grey,
            ),
            cardTheme: const CardThemeData(color: Colors.white, elevation: 2),
            listTileTheme: const ListTileThemeData(
              tileColor: Colors.white,
              textColor: Color(0xFF1A1A1A),
              iconColor: Color(0xFF1A1A1A),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white,
              modalBackgroundColor: Colors.white,
            ),
            dividerColor: Color(0xFFE0E0E0),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
              bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
              bodySmall: TextStyle(color: Color(0xFF555555)),
              titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
              titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B35),
              secondary: Color(0xFFFF6B35),
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFFFF6B35),
              unselectedItemColor: Colors.grey,
            ),
            cardTheme: const CardThemeData(color: Color(0xFF1E1E1E), elevation: 2),
            listTileTheme: const ListTileThemeData(
              tileColor: Color(0xFF1E1E1E),
              textColor: Colors.white,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              modalBackgroundColor: Color(0xFF1E1E1E),
            ),
            dividerColor: Color(0xFF2A2A2A),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1E1E)),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.grey),
              titleMedium: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

// ================= 主导航框架 =================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TrainingPage(),
    const AerobicPage(),
    const CalendarPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.fitness_center), label: S.navTraining),
          BottomNavigationBarItem(icon: const Icon(Icons.directions_run), label: S.navRunning),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_month), label: S.navCalendar),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: S.navSettings),
        ],
      ),
    );
  }
}

// ================= 训练界面 =================

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  List<WorkoutExercise> _exercises = [];
  final String _selectedDate = _todayKey();

  // ── 训练计时 ──
  Timer? _workoutTimer;
  int _workoutSeconds = 0;
  bool _workoutStarted = false;
  int _restSeconds = 90;

  // ── 体重（用于热量计算）──
  double _bodyWeight = 70.0;

  // ── 步数计数 ──
  StreamSubscription<StepCount>? _stepSub;
  int _stepBaseline = 0;   // 当天基线
  int _dailySteps = 0;     // 今日步数
  String _stepStatus = 'loading'; // loading / walking / stopped / unavailable / denied

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _initStepCounter();
    _langNotifier.addListener(_onLangChanged);
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _stepSub?.cancel();
    _langNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _onLangChanged() => setState(() {});

  // ── 步数计数器初始化 ──
  Future<void> _initStepCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = 'step_baseline_$_selectedDate';
      _stepBaseline = prefs.getInt(todayKey) ?? -1;

      _stepSub = Pedometer.stepCountStream.listen(
        (StepCount e) async {
          final raw = e.steps;
          // 第一次收到今天数据时记录基线
          if (_stepBaseline < 0) {
            _stepBaseline = raw;
            final p = await SharedPreferences.getInstance();
            await p.setInt(todayKey, raw);
          }
          if (!mounted) return;
          setState(() {
            _dailySteps = (raw - _stepBaseline).clamp(0, 999999);
            _stepStatus = 'ok';
          });
        },
        onError: (e) {
          if (!mounted) return;
          final msg = e.toString().toLowerCase();
          setState(() => _stepStatus =
              msg.contains('denied') || msg.contains('permission')
                  ? 'denied'
                  : 'unavailable');
        },
        cancelOnError: false,
      );
    } catch (_) {
      if (mounted) setState(() => _stepStatus = 'unavailable');
    }
  }

  int get _stepCalories => (_dailySteps * _bodyWeight * 0.000565).round();

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _restSeconds = prefs.getInt('rest_default_seconds') ?? 90;
    _bodyWeight = prefs.getDouble('bmr_weight') ?? 70.0;
    final raw = prefs.getString('training_$_selectedDate');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() => _exercises = decoded.map((e) => WorkoutExercise.fromJson(e)).toList());
    } else {
      setState(() => _exercises = []);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'training_$_selectedDate',
      jsonEncode(_exercises.map((e) => e.toJson()).toList()),
    );
  }

  void _addExercise(String name, String muscleGroup) {
    setState(() {
      _exercises.add(WorkoutExercise(name: name, muscleGroup: muscleGroup, sets: [WorkoutSet(reps: 10)]));
    });
    _saveData();
  }

  void _removeExercise(int index) {
    setState(() => _exercises.removeAt(index));
    _saveData();
  }

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TemplatePickerSheet(
        onImport: (template) {
          // Ask replace or append
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Text(template.name,
                  style: const TextStyle(color: Colors.white)),
              content: Text(
                S.isZh
                    ? '如何导入"${template.name}"？'
                    : 'How to import "${template.name}"?',
                style: TextStyle(color: Colors.grey[400]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.isZh ? '取消' : 'Cancel',
                      style: const TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      for (final ex in template.exercises) {
                        _exercises.add(WorkoutExercise(
                          name: ex.name,
                          muscleGroup: ex.muscleGroup,
                          sets: ex.sets.isNotEmpty
                              ? ex.sets.map((s) => WorkoutSet(weight: s.weight, reps: s.reps)).toList()
                              : [WorkoutSet(reps: 10)],
                        ));
                      }
                    });
                    _saveData();
                  },
                  child: Text(S.isZh ? '追加' : 'Append',
                      style: const TextStyle(color: Colors.blueAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _exercises.clear();
                      for (final ex in template.exercises) {
                        _exercises.add(WorkoutExercise(
                          name: ex.name,
                          muscleGroup: ex.muscleGroup,
                          sets: ex.sets.isNotEmpty
                              ? ex.sets.map((s) => WorkoutSet(weight: s.weight, reps: s.reps)).toList()
                              : [WorkoutSet(reps: 10)],
                        ));
                      }
                    });
                    _saveData();
                  },
                  child: Text(S.isZh ? '替换' : 'Replace'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveAsTemplate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SaveTemplateSheet(exercises: _exercises),
    );
  }

  String _formatTime(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _startWorkout() {
    setState(() {
      _workoutStarted = true;
      _workoutSeconds = 0;
    });
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _workoutSeconds++);
    });
  }

  void _finishWorkout() {
    _workoutTimer?.cancel();
    final totalSets = _exercises.fold<int>(
        0, (sum, e) => sum + e.sets.where((s) => s.isDone).length);
    final totalVol = _exercises.fold<int>(
        0,
        (sum, e) =>
            sum + e.sets.fold<int>(0, (s, st) => s + (st.weight * st.reps).round()));
    final duration = _formatTime(_workoutSeconds);
    // MET for weight training ≈ 3.5; Calories = MET × weight(kg) × hours
    final calories = (3.5 * _bodyWeight * _workoutSeconds / 3600).round();
    final snapshotSeconds = _workoutSeconds;
    setState(() {
      _workoutStarted = false;
      _workoutSeconds = 0;
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Text('🏆', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(S.isZh ? '训练完成！' : 'Workout Complete!'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _WorkoutSummaryRow(
                icon: Icons.timer_outlined,
                label: S.isZh ? '训练时长' : 'Duration',
                value: duration),
            _WorkoutSummaryRow(
                icon: Icons.check_circle_outline,
                label: S.isZh ? '完成组数' : 'Sets Done',
                value: '$totalSets'),
            if (totalVol > 0)
              _WorkoutSummaryRow(
                  icon: Icons.fitness_center,
                  label: S.isZh ? '总训练量' : 'Total Volume',
                  value: '${totalVol}kg'),
            if (snapshotSeconds > 0)
              _WorkoutSummaryRow(
                  icon: Icons.local_fire_department_outlined,
                  label: S.trainingCalories,
                  value: '~$calories ${S.caloriesUnit}'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.confirm),
          ),
        ],
      ),
    );
  }

  void _showRestTimer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
      pageBuilder: (ctx, a1, a2) => _RestTimerOverlay(
        initialSeconds: _restSeconds,
        onAdjustDefault: (s) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('rest_default_seconds', s);
          if (mounted) setState(() => _restSeconds = s);
        },
      ),
    );
  }

  void _showAddExerciseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ExercisePicker(onSelect: (name, group) {
        Navigator.pop(context);
        _addExercise(name, group);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = _exercises.fold<int>(0, (sum, e) => sum + e.sets.where((s) => s.isDone).length);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.training, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (_workoutStarted)
              Row(children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatTime(_workoutSeconds),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Text(S.isZh ? '训练中' : 'in progress',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ])
            else
              Text(_selectedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          if (totalSets > 0 && !_workoutStarted)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(S.setsCompleted(totalSets),
                    style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 13)),
              ),
            ),
          if (!_workoutStarted) ...[
            IconButton(
              icon: const Icon(Icons.library_books_outlined, color: Colors.white70),
              onPressed: _showTemplatePicker,
              tooltip: S.isZh ? '导入模版' : 'Import Template',
            ),
            if (_exercises.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white70),
                onPressed: _saveAsTemplate,
                tooltip: S.isZh ? '存为模版' : 'Save as Template',
              ),
          ],
          if (_workoutStarted)
            IconButton(
              icon: const Icon(Icons.timer_outlined, color: Colors.blueAccent),
              onPressed: _showRestTimer,
              tooltip: S.isZh ? '休息计时' : 'Rest Timer',
            ),
          IconButton(
            icon: Icon(
              _workoutStarted ? Icons.stop_circle_outlined : Icons.play_circle_outline,
              color: _workoutStarted ? Colors.redAccent : const Color(0xFF4CAF50),
              size: 28,
            ),
            onPressed: _workoutStarted ? _finishWorkout : _startWorkout,
            tooltip: _workoutStarted
                ? (S.isZh ? '结束训练' : 'Finish')
                : (S.isZh ? '开始训练' : 'Start'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildStepCard(),
          Expanded(
            child: _exercises.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) => _ExerciseCard(
                      exercise: _exercises[index],
                      onDelete: () => _removeExercise(index),
                      onChanged: _saveData,
                      onRestTimer: _showRestTimer,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseDialog,
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.add),
        label: Text(S.addExercise),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(S.noTrainingPlan, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          Text(S.tapToAdd, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStepCard() {
    const int goal = 10000;
    final double progress = (_dailySteps / goal).clamp(0.0, 1.0);

    Widget content;
    if (_stepStatus == 'loading') {
      content = Text(S.stepsLoading,
          style: TextStyle(color: Colors.grey[500], fontSize: 13));
    } else if (_stepStatus == 'denied') {
      content = Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(S.stepsPermissionDenied,
              style: const TextStyle(color: Colors.orange, fontSize: 12)),
        ),
      ]);
    } else if (_stepStatus == 'unavailable') {
      content = Row(children: [
        Icon(Icons.sensors_off, color: Colors.grey[600], size: 16),
        const SizedBox(width: 6),
        Text(S.stepsNotAvailable,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ]);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 步数
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.stepsToday,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$_dailySteps',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '  ${S.stepsUnit}',
                            style:
                                TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 步行消耗热量
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(S.stepsCalories,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_stepCalories',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${S.caloriesUnit}',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_dailySteps / $goal ${S.stepsUnit}',
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_walk,
                color: Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _ExercisePicker extends StatelessWidget {
  final void Function(String name, String group) onSelect;
  const _ExercisePicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final db = getExerciseDatabase();
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(S.selectExercise,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: db.entries.expand((group) {
                  // group.key = 大肌群（如"胸部"），group.value = 子分类 Map
                  return [
                    // 大肌群标题
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            group.key,
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 子分类及动作
                    ...group.value.entries.expand((sub) {
                      // sub.key = 子分类（如"中下胸"），sub.value = 动作列表
                      return [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 8, 16, 4),
                          child: Text(
                            sub.key,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...sub.value.map((exercise) => ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(28, 0, 12, 0),
                              dense: true,
                              title: Text(exercise, style: const TextStyle(fontSize: 14)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 播放按钮 → 跳 YouTube 教程
                                  GestureDetector(
                                    onTap: () => launchExerciseTutorial(exercise),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey[700]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.play_circle_outline, color: Colors.white70, size: 14),
                                          const SizedBox(width: 3),
                                          Text(S.isZh ? '教程' : 'Guide',
                                              style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 添加按钮
                                  GestureDetector(
                                    onTap: () => onSelect(exercise, sub.key),
                                    child: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6B35), size: 22),
                                  ),
                                ],
                              ),
                              onTap: () => onSelect(exercise, sub.key),
                            )),
                      ];
                    }),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ];
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final WorkoutExercise exercise;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final VoidCallback onRestTimer;

  const _ExerciseCard(
      {required this.exercise,
      required this.onDelete,
      required this.onChanged,
      required this.onRestTimer});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  void _addSet() {
    final last = widget.exercise.sets.isNotEmpty ? widget.exercise.sets.last : null;
    setState(() {
      widget.exercise.sets.add(WorkoutSet(weight: last?.weight ?? 0, reps: last?.reps ?? 10));
    });
    widget.onChanged();
  }

  void _removeSet(int index) {
    if (widget.exercise.sets.length <= 1) return;
    setState(() => widget.exercise.sets.removeAt(index));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(widget.exercise.muscleGroup,
                      style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.exercise.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                // 教程按钮
                GestureDetector(
                  onTap: () => launchExerciseTutorial(widget.exercise.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.white70, size: 13),
                        const SizedBox(width: 3),
                        Text(S.isZh ? '教程' : 'Guide',
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(width: 32, child: Text(S.setsHeader, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                Expanded(child: Center(child: Text(S.weightKg, style: const TextStyle(color: Colors.grey, fontSize: 12)))),
                Expanded(child: Center(child: Text(S.repsHeader, style: const TextStyle(color: Colors.grey, fontSize: 12)))),
                SizedBox(width: 48, child: Center(child: Text(S.doneHeader, style: const TextStyle(color: Colors.grey, fontSize: 12)))),
              ],
            ),
            const Divider(height: 8),
            ...List.generate(widget.exercise.sets.length, (i) {
              final set = widget.exercise.sets[i];
              return GestureDetector(
                onLongPress: () => _removeSet(i),
                child: Container(
                  color: set.isDone ? const Color(0xFFFF6B35).withValues(alpha: 0.05) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  color: set.isDone ? const Color(0xFFFF6B35) : Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: _NumberInput(
                            value: set.weight == 0 ? '' : set.weight.toString().replaceAll('.0', ''),
                            hint: '0',
                            onChanged: (v) {
                              setState(() => set.weight = double.tryParse(v) ?? 0);
                              widget.onChanged();
                            },
                          ),
                        ),
                        Expanded(
                          child: _NumberInput(
                            value: set.reps == 0 ? '' : set.reps.toString(),
                            hint: '0',
                            onChanged: (v) {
                              setState(() => set.reps = int.tryParse(v) ?? 0);
                              widget.onChanged();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => set.isDone = !set.isDone);
                                widget.onChanged();
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: set.isDone ? const Color(0xFFFF6B35) : Colors.transparent,
                                  border: Border.all(
                                    color: set.isDone ? const Color(0xFFFF6B35) : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: set.isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // 组间休息按钮
            GestureDetector(
              onTap: widget.onRestTimer,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.06),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 15, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Text(S.isZh ? '组间休息' : 'Rest Timer',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _addSet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(S.addSet, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  const _NumberInput({required this.value, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 60,
        height: 32,
        child: TextFormField(
          initialValue: value,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[700]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[700]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFFF6B35))),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── 训练完成摘要行 ──
class _WorkoutSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WorkoutSummaryRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B35), size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

// ================= 休息计时器（闹钟UI） =================

class _RestTimerOverlay extends StatefulWidget {
  final int initialSeconds;
  final ValueChanged<int>? onAdjustDefault;
  const _RestTimerOverlay(
      {required this.initialSeconds, this.onAdjustDefault});

  @override
  State<_RestTimerOverlay> createState() => _RestTimerOverlayState();
}

class _RestTimerOverlayState extends State<_RestTimerOverlay>
    with TickerProviderStateMixin {
  late int _remaining;
  late int _total;
  Timer? _countdownTimer;
  bool _finished = false;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;
  late int _funnyIndex;

  static const List<String> _iconsZh = ['💪', '🐔', '🔔', '🦁', '⚡'];
  static const List<String> _msgsZh = [
    '别躺着了！\n去撸铁啊！',
    '不动就变成\n小鸡腿了！',
    '铃铃铃！\n继续干！',
    '吼出来！\n继续冲！',
    '充电完毕！\n准备起飞！',
  ];
  static const List<String> _iconsEn = ['💪', '🐔', '🔔', '🦁', '⚡'];
  static const List<String> _msgsEn = [
    'Stop resting!\nGet moving!',
    "Don't be a\nchicken! Go!",
    'DING DING!\nBack to work!',
    'ROAR!\nLet\'s go!',
    'Charged up!\nLet\'s crush it!',
  ];

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialSeconds;
    _total = widget.initialSeconds;
    _funnyIndex = Random().nextInt(5);

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remaining <= 1) {
        t.cancel();
        setState(() {
          _remaining = 0;
          _finished = true;
        });
        HapticFeedback.heavyImpact();
        _bounceCtrl.repeat(reverse: true);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bounceCtrl.dispose();
    super.dispose();
  }

  String get _timeStr {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _adjustTime(int delta) {
    final newRemaining = (_remaining + delta).clamp(5, 3600);
    final newTotal = (_total + delta).clamp(30, 3600);
    setState(() {
      _remaining = newRemaining;
      _total = newTotal;
    });
    widget.onAdjustDefault?.call(newTotal);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: const Color(0xEB000000),
        body: SafeArea(
          child: Center(
            child: _finished ? _buildFinished() : _buildClock(),
          ),
        ),
      ),
    );
  }

  Widget _buildClock() {
    final progress = _total > 0 ? _remaining / _total : 0.0;
    final isLow = progress < 0.25 && _remaining > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.isZh ? '组间休息' : 'Rest',
          style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              letterSpacing: 3,
              fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 32),
        // 时钟表盘
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(260, 260),
                painter: _ClockFacePainter(progress: progress, isLow: isLow),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm,
                    color: isLow ? Colors.redAccent : Colors.grey[600],
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeStr,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: isLow ? Colors.redAccent : Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 调整按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _adjustTime(-15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: const Text('-15s',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => _adjustTime(15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: const Text('+15s',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          S.isZh ? '点击屏幕跳过' : 'Tap anywhere to skip',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFinished() {
    final icon = S.isZh ? _iconsZh[_funnyIndex] : _iconsEn[_funnyIndex];
    final msg = S.isZh ? _msgsZh[_funnyIndex] : _msgsEn[_funnyIndex];

    return ScaleTransition(
      scale: _bounceAnim,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 90)),
          const SizedBox(height: 20),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Text(
              S.isZh ? '点击屏幕继续' : 'Tap to continue',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// 闹钟表盘 Painter
class _ClockFacePainter extends CustomPainter {
  final double progress;
  final bool isLow;
  const _ClockFacePainter({required this.progress, required this.isLow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 背景圆
    canvas.drawCircle(
      center,
      radius - 5,
      Paint()..color = const Color(0xFF161616),
    );

    // 刻度线
    final tickPaint = Paint()..strokeCap = StrokeCap.round;
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * (pi / 180);
      final isMajor = i % 5 == 0;
      final outerR = radius - 10;
      final innerR = isMajor ? radius - 26 : radius - 17;
      tickPaint
        ..strokeWidth = isMajor ? 2.5 : 1.0
        ..color =
            isMajor ? const Color(0xFF4A4A4A) : const Color(0xFF2C2C2C);
      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle),
            center.dy + innerR * sin(angle)),
        Offset(center.dx + outerR * cos(angle),
            center.dy + outerR * sin(angle)),
        tickPaint,
      );
    }

    // 进度轨道
    final arcRect = Rect.fromCircle(center: center, radius: radius - 28);
    canvas.drawArc(
      arcRect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF2A2A2A),
    );

    // 倒计时进度弧
    if (progress > 0) {
      canvas.drawArc(
        arcRect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = isLow ? Colors.redAccent : const Color(0xFFFF6B35),
      );
    }

    // 外圈边框
    canvas.drawCircle(
      center,
      radius - 5,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF2A2A2A)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ClockFacePainter old) =>
      old.progress != progress || old.isLow != isLow;
}

// ================= 日历 / 历史界面 =================

// 单天数据模型
class _DayData {
  final List<WorkoutExercise> exercises;
  final int volume;
  final List<String> muscleGroups;
  final double runDistanceKm;
  final bool isRestDay;

  const _DayData({
    required this.exercises,
    required this.volume,
    required this.muscleGroups,
    required this.runDistanceKm,
    required this.isRestDay,
  });

  bool get hasWorkout => exercises.isNotEmpty;
  bool get hasRun => runDistanceKm > 0;
}

// 子分类 → 简写大肌群标签
String _abbreviateMuscle(String sub) {
  const map = {
    '中下胸': '胸', '上胸': '胸',
    '上背': '背', '下背': '背',
    '股四头': '腿', '腘绳肌': '腿',
    '前束': '肩', '中束': '肩', '后束': '肩',
    '上腹': '腹', '下腹': '腹', '侧腹': '腹',
    '二头肌': '二头', '三头肌': '三头',
    'Mid/Lower': 'Chest', 'Upper': 'Chest',
    'Upper Back': 'Back', 'Lower Back': 'Back',
    'Quadriceps': 'Legs', 'Hamstrings': 'Legs',
    'Front Delt': 'Shldr', 'Side Delt': 'Shldr', 'Rear Delt': 'Shldr',
    'Obliques': 'Abs', 'Biceps': 'Bi', 'Triceps': 'Tri',
  };
  return map[sub] ?? sub;
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentMonth = DateTime.now();
  Map<String, _DayData> _monthData = {};
  bool _loading = false;

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _todayKey() => _dateKey(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _langNotifier.addListener(_onLangChanged);
    _loadMonthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _langNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _onLangChanged() => setState(() {});

  Future<void> _loadMonthData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final newData = <String, _DayData>{};

    for (int d = 1; d <= lastDay.day; d++) {
      final day = DateTime(_currentMonth.year, _currentMonth.month, d);
      final key = _dateKey(day);
      final isRestDay = prefs.getBool('rest_$key') ?? false;

      // 训练数据
      List<WorkoutExercise> exercises = [];
      final trainingRaw = prefs.getString('training_$key');
      if (trainingRaw != null) {
        try {
          final List decoded = jsonDecode(trainingRaw);
          exercises = decoded.map((e) => WorkoutExercise.fromJson(e)).toList();
        } catch (_) {}
      }

      int volume = 0;
      final muscleSet = <String>{};
      for (final ex in exercises) {
        muscleSet.add(_abbreviateMuscle(ex.muscleGroup));
        for (final set in ex.sets) {
          volume += (set.weight * set.reps).round();
        }
      }

      // 跑步数据
      double runDistanceKm = 0;
      final runsRaw = prefs.getString('run_sessions');
      if (runsRaw != null) {
        try {
          final List decoded = jsonDecode(runsRaw);
          for (final r in decoded) {
            final dateStr = r['startTime'] as String? ?? '';
            if (dateStr.startsWith(key)) {
              runDistanceKm += (r['distanceKm'] as num? ?? 0).toDouble();
            }
          }
        } catch (_) {}
      }

      newData[key] = _DayData(
        exercises: exercises,
        volume: volume,
        muscleGroups: muscleSet.toList(),
        runDistanceKm: runDistanceKm,
        isRestDay: isRestDay,
      );
    }

    if (mounted) setState(() { _monthData = newData; _loading = false; });
  }

  Future<void> _toggleRestDay(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cur = prefs.getBool('rest_$key') ?? false;
    await prefs.setBool('rest_$key', !cur);
    _loadMonthData();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadMonthData();
  }

  void _nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    final now = DateTime.now();
    if (next.year > now.year || (next.year == now.year && next.month > now.month)) return;
    setState(() => _currentMonth = next);
    _loadMonthData();
  }

  void _openDayDetail(String key) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DayEditSheet(
        dateKey: key,
        initialIsRestDay: _monthData[key]?.isRestDay ?? false,
        onToggleRestDay: () async {
          Navigator.pop(context);
          await _toggleRestDay(key);
        },
        onDataChanged: () => _loadMonthData(),
      ),
    );
  }

  static String _monthName(int m) =>
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.navCalendar,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B35),
          labelColor: const Color(0xFFFF6B35),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: S.isZh ? '历史' : 'History'),
            Tab(text: S.isZh ? '统计' : 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildHistoryTab(), _buildStatsTab()],
      ),
    );
  }

  // ── 历史 Tab ──
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // 月份导航
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _previousMonth, icon: const Icon(Icons.chevron_left)),
              Text(
                S.isZh
                    ? '${_currentMonth.year}年 ${_currentMonth.month}月'
                    : '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        // 星期表头
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: (S.isZh
                    ? ['一', '二', '三', '四', '五', '六', '日']
                    : ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        // 日历格子
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildGrid(),
                ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startOffset = (firstDay.weekday - 1) % 7; // Mon=0
    final totalRows = ((startOffset + lastDay.day) / 7).ceil();

    return Column(
      children: List.generate(totalRows, (row) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (col) {
              final idx = row * 7 + col;
              final dayNum = idx - startOffset + 1;
              if (dayNum < 1 || dayNum > lastDay.day) {
                return const Expanded(child: SizedBox());
              }
              final day = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
              final key = _dateKey(day);
              return Expanded(
                child: _DayCell(
                  day: dayNum,
                  data: _monthData[key],
                  isToday: key == _todayKey(),
                  onTap: () => _openDayDetail(key),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ── 统计 Tab ──
  Widget _buildStatsTab() {
    final workoutDays = _monthData.values.where((d) => d.hasWorkout).length;
    final restDays = _monthData.values.where((d) => d.isRestDay).length;
    final totalVol = _monthData.values.fold<int>(0, (s, d) => s + d.volume);
    final totalRunKm = _monthData.values.fold<double>(0, (s, d) => s + d.runDistanceKm);

    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final maxVol = _monthData.values.fold<int>(0, (m, d) => d.volume > m ? d.volume : m);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.isZh
                ? '${_currentMonth.year}年${_currentMonth.month}月总结'
                : '${_monthName(_currentMonth.month)} ${_currentMonth.year} Summary',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _StatCard(
                  icon: Icons.fitness_center,
                  label: S.isZh ? '训练天数' : 'Workout Days',
                  value: '$workoutDays ${S.isZh ? "天" : "days"}',
                  color: const Color(0xFFFF6B35)),
              _StatCard(
                  icon: Icons.hotel,
                  label: S.isZh ? '休息天数' : 'Rest Days',
                  value: '$restDays ${S.isZh ? "天" : "days"}',
                  color: Colors.blueAccent),
              _StatCard(
                  icon: Icons.bar_chart,
                  label: S.isZh ? '总训练量' : 'Total Volume',
                  value: totalVol > 0 ? '${(totalVol / 1000).toStringAsFixed(1)} T' : '--',
                  color: const Color(0xFF4CAF50)),
              _StatCard(
                  icon: Icons.directions_run,
                  label: S.isZh ? '本月跑步' : 'Total Run',
                  value: totalRunKm > 0 ? '${totalRunKm.toStringAsFixed(1)} km' : '--',
                  color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 20),
          Text(S.isZh ? '本月训练量分布' : 'Monthly Volume',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // 柱状图
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(daysInMonth, (i) {
                final day = DateTime(_currentMonth.year, _currentMonth.month, i + 1);
                final data = _monthData[_dateKey(day)];
                final vol = data?.volume ?? 0;
                final isRest = data?.isRestDay ?? false;
                final h = maxVol > 0 && vol > 0 ? (60 * vol / maxVol).clamp(4.0, 60.0) : (isRest ? 6.0 : 2.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: isRest
                                ? Colors.blueAccent.withValues(alpha: 0.5)
                                : vol > 0
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // X轴日期标签
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['1', '7', '14', '21', '$daysInMonth']
                  .map((d) => Text(d, style: TextStyle(color: Colors.grey[600], fontSize: 10)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 日历格子 ──
class _DayCell extends StatelessWidget {
  final int day;
  final _DayData? data;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell(
      {required this.day, required this.data, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasWorkout = data?.hasWorkout ?? false;
    final isRestDay = data?.isRestDay ?? false;
    final volume = data?.volume ?? 0;
    final muscles = data?.muscleGroups ?? [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            // 日期数字
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF4CAF50) : null,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // 训练徽标
            if (hasWorkout) ...[
              const SizedBox(height: 2),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A1A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF2D5A2D), width: 0.5),
                ),
                child: Column(
                  children: [
                    Text(
                      volume > 0 ? '$volume' : '✓',
                      style: const TextStyle(
                          color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (muscles.isNotEmpty)
                      Text(
                        muscles.take(3).join(' '),
                        style: TextStyle(color: Colors.grey[400], fontSize: 8.5),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ] else if (isRestDay) ...[
              const SizedBox(height: 2),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  S.isZh ? '休息' : 'Rest',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── 日期详情 / 编辑弹窗 ──
class _DayEditSheet extends StatefulWidget {
  final String dateKey;
  final bool initialIsRestDay;
  final VoidCallback onToggleRestDay;
  final VoidCallback onDataChanged;

  const _DayEditSheet({
    required this.dateKey,
    required this.initialIsRestDay,
    required this.onToggleRestDay,
    required this.onDataChanged,
  });

  @override
  State<_DayEditSheet> createState() => _DayEditSheetState();
}

class _DayEditSheetState extends State<_DayEditSheet> {
  List<WorkoutExercise> _exercises = [];
  List<RunSession> _runs = [];
  bool _loaded = false;
  bool _editMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawEx = prefs.getString('training_${widget.dateKey}');
    List<WorkoutExercise> exs = [];
    if (rawEx != null) {
      try {
        final List decoded = jsonDecode(rawEx);
        exs = decoded.map((e) => WorkoutExercise.fromJson(e)).toList();
      } catch (_) {}
    }
    final allRuns = await _loadRunSessions();
    final runs = allRuns.where((r) =>
        r.startTime.toIso8601String().startsWith(widget.dateKey)).toList();
    if (mounted) setState(() { _exercises = exs; _runs = runs; _loaded = true; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_${widget.dateKey}',
        jsonEncode(_exercises.map((e) => e.toJson()).toList()));
    widget.onDataChanged();
  }

  Future<void> _copyToToday() async {
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    if (key == widget.dateKey) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.isZh ? '已经是今天了' : 'Already today'),
        backgroundColor: const Color(0xFF2A2A2A),
      ));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final copied = _exercises.map((ex) => WorkoutExercise(
      name: ex.name,
      muscleGroup: ex.muscleGroup,
      sets: ex.sets.map((s) => WorkoutSet(weight: s.weight, reps: s.reps)).toList(),
    )).toList();
    await prefs.setString('training_$key',
        jsonEncode(copied.map((e) => e.toJson()).toList()));
    widget.onDataChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S.isZh ? '已复制到今天' : 'Copied to today'),
        backgroundColor: const Color(0xFF2A2A2A),
      ));
    }
  }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ExercisePicker(onSelect: (name, group) {
        Navigator.pop(context);
        setState(() {
          _exercises.add(WorkoutExercise(
            name: name, muscleGroup: group,
            sets: [WorkoutSet(weight: 0, reps: 10)],
          ));
        });
        _save();
      }),
    );
  }

  int get _totalVolume => _exercises.fold(0, (s, ex) =>
    s + ex.sets.where((st) => st.isDone).fold(0, (ss, st) => ss + (st.weight * st.reps).toInt()));

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.dateKey,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      if (_loaded && _exercises.isNotEmpty)
                        Text(
                          '${_totalVolume}kg ${S.isZh ? "容量" : "vol"}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onToggleRestDay,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: widget.initialIsRestDay
                          ? Colors.blueAccent.withValues(alpha: 0.15)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: widget.initialIsRestDay ? Colors.blueAccent : Colors.grey[700]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.initialIsRestDay ? Icons.hotel : Icons.hotel_outlined,
                            size: 13,
                            color: widget.initialIsRestDay ? Colors.blueAccent : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          S.isZh
                              ? (widget.initialIsRestDay ? '休息日 ✓' : '设为休息日')
                              : (widget.initialIsRestDay ? 'Rest ✓' : 'Set Rest'),
                          style: TextStyle(
                              color: widget.initialIsRestDay ? Colors.blueAccent : Colors.grey,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: !_loaded
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
              : ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    _SectionHeader(
                      icon: Icons.fitness_center,
                      title: S.isZh ? '力量训练' : 'Strength Training',
                      trailing: _editMode
                        ? TextButton.icon(
                            onPressed: _addExercise,
                            icon: const Icon(Icons.add, size: 16, color: Color(0xFFFF6B35)),
                            label: Text(S.isZh ? '添加动作' : 'Add Exercise',
                              style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 13)),
                          )
                        : null,
                    ),
                    const SizedBox(height: 8),
                    if (_exercises.isEmpty)
                      _EmptyHint(S.isZh ? '这天没有训练记录' : 'No workout recorded')
                    else
                      ..._exercises.asMap().entries.map((e) {
                        final i = e.key;
                        final ex = e.value;
                        return _HistoryExerciseCard(
                          exercise: ex,
                          editMode: _editMode,
                          onChanged: () { setState(() {}); _save(); },
                          onDelete: () { setState(() => _exercises.removeAt(i)); _save(); },
                        );
                      }),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      icon: Icons.directions_run,
                      title: S.isZh ? '有氧跑步' : 'Aerobic Running',
                    ),
                    const SizedBox(height: 8),
                    if (_runs.isEmpty)
                      _EmptyHint(S.isZh ? '这天没有跑步记录' : 'No runs recorded')
                    else
                      ..._runs.map((r) => _RunHistoryCard(session: r)),
                  ],
                ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editMode ? const Color(0xFF4CAF50) : const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(_editMode ? Icons.check : Icons.edit_outlined, size: 18),
                      label: Text(_editMode
                        ? (S.isZh ? '完成编辑' : 'Done')
                        : (S.isZh ? '编辑数据' : 'Edit')),
                      onPressed: () => setState(() => _editMode = !_editMode),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_exercises.isNotEmpty)
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        label: Text(S.isZh ? '复制到今天' : 'Copy to Today'),
                        onPressed: _copyToToday,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.icon, required this.title, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 17),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
  );
}

class _HistoryExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final bool editMode;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  const _HistoryExerciseCard({
    required this.exercise,
    required this.editMode,
    required this.onChanged,
    required this.onDelete,
  });

  void _editSet(BuildContext context, WorkoutSet set) {
    final wCtrl = TextEditingController(
      text: set.weight == 0 ? '' : set.weight.toString().replaceAll('.0', ''));
    final rCtrl = TextEditingController(text: set.reps == 0 ? '' : set.reps.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(S.isZh ? '编辑组' : 'Edit Set',
          style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Row(
          children: [
            Expanded(child: TextField(
              controller: wCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: S.weightKg,
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF6B35))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: TextField(
              controller: rCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: S.repsHeader,
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF6B35))),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.isZh ? '取消' : 'Cancel', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              set.weight = double.tryParse(wCtrl.text) ?? set.weight;
              set.reps = int.tryParse(rCtrl.text) ?? set.reps;
              Navigator.pop(ctx);
              onChanged();
            },
            child: Text(S.isZh ? '保存' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // exercise header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(exercise.muscleGroup,
                    style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(exercise.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                if (editMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  Text(
                    '${exercise.sets.where((s) => s.isDone).length}/${exercise.sets.length} ${S.isZh ? "组" : "sets"}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 12, endIndent: 12),
          // sets list
          ...exercise.sets.asMap().entries.map((e) {
            final i = e.key;
            final set = e.value;
            return GestureDetector(
              onTap: editMode ? () => _editSet(context, set) : null,
              child: Container(
                color: set.isDone ? const Color(0xFFFF6B35).withValues(alpha: 0.05) : null,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text('${i + 1}',
                        style: TextStyle(
                          color: set.isDone ? const Color(0xFFFF6B35) : Colors.grey[600],
                          fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Expanded(
                      child: Text(
                        set.weight > 0
                          ? '${set.weight.toString().replaceAll('.0', '')} kg × ${set.reps}'
                          : '— × ${set.reps}',
                        style: TextStyle(
                          color: set.isDone ? Colors.white : Colors.grey[400],
                          fontSize: 13),
                      ),
                    ),
                    if (editMode)
                      GestureDetector(
                        onTap: () {
                          set.isDone = !set.isDone;
                          onChanged();
                        },
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: set.isDone ? const Color(0xFFFF6B35) : Colors.transparent,
                            border: Border.all(
                              color: set.isDone ? const Color(0xFFFF6B35) : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: set.isDone
                            ? const Icon(Icons.check, size: 15, color: Colors.white)
                            : null,
                        ),
                      )
                    else
                      Icon(
                        set.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: set.isDone ? const Color(0xFFFF6B35) : Colors.grey[700],
                      ),
                  ],
                ),
              ),
            );
          }),
          // add set (edit mode)
          if (editMode)
            TextButton.icon(
              onPressed: () {
                final last = exercise.sets.isNotEmpty ? exercise.sets.last : null;
                exercise.sets.add(WorkoutSet(weight: last?.weight ?? 0, reps: last?.reps ?? 10));
                onChanged();
              },
              icon: const Icon(Icons.add, size: 15, color: Colors.blueAccent),
              label: Text(S.isZh ? '添加组' : 'Add Set',
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
// ================= 统计卡片 =================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= 设置界面 =================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // BMR 数据
  String _gender = 'male';
  double _height = 0;
  double _weight = 0;
  int _age = 0;

  // API Keys
  String _owmApiKey = '';
  String _aqiToken = '';

  int get _bmr {
    if (_height <= 0 || _weight <= 0 || _age <= 0) return 0;
    // Mifflin-St Jeor 公式
    final base = (10 * _weight) + (6.25 * _height) - (5 * _age);
    return (_gender == 'male' ? base + 5 : base - 161).round();
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _langNotifier.addListener(_onLangChanged);
  }

  @override
  void dispose() {
    _langNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _onLangChanged() => setState(() {});

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gender = prefs.getString('bmr_gender') ?? 'male';
      _height = prefs.getDouble('bmr_height') ?? 0;
      _weight = prefs.getDouble('bmr_weight') ?? 0;
      _age = prefs.getInt('bmr_age') ?? 0;
      _owmApiKey = prefs.getString('owm_api_key') ?? 'a02de7717374e9741017a9904a3b0829';
      _aqiToken = prefs.getString('aqi_token') ?? 'a0493f0644b86d3f3b3de82855d86455425fd012';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bmr_gender', _gender);
    await prefs.setDouble('bmr_height', _height);
    await prefs.setDouble('bmr_weight', _weight);
    await prefs.setInt('bmr_age', _age);
  }

  void _showBmrDialog() {
    String gender = _gender;
    final heightCtrl = TextEditingController(text: _height > 0 ? _height.toStringAsFixed(0) : '');
    final weightCtrl = TextEditingController(text: _weight > 0 ? _weight.toStringAsFixed(0) : '');
    final ageCtrl = TextEditingController(text: _age > 0 ? _age.toString() : '');
    final weightFocus = FocusNode();
    final ageFocus = FocusNode();
    String activityLevel = 'sedentary';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setDialogState) {
          double h = double.tryParse(heightCtrl.text) ?? 0;
          double w = double.tryParse(weightCtrl.text) ?? 0;
          int a = int.tryParse(ageCtrl.text) ?? 0;
          int calculatedBmr = 0;
          int tdee = 0;
          if (h > 0 && w > 0 && a > 0) {
            final base = (10 * w) + (6.25 * h) - (5 * a);
            calculatedBmr = (gender == 'male' ? base + 5 : base - 161).round();
            const multipliers = {'sedentary': 1.2, 'light': 1.375, 'moderate': 1.55, 'active': 1.725};
            tdee = (calculatedBmr * (multipliers[activityLevel] ?? 1.2)).round();
          }

          final keyboardH = MediaQuery.of(sheetCtx).viewInsets.bottom;
          final screenH = MediaQuery.of(sheetCtx).size.height;
          final safeBottom = MediaQuery.of(sheetCtx).padding.bottom;

          // (screenH - keyboardH) * 0.65 shrinks the scroll area as the
          // keyboard rises, so header + scrollArea + footer + keyboardPadding
          // never exceeds the screen height.
          return Padding(
            padding: EdgeInsets.only(bottom: keyboardH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽把手
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2)),
                ),
                // 标题行
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(S.setBmr,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 可滚动内容
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (screenH - keyboardH - safeBottom) * 0.65,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 性别选择
                        Text(S.gender,
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _GenderButton(
                              label: S.male,
                              icon: Icons.male,
                              selected: gender == 'male',
                              onTap: () => setDialogState(() => gender = 'male'),
                            ),
                            const SizedBox(width: 12),
                            _GenderButton(
                              label: S.female,
                              icon: Icons.female,
                              selected: gender == 'female',
                              onTap: () => setDialogState(() => gender = 'female'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 身高
                        TextField(
                          controller: heightCtrl,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              labelText: S.height, hintText: S.heightHint),
                          onChanged: (_) => setDialogState(() {}),
                          onSubmitted: (_) => weightFocus.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        // 体重
                        TextField(
                          controller: weightCtrl,
                          focusNode: weightFocus,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              labelText: S.weightLabel, hintText: S.weightHint),
                          onChanged: (_) => setDialogState(() {}),
                          onSubmitted: (_) => ageFocus.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        // 年龄
                        TextField(
                          controller: ageCtrl,
                          focusNode: ageFocus,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              labelText: S.age, hintText: S.ageHint),
                          onChanged: (_) => setDialogState(() {}),
                          onSubmitted: (_) => ageFocus.unfocus(),
                        ),
                        // BMR 结果
                        if (calculatedBmr > 0) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              S.bmrResult(calculatedBmr),
                              style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 活动量
                          Text(S.activityLevel,
                              style:
                                  const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          _ActivityOption(
                              label: S.sedentary,
                              value: 'sedentary',
                              groupValue: activityLevel,
                              onChanged: (v) =>
                                  setDialogState(() => activityLevel = v)),
                          _ActivityOption(
                              label: S.lightlyActive,
                              value: 'light',
                              groupValue: activityLevel,
                              onChanged: (v) =>
                                  setDialogState(() => activityLevel = v)),
                          _ActivityOption(
                              label: S.moderatelyActive,
                              value: 'moderate',
                              groupValue: activityLevel,
                              onChanged: (v) =>
                                  setDialogState(() => activityLevel = v)),
                          _ActivityOption(
                              label: S.veryActive,
                              value: 'active',
                              groupValue: activityLevel,
                              onChanged: (v) =>
                                  setDialogState(() => activityLevel = v)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              S.tdeeResult(tdee),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // ── 固定底部按钮 ──
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: BorderSide(color: Colors.grey[700]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(S.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            // 1. Snapshot values while controllers are alive.
                            final g = gender;
                            final h = double.tryParse(heightCtrl.text) ?? 0;
                            final w = double.tryParse(weightCtrl.text) ?? 0;
                            final a = int.tryParse(ageCtrl.text) ?? 0;
                            // 2. Close sheet first — iOS dismisses keyboard
                            //    naturally during route removal, avoiding the
                            //    unfocus+pop race that freezes on iOS 26.
                            Navigator.pop(sheetCtx);
                            // 3. Update outer state and persist after pop.
                            setState(() {
                              _gender = g;
                              _height = h;
                              _weight = w;
                              _age = a;
                            });
                            _saveSettings();
                          },
                          child: Text(S.save),
                        ),
                      ),
                    ],
                  ),
                ),
                // iOS Home Indicator 安全区
                SizedBox(height: MediaQuery.of(sheetCtx).padding.bottom),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      heightCtrl.dispose();
      weightCtrl.dispose();
      ageCtrl.dispose();
      weightFocus.dispose();
      ageFocus.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bmrValue = _bmr;
    final hasBodyData = _height > 0 && _weight > 0 && _age > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.settings, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          // ── 身体数据 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.bodyDataSettings, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined, color: Color(0xFFFF6B35)),
            title: Text(S.bmrTitle),
            subtitle: Text(
              hasBodyData ? S.bmrResult(bmrValue) : S.bmrNotSetHint,
              style: TextStyle(color: hasBodyData ? const Color(0xFFFF6B35) : Colors.grey[600]),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _showBmrDialog,
          ),
          if (hasBodyData) ...[
            const Divider(height: 1, indent: 56),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BodyStatChip(label: S.height, value: '${_height.toStringAsFixed(0)} cm'),
                  _BodyStatChip(label: S.weightLabel, value: '${_weight.toStringAsFixed(1)} kg'),
                  _BodyStatChip(label: S.age, value: '$_age'),
                  _BodyStatChip(label: S.gender, value: _gender == 'male' ? S.male : S.female),
                ],
              ),
            ),
          ],

          // ── API 设置 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.isZh ? 'API 设置' : 'API Settings',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          _ApiKeyTile(
            icon: Icons.cloud_outlined,
            title: S.isZh ? 'OpenWeatherMap Key' : 'OpenWeatherMap Key',
            subtitle: S.isZh ? '用于获取实时天气数据' : 'For real-time weather data',
            value: _owmApiKey,
            onSaved: (val) async {
              setState(() => _owmApiKey = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('owm_api_key', val);
            },
          ),
          const Divider(height: 1, indent: 56),
          _ApiKeyTile(
            icon: Icons.air,
            title: S.isZh ? 'AQICN Token' : 'AQICN Token',
            subtitle: S.isZh ? '用于获取空气质量指数' : 'For air quality index',
            value: _aqiToken,
            onSaved: (val) async {
              setState(() => _aqiToken = val);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('aqi_token', val);
            },
          ),

          // ── 训练模版 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.isZh ? '训练' : 'Training', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          ListTile(
            leading: const Icon(Icons.library_books_outlined, color: Color(0xFFFF6B35)),
            title: Text(S.isZh ? '训练模版' : 'Workout Templates'),
            subtitle: Text(S.isZh ? '创建和管理常用训练计划' : 'Create & manage training plans'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _TemplateManagerPage()),
            ),
          ),

          // ── 外观与语言 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.isZh ? '外观与语言' : 'Appearance & Language',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          // 主题切换行
          ValueListenableBuilder<ThemeMode>(
            valueListenable: _themeNotifier,
            builder: (_, mode, child) => Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFFFF6B35)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(S.isZh ? '主题模式' : 'Theme',
                        style: const TextStyle(fontSize: 16)),
                  ),
                  _ThemeToggle(
                    currentMode: mode,
                    onChanged: (m) async {
                      _themeNotifier.value = m;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'theme_mode', m == ThemeMode.light ? 'light' : 'dark');
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 56),
          // 语言切换行
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.language, color: Color(0xFFFF6B35)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(S.languageLabel, style: const TextStyle(fontSize: 16)),
                ),
                _LangToggle(
                  currentLang: _langNotifier.value,
                  onChanged: (lang) async {
                    _langNotifier.value = lang;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('language', lang);
                  },
                ),
              ],
            ),
          ),

          // ── 关于 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(S.about, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: Text(S.version),
            trailing: Text('1.0.0', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

// 语言切换按钮
class _LangToggle extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const _LangToggle({required this.currentLang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LangChip(label: '中文', selected: currentLang == 'zh', onTap: () => onChanged('zh')),
        const SizedBox(width: 8),
        _LangChip(label: 'EN', selected: currentLang == 'en', onTap: () => onChanged('en')),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B35) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF6B35) : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// 主题切换按钮
class _ThemeToggle extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggle({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeChip(
          icon: Icons.light_mode,
          label: S.isZh ? '日间' : 'Light',
          selected: currentMode == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
        ),
        const SizedBox(width: 8),
        _ThemeChip(
          icon: Icons.dark_mode,
          label: S.isZh ? '夜间' : 'Dark',
          selected: currentMode == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip(
      {required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B35) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFFF6B35) : Colors.grey[500]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 性别选择按钮
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton(
      {required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF6B35) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFFFF6B35) : Colors.grey[700]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.grey,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

// 活动量单选项
class _ActivityOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _ActivityOption(
      {required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF6B35).withValues(alpha: 0.12) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? const Color(0xFFFF6B35) : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFFFF6B35) : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: selected ? Colors.white : Colors.grey[400]))),
          ],
        ),
      ),
    );
  }
}

// 身体数据小标签
class _BodyStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _BodyStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// API Key 输入 tile
class _ApiKeyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Future<void> Function(String) onSaved;

  const _ApiKeyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF6B35)),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? subtitle : '${value.substring(0, value.length.clamp(0, 8))}••••',
        style: TextStyle(color: value.isEmpty ? Colors.grey[600] : const Color(0xFF4CAF50), fontSize: 12),
      ),
      trailing: const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
      onTap: () {
        final ctrl = TextEditingController(text: value);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title, style: const TextStyle(fontSize: 15)),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: S.isZh ? '粘贴 API Key...' : 'Paste API key...',
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(S.cancel, style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(ctx);
                  onSaved(ctrl.text.trim());
                },
                child: Text(S.save),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= 训练模版 UI =================

class _TemplatePickerSheet extends StatefulWidget {
  final void Function(WorkoutTemplate) onImport;
  const _TemplatePickerSheet({required this.onImport});
  @override
  State<_TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<_TemplatePickerSheet> {
  List<WorkoutTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates().then((t) { if (mounted) setState(() => _templates = t); });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, ctrl) => Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(S.isZh ? '选择模版' : 'Select Template',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: _templates.isEmpty
                ? Center(child: Text(S.isZh ? '暂无模版' : 'No templates yet',
                    style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    controller: ctrl,
                    itemCount: _templates.length,
                    itemBuilder: (_, i) {
                      final t = _templates[i];
                      return ListTile(
                        leading: const Icon(Icons.library_books_outlined, color: Color(0xFFFF6B35)),
                        title: Text(t.name),
                        subtitle: Text(t.muscleGroups.join(', '),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        onTap: () { Navigator.pop(context); widget.onImport(t); },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SaveTemplateSheet extends StatefulWidget {
  final List<WorkoutExercise> exercises;
  const _SaveTemplateSheet({required this.exercises});
  @override
  State<_SaveTemplateSheet> createState() => _SaveTemplateSheetState();
}

class _SaveTemplateSheetState extends State<_SaveTemplateSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(margin: const EdgeInsets.only(top: 10, bottom: 4), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
            child: Text(S.isZh ? '保存为模版' : 'Save as Template',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: S.isZh ? '模版名称' : 'Template name',
                hintText: S.isZh ? '例：胸背日' : 'e.g. Push Day',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(S.cancel, style: const TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white),
                    onPressed: () async {
                      final name = _ctrl.text.trim();
                      if (name.isEmpty) return;
                      final muscles = widget.exercises.map((e) => e.muscleGroup).toSet().toList();
                      final t = WorkoutTemplate(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        muscleGroups: muscles,
                        exercises: widget.exercises,
                      );
                      final list = await _loadTemplates();
                      list.add(t);
                      await _saveTemplates(list);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(S.isZh ? '已保存为"$name"' : 'Saved as "$name"'),
                          backgroundColor: const Color(0xFF2A2A2A),
                        ));
                      }
                    },
                    child: Text(S.save),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _TemplateManagerPage extends StatefulWidget {
  const _TemplateManagerPage();
  @override
  State<_TemplateManagerPage> createState() => _TemplateManagerPageState();
}

class _TemplateManagerPageState extends State<_TemplateManagerPage> {
  List<WorkoutTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _load();
    _langNotifier.addListener(_onLangChanged);
  }

  @override
  void dispose() {
    _langNotifier.removeListener(_onLangChanged);
    super.dispose();
  }

  void _onLangChanged() => setState(() {});

  Future<void> _load() async {
    final t = await _loadTemplates();
    if (mounted) setState(() => _templates = t);
  }

  Future<void> _delete(int i) async {
    _templates.removeAt(i);
    await _saveTemplates(_templates);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.isZh ? '训练模版' : 'Workout Templates',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => _CreateEditTemplateSheet(onSave: (t) async {
                  final list = await _loadTemplates();
                  list.add(t);
                  await _saveTemplates(list);
                }),
              );
              _load();
            },
          ),
        ],
      ),
      body: _templates.isEmpty
          ? Center(child: Text(S.isZh ? '还没有模版，点击 + 创建' : 'No templates. Tap + to create.',
              style: TextStyle(color: Colors.grey[600])))
          : ListView.builder(
              itemCount: _templates.length,
              itemBuilder: (_, i) {
                final t = _templates[i];
                return ListTile(
                  leading: const Icon(Icons.library_books_outlined, color: Color(0xFFFF6B35)),
                  title: Text(t.name),
                  subtitle: Text('${t.exercises.length} ${S.isZh ? "动作" : "exercises"} · ${t.muscleGroups.join(", ")}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _delete(i),
                  ),
                );
              },
            ),
    );
  }
}

class _CreateEditTemplateSheet extends StatefulWidget {
  final Future<void> Function(WorkoutTemplate) onSave;
  const _CreateEditTemplateSheet({required this.onSave});
  @override
  State<_CreateEditTemplateSheet> createState() => _CreateEditTemplateSheetState();
}

class _CreateEditTemplateSheetState extends State<_CreateEditTemplateSheet> {
  final _nameCtrl = TextEditingController();
  final List<WorkoutExercise> _exercises = [];

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ExercisePicker(onSelect: (name, group) {
        Navigator.pop(context);
        setState(() => _exercises.add(WorkoutExercise(
          name: name, muscleGroup: group, sets: [WorkoutSet(reps: 10)])));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, ctrl) => Column(
        children: [
          Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(child: Text(S.isZh ? '新建模版' : 'New Template',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                  onPressed: () async {
                    final name = _nameCtrl.text.trim();
                    if (name.isEmpty || _exercises.isEmpty) return;
                    final muscles = _exercises.map((e) => e.muscleGroup).toSet().toList();
                    final t = WorkoutTemplate(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name, muscleGroups: muscles, exercises: _exercises,
                    );
                    await widget.onSave(t);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(S.save),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: S.isZh ? '模版名称' : 'Template name',
                hintText: S.isZh ? '例：腿部日' : 'e.g. Leg Day',
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              children: [
                ..._exercises.asMap().entries.map((e) => ListTile(
                  title: Text(e.value.name),
                  subtitle: Text(e.value.muscleGroup,
                      style: const TextStyle(color: Color(0xFFFF6B35), fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => setState(() => _exercises.removeAt(e.key)),
                  ),
                )),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add, color: Color(0xFFFF6B35)),
                  label: Text(S.isZh ? '添加动作' : 'Add Exercise',
                      style: const TextStyle(color: Color(0xFFFF6B35))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= 数据模型：跑步 =================

class RunEnvironmentData {
  final int aqi;
  final double tempC;
  final int humidity;
  final String weatherDesc;
  final double windSpeed;

  const RunEnvironmentData({
    this.aqi = 0,
    this.tempC = 0,
    this.humidity = 0,
    this.weatherDesc = '',
    this.windSpeed = 0,
  });

  String get aqiCategory {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String get aqiCategoryZh {
    if (aqi <= 50) return '优';
    if (aqi <= 100) return '良';
    if (aqi <= 150) return '轻度污染';
    if (aqi <= 200) return '中度污染';
    if (aqi <= 300) return '重度污染';
    return '严重污染';
  }

  Color get aqiColor {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return const Color(0xFF8B00FF);
    return const Color(0xFF7E0023);
  }

  bool get isSafeToRun => aqi == 0 || aqi <= 100;

  Map<String, dynamic> toJson() => {
    'aqi': aqi,
    'tempC': tempC,
    'humidity': humidity,
    'weatherDesc': weatherDesc,
    'windSpeed': windSpeed,
  };

  factory RunEnvironmentData.fromJson(Map<String, dynamic> j) =>
      RunEnvironmentData(
        aqi: (j['aqi'] as num?)?.toInt() ?? 0,
        tempC: (j['tempC'] as num?)?.toDouble() ?? 0,
        humidity: (j['humidity'] as num?)?.toInt() ?? 0,
        weatherDesc: j['weatherDesc'] as String? ?? '',
        windSpeed: (j['windSpeed'] as num?)?.toDouble() ?? 0,
      );
}

class RunSession {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final double distanceKm;
  final double avgPaceMinPerKm;
  final double avgSpeedKmh;
  final int totalSteps;
  final double avgCadenceSpm;
  final int caloriesBurned;
  final List<List<double>> routePoints;
  final RunEnvironmentData env;

  const RunSession({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.distanceKm,
    required this.avgPaceMinPerKm,
    required this.avgSpeedKmh,
    required this.totalSteps,
    required this.avgCadenceSpm,
    required this.caloriesBurned,
    required this.routePoints,
    required this.env,
  });

  String get dateKey =>
      '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'durationSeconds': durationSeconds,
    'distanceKm': distanceKm,
    'avgPaceMinPerKm': avgPaceMinPerKm,
    'avgSpeedKmh': avgSpeedKmh,
    'totalSteps': totalSteps,
    'avgCadenceSpm': avgCadenceSpm,
    'caloriesBurned': caloriesBurned,
    'routePoints': routePoints,
    'env': env.toJson(),
  };

  factory RunSession.fromJson(Map<String, dynamic> j) => RunSession(
    id: j['id'] as String? ?? '',
    startTime: DateTime.parse(j['startTime'] as String),
    durationSeconds: (j['durationSeconds'] as num?)?.toInt() ?? 0,
    distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0,
    avgPaceMinPerKm: (j['avgPaceMinPerKm'] as num?)?.toDouble() ?? 0,
    avgSpeedKmh: (j['avgSpeedKmh'] as num?)?.toDouble() ?? 0,
    totalSteps: (j['totalSteps'] as num?)?.toInt() ?? 0,
    avgCadenceSpm: (j['avgCadenceSpm'] as num?)?.toDouble() ?? 0,
    caloriesBurned: (j['caloriesBurned'] as num?)?.toInt() ?? 0,
    routePoints: (j['routePoints'] as List? ?? [])
        .map((p) => (p as List).map((v) => (v as num).toDouble()).toList())
        .toList(),
    env: RunEnvironmentData.fromJson(
        j['env'] as Map<String, dynamic>? ?? {}),
  );
}

Future<List<RunSession>> _loadRunSessions() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('run_sessions');
  if (raw == null) return [];
  try {
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => RunSession.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> _saveRunSessions(List<RunSession> sessions) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      'run_sessions', jsonEncode(sessions.map((s) => s.toJson()).toList()));
}

Future<RunEnvironmentData> _fetchEnvironment(double lat, double lon) async {
  final prefs = await SharedPreferences.getInstance();
  const defaultOwmKey = 'a02de7717374e9741017a9904a3b0829';
  const defaultAqiToken = 'a0493f0644b86d3f3b3de82855d86455425fd012';
  final owmKey = prefs.getString('owm_api_key')?.isNotEmpty == true
      ? prefs.getString('owm_api_key')!
      : defaultOwmKey;
  final aqiToken = prefs.getString('aqi_token')?.isNotEmpty == true
      ? prefs.getString('aqi_token')!
      : defaultAqiToken;

  double tempC = 0;
  int humidity = 0;
  String weatherDesc = '';
  double windSpeed = 0;
  int aqi = 0;

  if (owmKey.isNotEmpty) {
    try {
      final resp = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$lat&lon=$lon&appid=$owmKey&units=metric',
      )).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final main = data['main'] as Map<String, dynamic>? ?? {};
        tempC = (main['temp'] as num?)?.toDouble() ?? 0;
        humidity = (main['humidity'] as num?)?.toInt() ?? 0;
        final weather = (data['weather'] as List?)?.first as Map<String, dynamic>?;
        weatherDesc = weather?['description'] as String? ?? '';
        final wind = data['wind'] as Map<String, dynamic>? ?? {};
        windSpeed = (wind['speed'] as num?)?.toDouble() ?? 0;
      }
    } catch (_) {}
  }

  if (aqiToken.isNotEmpty) {
    try {
      final resp = await http.get(Uri.parse(
        'https://api.waqi.info/feed/geo:$lat;$lon/?token=$aqiToken',
      )).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        if (data['status'] == 'ok') {
          aqi = ((data['data'] as Map<String, dynamic>)['aqi'] as num?)
                  ?.toInt() ??
              0;
        }
      }
    } catch (_) {}
  }

  return RunEnvironmentData(
    aqi: aqi,
    tempC: tempC,
    humidity: humidity,
    weatherDesc: weatherDesc,
    windSpeed: windSpeed,
  );
}

// ================= Splash Screen =================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MainNavigationScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.directions_run,
                    size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Urban FitLog',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connected Fitness',
                style: TextStyle(
                    fontSize: 14, color: Colors.grey, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= 有氧跑步页 =================

enum _RunState { idle, running, paused }

class AerobicPage extends StatefulWidget {
  const AerobicPage({super.key});

  @override
  State<AerobicPage> createState() => _AerobicPageState();
}

class _AerobicPageState extends State<AerobicPage> {
  _RunState _runState = _RunState.idle;

  // ── Event-processing gate — flip to false before any UI transition ──
  // Native streams keep running; their callbacks check this flag first.
  // This avoids calling .cancel() on main thread (which freezes iOS).
  bool _runActive = false;

  // ── Permission flags — set ONCE at init, never re-checked in button handlers ──
  bool _locGranted = false;
  bool _permInitDone = false;

  // Environment
  RunEnvironmentData? _envData;
  bool _envLoading = false;

  // GPS / Route
  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _gpsSub;
  double _distanceKm = 0;
  final MapController _mapController = MapController();

  // Timer
  Timer? _runTimer;
  int _durationSeconds = 0;

  // Pedometer (independent — no location permission needed)
  StreamSubscription<StepCount>? _stepSub;
  int _stepBaseline = -1;
  int _runSteps = 0;

  // Accelerometer cadence (independent — always available)
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _cadenceSpm = 0;
  int _peakCount = 0;
  DateTime _cadenceWindowStart = DateTime.now();
  double _lastMag = 0;

  // History
  List<RunSession> _history = [];

  double _bodyWeight = 70.0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _bodyWeight = p.getDouble('bmr_weight') ?? 70.0);
    });
    // All Geolocator async work happens here ONCE — never inside button handlers
    _initPermissions();
  }

  @override
  void dispose() {
    _cancelAllStreams();
    _mapController.dispose();
    super.dispose();
  }

  void _cancelAllStreams() {
    _gpsSub?.cancel();
    _gpsSub = null;
    _stepSub?.cancel();
    _stepSub = null;
    _accelSub?.cancel();
    _accelSub = null;
    _runTimer?.cancel();
  }

  // ── One-time permission request at page load ──
  // Asks for location on first visit. Stores result in _locGranted.
  // GPS/map/weather features activate if granted; all other features always work.
  Future<void> _initPermissions() async {
    if (_permInitDone) return;
    _permInitDone = true;
    try {
      LocationPermission lp = await Geolocator.checkPermission();
      if (lp == LocationPermission.denied) {
        lp = await Geolocator.requestPermission();
      }
      final granted = lp == LocationPermission.whileInUse ||
          lp == LocationPermission.always;
      if (!mounted) return;
      setState(() => _locGranted = granted);
      if (granted) _loadEnvironment();
    } catch (_) {
      // Device has no location — GPS features remain hidden
    }
  }

  Future<void> _loadHistory() async {
    final sessions = await _loadRunSessions();
    if (!mounted) return;
    setState(() => _history = sessions);
  }

  // Loads weather + AQI using cached GPS position.
  // No permission checks here — _locGranted is the gate.
  Future<void> _loadEnvironment() async {
    if (!_locGranted || !mounted) return;
    setState(() => _envLoading = true);
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        final env = await _fetchEnvironment(pos.latitude, pos.longitude);
        if (!mounted) return;
        setState(() => _envData = env);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _envLoading = false);
  }

  // ── FULLY SYNCHRONOUS — zero await, zero platform-channel calls ──
  // Safe to call from any button handler.
  void _startRun() {
    _runActive = true; // enable event processing BEFORE streams start
    setState(() {
      _runState = _RunState.running;
      _routePoints.clear();
      _distanceKm = 0;
      _durationSeconds = 0;
      _runSteps = 0;
      _stepBaseline = -1;
      _cadenceSpm = 0;
      _peakCount = 0;
      _cadenceWindowStart = DateTime.now();
      _lastMag = 0;
    });
    _startTimer();
    // Defer native sensor streams until AFTER the running view renders.
    // Starting sensors synchronously during the button handler floods the
    // event loop (60 Hz accelerometer events) before Flutter can render
    // the first frame → perceived freeze on tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_runActive) return;
      if (_accelSub == null) _startAccelerometer();
      if (_stepSub == null) _startStepCounter();
      if (_gpsSub == null && _locGranted) _startGps();
    });
  }

  void _startTimer() {
    _runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _durationSeconds++);
    });
  }

  void _startGps() {
    // 先主动获取一次当前位置作为起点，避免等待流的第一次回调
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((pos) {
      if (!_runActive || !mounted) return;
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _routePoints.add(latLng));
      _mapController.move(latLng, 17);
    }).catchError((_) {});

    // distanceFilter: 0 — 只要位置有变化就立即回调，不需要移动满5米
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    _gpsSub =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) {
        if (!_runActive || !mounted) return;
        final latLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          if (_routePoints.isNotEmpty) {
            final d = _haversineKm(_routePoints.last, latLng);
            if (d > 0.002) {
              _distanceKm += d;
              _routePoints.add(latLng);
            }
          } else {
            _routePoints.add(latLng);
          }
        });
        _mapController.move(latLng, 17);
      },
      onError: (e) {}, // 模拟器 kCLErrorLocationUnknown — 静默忽略
      cancelOnError: false,
    );
  }

  void _startStepCounter() {
    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount e) {
        if (!_runActive || !mounted) return;
        setState(() {
          if (_stepBaseline < 0) _stepBaseline = e.steps;
          _runSteps = (e.steps - _stepBaseline).clamp(0, 999999);
        });
      },
      cancelOnError: false,
    );
  }

  void _startAccelerometer() {
    const threshold = 12.0;
    const cadenceWindowSec = 5;
    _accelSub = accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 100))
        .listen(
      (event) {
        if (!_runActive) return;
        final mag =
            sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (_lastMag < threshold && mag >= threshold) _peakCount++;
        _lastMag = mag;
        final elapsed =
            DateTime.now().difference(_cadenceWindowStart).inSeconds;
        if (elapsed >= cadenceWindowSec) {
          final spm = (_peakCount / elapsed) * 60;
          if (mounted) {
            setState(() {
              _cadenceSpm = spm.clamp(0, 300);
              _peakCount = 0;
              _cadenceWindowStart = DateTime.now();
            });
          }
        }
      },
      onError: (e) {}, // simulator: no accelerometer hardware — silently ignore
      cancelOnError: false,
    );
  }

  double _haversineKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final sinA = sin(dLat / 2);
    final sinO = sin(dLon / 2);
    final h = sinA * sinA +
        cos(_deg2rad(a.latitude)) * cos(_deg2rad(b.latitude)) * sinO * sinO;
    return R * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  double _deg2rad(double deg) => deg * pi / 180;

  void _pauseRun() {
    // Gate event processing immediately — no native stream calls on main thread.
    // Native streams (GPS, accel, pedometer) keep running but their callbacks
    // return early because _runActive == false.
    _runActive = false;
    _runTimer?.cancel(); // pure Dart — safe to cancel synchronously
    setState(() => _runState = _RunState.paused);
  }

  void _resumeRun() {
    // Re-enable event processing and restart the Dart timer.
    // Native streams never stopped, so no need to restart them.
    _runActive = true;
    _startTimer();
    setState(() => _runState = _RunState.running);
  }

  void _stopRun() {
    // 1. Gate event processing — no native calls on main thread here.
    _runActive = false;
    _runTimer?.cancel(); // pure Dart — safe

    // 2. Build session synchronously from current snapshot values.
    final durationSecs = _durationSeconds;
    final distKm = _distanceKm;
    final steps = _runSteps;
    final cadence = _cadenceSpm;
    final routeSnapshot = List<LatLng>.from(_routePoints);
    final envSnapshot = _envData ?? const RunEnvironmentData();
    final hours = durationSecs / 3600;
    final calories = (8.0 * _bodyWeight * hours).round();
    final pace = distKm > 0 ? (durationSecs / 60) / distKm : 0.0;
    final speed = hours > 0 ? distKm / hours : 0.0;

    final session = RunSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(Duration(seconds: durationSecs)),
      durationSeconds: durationSecs,
      distanceKm: distKm,
      avgPaceMinPerKm: pace,
      avgSpeedKmh: speed,
      totalSteps: steps,
      avgCadenceSpm: cadence,
      caloriesBurned: calories,
      routePoints: routeSnapshot.map((p) => [p.latitude, p.longitude]).toList(),
      env: envSnapshot,
    );

    // 3. Immediately return to idle and update history (synchronous setState).
    setState(() {
      _runState = _RunState.idle;
      _history.insert(0, session);
    });

    // 4. Persist to SharedPreferences in the background.
    _saveCurrentRun(session);
    // Streams keep running silently (gated by _runActive = false).
    // Only dispose() ever calls .cancel() — the correct iOS lifecycle point.
  }

  Future<void> _saveCurrentRun(RunSession session) async {
    final sessions = await _loadRunSessions();
    // Avoid duplicates if called twice
    if (sessions.any((s) => s.id == session.id)) return;
    sessions.insert(0, session);
    await _saveRunSessions(sessions);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.isZh ? '跑步记录已保存 ✓' : 'Run saved ✓')),
    );
  }

  String _formatDuration(int secs) {
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0 || paceMinPerKm.isInfinite || paceMinPerKm.isNaN) {
      return "--'--\"";
    }
    final m = paceMinPerKm.floor();
    final s = ((paceMinPerKm - m) * 60).round();
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  double get _currentPace {
    if (_distanceKm <= 0 || _durationSeconds <= 0) return 0;
    return (_durationSeconds / 60) / _distanceKm;
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps both views in the widget tree at all times.
    // FlutterMap inside the running view is never disposed → no NSURLSession
    // cancellation on iOS main thread → no freeze when stopping/pausing.
    return IndexedStack(
      index: _runState == _RunState.idle ? 0 : 1,
      children: [
        _buildIdleView(),
        _buildRunningView(),
      ],
    );
  }

  // ─── IDLE ───
  Widget _buildIdleView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.navRunning),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: S.isZh ? '刷新环境数据' : 'Refresh',
            onPressed: _loadEnvironment,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEnvCard(),
            const SizedBox(height: 16),
            _buildRecentRuns(),
            const SizedBox(height: 24),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow,
                    color: Colors.white, size: 28),
                label: Text(S.startRun,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                onPressed: _startRun,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvCard() {
    final env = _envData;
    return Card(
      color: const Color(0xFF1E1E1E),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Color(0xFFFF6B35), size: 20),
                const SizedBox(width: 8),
                Text(S.isZh ? '当前环境' : 'Environment',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (_envLoading)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFFF6B35))),
              ],
            ),
            const SizedBox(height: 12),
            if (env == null && !_envLoading)
              Text(
                  S.isZh
                      ? '暂无数据，请配置 API Key 并开启定位'
                      : 'No data — enable location and set API keys',
                  style: const TextStyle(color: Colors.grey))
            else if (env != null) ...[
              Row(
                children: [
                  _EnvChip(
                    label: S.isZh ? '空气质量' : 'AQI',
                    value: env.aqi > 0
                        ? '${env.aqi} ${S.isZh ? env.aqiCategoryZh : env.aqiCategory}'
                        : '--',
                    color: env.aqi > 0 ? env.aqiColor : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  _EnvChip(
                    label: S.isZh ? '温度' : 'Temp',
                    value: env.tempC != 0
                        ? '${env.tempC.toStringAsFixed(1)}°C'
                        : '--',
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  _EnvChip(
                    label: S.isZh ? '湿度' : 'Humidity',
                    value:
                        env.humidity != 0 ? '${env.humidity}%' : '--',
                    color: Colors.tealAccent,
                  ),
                ],
              ),
              if (env.weatherDesc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${S.isZh ? "天气：" : "Weather: "}${env.weatherDesc}'
                  '  ${S.isZh ? "风速：" : "Wind: "}${env.windSpeed.toStringAsFixed(1)} m/s',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (env.isSafeToRun ? Colors.green : Colors.orange)
                      .withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          env.isSafeToRun ? Colors.green : Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        env.isSafeToRun
                            ? Icons.check_circle
                            : Icons.warning,
                        color: env.isSafeToRun
                            ? Colors.green
                            : Colors.orange,
                        size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        env.aqi == 0
                            ? (S.isZh
                                ? '添加 API Key 以获取跑步建议'
                                : 'Add API keys for run advice')
                            : (env.isSafeToRun
                                ? (S.isZh ? '适宜跑步' : 'Safe to run')
                                : (S.isZh
                                    ? '空气质量较差，建议减少户外运动'
                                    : 'Poor air quality — consider indoors')),
                        style: TextStyle(
                          color: env.isSafeToRun
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRuns() {
    if (_history.isEmpty) {
      return Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(S.isZh ? '还没有跑步记录' : 'No runs yet',
                style: const TextStyle(color: Colors.grey)),
          ),
        ),
      );
    }
    final recent = _history.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(S.isZh ? '最近跑步' : 'Recent Runs',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...recent.map((s) => _RunHistoryCard(session: s)),
      ],
    );
  }

  // ─── RUNNING / PAUSED ───
  Widget _buildRunningView() {
    final isPaused = _runState == _RunState.paused;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // OpenStreetMap via flutter_map.
                  // Kept alive by IndexedStack — never disposed during
                  // pause/stop, so no NSURLSession cancel freeze on iOS.
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _routePoints.isNotEmpty
                          ? _routePoints.last
                          : const LatLng(51.5074, -0.1278),
                      initialZoom: 17,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ethanhxy.fitnessapp',
                      ),
                      if (_routePoints.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              strokeWidth: 4,
                              color: const Color(0xFFFF6B35),
                            ),
                          ],
                        ),
                      if (_routePoints.isNotEmpty)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _routePoints.last,
                              width: 22,
                              height: 22,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38, blurRadius: 4)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      // GPS 信号等待提示（还没有位置点时显示）
                      if (_routePoints.isEmpty)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.gps_not_fixed,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  _locGranted
                                      ? (S.isZh
                                          ? '正在获取 GPS 信号...'
                                          : 'Acquiring GPS...')
                                      : (S.isZh
                                          ? 'GPS 未授权'
                                          : 'GPS not permitted'),
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isPaused)
                    Container(
                      color: Colors.black45,
                      child: Center(
                        child: Text(
                          S.isZh ? '已暂停' : 'PAUSED',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                color: const Color(0xFF121212),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _StatCell(
                            label: S.isZh ? '距离' : 'Distance',
                            value: _distanceKm.toStringAsFixed(2),
                            unit: 'km'),
                        _StatCell(
                            label: S.isZh ? '配速' : 'Pace',
                            value: _formatPace(_currentPace),
                            unit: '/km'),
                        _StatCell(
                            label: S.isZh ? '时间' : 'Duration',
                            value: _formatDuration(_durationSeconds),
                            unit: ''),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCell(
                            label: S.isZh ? '步数' : 'Steps',
                            value: _runSteps.toString(),
                            unit: ''),
                        _StatCell(
                            label: S.isZh ? '步频' : 'Cadence',
                            value: _cadenceSpm.toStringAsFixed(0),
                            unit: 'spm'),
                        _StatCell(
                          label: S.isZh ? '空气质量' : 'AQI',
                          value: (_envData?.aqi ?? 0) > 0
                              ? _envData!.aqi.toString()
                              : '--',
                          unit: '',
                          valueColor: (_envData?.aqi ?? 0) > 0
                              ? _envData!.aqiColor
                              : Colors.grey,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2A),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            icon: Icon(
                                isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: Colors.white),
                            label: Text(
                                isPaused
                                    ? (S.isZh ? '继续' : 'Resume')
                                    : (S.isZh ? '暂停' : 'Pause'),
                                style: const TextStyle(
                                    color: Colors.white)),
                            onPressed:
                                isPaused ? _resumeRun : _pauseRun,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.stop,
                                color: Colors.white),
                            label: Text(
                                S.isZh ? '结束跑步' : 'Stop Run',
                                style: const TextStyle(
                                    color: Colors.white)),
                            onPressed: _stopRun,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ─── Aerobic helper widgets ───

class _EnvChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _EnvChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value, unit;
  final Color? valueColor;
  const _StatCell(
      {required this.label,
      required this.value,
      required this.unit,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          if (unit.isNotEmpty)
            Text(unit,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11)),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}


class _RunHistoryCard extends StatelessWidget {
  final RunSession session;
  const _RunHistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final dt = session.startTime;
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final dur = session.durationSeconds;
    final m = dur ~/ 60;
    final s = dur % 60;
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.directions_run,
                color: Color(0xFFFF6B35)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  Text(
                      '${session.distanceKm.toStringAsFixed(2)} km',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Text(
                '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
