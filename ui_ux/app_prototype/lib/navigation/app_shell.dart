import 'dart:io' show Platform;

import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:app_prototype/features/profile/setup/profile_setup_screen.dart';
import 'package:app_prototype/navigation/debug_inspector_footer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/widgets.dart';
import '../state/ui_state.dart';
import '../data/models/models.dart';
import 'bottom_nav.dart';
import '../features/home/home_screen.dart';
import '../features/home/exercise_detail_screen.dart';
import '../features/home/tip_screen.dart';
import '../features/plans/plans_screen.dart';
import '../features/plans/plan_detail_screen.dart';
import '../features/plans/plan_training_screen.dart';
import '../features/plans/plan_create_screen.dart';
import '../features/plans/recommendation_flow.dart';
import '../features/plans/new_plan_choice_sheet.dart';
import '../features/plans/add_exercise_screen.dart';
import '../features/plans/exercises_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/progress/calendar_fullscreen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/profile_drawer.dart';
import '../features/profile/profile_edit_sheet.dart';

// GGF. PFAD ZU DEINER MAIN / DEM FOOTER-WIDGET ANPASSEN:
import 'package:app_prototype/main.dart';

enum SubView {
  none,
  userSetup,
  profile,
  profileEdit,
  exerciseDetail,
  planDetail,
  planTraining,
  tip,
  planCreate,
  recommend,
  addExercise,
  library,
  calendarFull,
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;
  SubView _sub = SubView.none;

  bool _profileOpen = false;
  bool _editOpen = false;
  String? _selectedId;
  DateTime? _calendarInitialDate;

  void _openProfile() => setState(() => _profileOpen = true);

  void _openTip() => setState(() => _sub = SubView.tip);

  void _openCalendar(DateTime date) => setState(() {
    _calendarInitialDate = date;
    _sub = SubView.calendarFull;
  });

  void _closeSub() => setState(() {
    _sub = SubView.none;
    _selectedId = null;
  });

  void _openExercise(String id) => setState(() {
    _selectedId = id;
    _sub = SubView.exerciseDetail;
  });

  void _openPlan(String id) => setState(() {
    _selectedId = id;
    _sub = SubView.planDetail;
  });

  void _startTraining(String id) => setState(() {
    _selectedId = id;
    _sub = SubView.planTraining;
  });

  void _openAddExercise(String id) => setState(() {
    _selectedId = id;
    _sub = SubView.addExercise;
  });

  void _showNewPlanChoices() {
    NewPlanChoiceSheet.show(
      context,
      onRecommend: () => setState(() => _sub = SubView.recommend),
      onManual: () => setState(() => _sub = SubView.planCreate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();

    if (app.toast != null) {
      Future.delayed(AppMotion.toastDuration, () {
        if (mounted && app.toast != null) app.clearToast();
      });
    }

    Widget screen;
    bool showNav = true;
    final userProvider = context.watch<UserProvider>();

    if (!userProvider.userExists) {
      screen = UserSetupScreen(
        "Profil erstellen",
        onFinished: () {
          setState(() {
            _tab = AppTab.home;
            _sub = SubView.none;
          });
        },
      );
      showNav = false;
    } else if (_sub == SubView.profileEdit) {
      screen = UserSetupScreen(
        "Profil bearbeiten",
        isEdit: true,
        onBack: () {
          setState(() {
            _sub = SubView.profile;
          });
        },
        onFinished: () {
          context.read<UserProvider>().init();
          setState(() {
            _sub = SubView.profile;
          });
        },
      );
      showNav = false;
    } else if (_sub == SubView.profile) {
      screen = ProfileScreen(
        onBack: _closeSub,
        onEdit: () {
          setState(() {
            _sub = SubView.profileEdit;
          });
        },
      );
      showNav = false;
    } else if (_sub == SubView.tip) {
      screen = TipScreen(onBack: _closeSub);
      showNav = false;
    } else if (_sub == SubView.planCreate) {
      screen = PlanCreateScreen(
        onBack: _closeSub,
        onSaved: () {
          _closeSub();
          setState(() => _tab = AppTab.plans);
        },
      );
      showNav = false;
    } else if (_sub == SubView.recommend) {
      screen = RecommendationFlow(
        onBack: _closeSub,
        onSaved: () {
          _closeSub();
          setState(() => _tab = AppTab.plans);
        },
      );
      showNav = false;
    } else if (_sub == SubView.addExercise && _selectedId != null) {
      screen = AddExerciseScreen(
        planId: _selectedId!,
        onBack: () => setState(() => _sub = SubView.planDetail),
        onAdded: () => setState(() => _sub = SubView.planDetail),
      );
      showNav = false;
    } else if (_sub == SubView.library) {
      screen = ExercisesScreen(
        onOpenProfile: _openProfile,
        onOpenExercise: _openExercise,
      );
      showNav = false;
    } else if (_sub == SubView.calendarFull) {
      screen = CalendarFullscreen(
        onBack: _closeSub,
        initialDate: _calendarInitialDate ?? DateTime.now(),
      );
      showNav = false;
    } else if (_sub == SubView.exerciseDetail && _selectedId != null) {
      screen = ExerciseDetailScreen(
        exerciseId: _selectedId!,
        onBack: _closeSub,
      );
      showNav = false;
    } else if (_sub == SubView.planDetail && _selectedId != null) {
      screen = PlanDetailScreen(
        planId: _selectedId!,
        onBack: _closeSub,
        onStartTraining: _startTraining,
        onAddExercise: _openAddExercise,
      );
      showNav = false;
    } else if (_sub == SubView.planTraining && _selectedId != null) {
      screen = PlanTrainingScreen(
        planId: _selectedId!,
        onExit: _closeSub,
        onFinish: () {
          context.read<UiState>().finishTraining(_selectedId!);
          _closeSub();
          setState(() => _tab = AppTab.plans);
        },
      );
      showNav = false;
    } else {
      switch (_tab) {
        case AppTab.home:
          screen = HomeScreen(
            onOpenProfile: _openProfile,
            onStartTraining: (plan) => _startTraining(plan.id),
          );
          break;
        case AppTab.plans:
          screen = PlansScreen(
            onOpenProfile: _openProfile,
            onOpenPlan: _openPlan,
            onAddPlan: _showNewPlanChoices,
          );
          break;
        case AppTab.progress:
          screen = ProgressScreen(
            onOpenProfile: _openProfile,
            onOpenCalendar: _openCalendar,
          );
          break;
      }
    }

    return PhoneFrame(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: screen),
                    if (app.toast != null) AppToast(message: app.toast!),
                  ],
                ),
              ),
              if (showNav)
                BottomNav(
                  active: _tab,
                  onChange: (t) => setState(() {
                    _tab = t;
                    _sub = SubView.none;
                  }),
                  onAddPlan: _showNewPlanChoices,
                ),

              // Zeigt den Isar Inspector Link im Debug-Modus unten an
              const DebugInspectorFooter(),
            ],
          ),

          if (_profileOpen)
            ProfileDrawer(
              onClose: () => setState(() => _profileOpen = false),
              onEditProfile: () => setState(() => _editOpen = true),
            ),

          if (_editOpen)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, cons) => Stack(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _editOpen = false),
                      child: Container(color: const Color(0x59000000)),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: cons.maxHeight * 0.94,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          child: ColoredBox(
                            color: AppColors.cream,
                            child: ProfileEditSheet(
                              onClose: () => setState(() => _editOpen = false),
                            ),
                          ),
                        ),
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

/// Handy-Rahmen der Demo-Ansicht. Public, damit auch das Intro (vor dem
/// AppShell) im selben Rahmen läuft und nicht im Vollbild erscheint.
///
/// Der Rahmen ist nur eine Hilfe für die Desktop- und Web-Vorschau: Dort wird
/// die App in einem großen Fenster gezeigt und soll trotzdem wie auf einem
/// Handy wirken. Auf einem echten Handy oder Tablet wäre er ein doppelter
/// Rahmen im Display und wird deshalb weggelassen.
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  /// Echte Mobilgeräte: kein simulierter Rahmen.
  static bool get _isMobileDevice {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    if (_isMobileDevice) {
      return Scaffold(backgroundColor: AppColors.cream, body: child);
    }

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 800),
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: const Color(0xFF1B1B1B), width: 7),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
