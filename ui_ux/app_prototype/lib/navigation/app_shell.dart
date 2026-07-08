import 'package:app_prototype/data/provider/user_provider.dart';
import 'package:app_prototype/data/service/user_service.dart';
import 'package:app_prototype/features/profile/setup/profile_setup_screen.dart';
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
import '../features/profile/profile_screen.dart';

/// Unter-Ansichten, die über die Tabs hinausgehen (Detail-Screens).
/// Person 4 erweitert dieses Routing, wenn neue Detail-Screens dazukommen.
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
}

/// App-Shell — hält Tab- und Sub-View-Zustand, rendert den aktiven Screen,
/// die Bottom-Nav und das Toast-Overlay.
///
/// Bewusst mit lokalem [StatefulWidget]-Routing gehalten (kein Router-Paket),
/// damit der Aufbau dem JSX-Prototyp 1:1 entspricht und für ein Bachelor-
/// Projekt leicht nachvollziehbar bleibt.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;
  SubView _sub = SubView.none;

  /// ID des aktuell geöffneten Elements (Übung oder Plan).
  String? _selectedId;

  void _openProfile() => setState(() => _sub = SubView.profile);

  void _openTip() => setState(() => _sub = SubView.tip);

  void _closeSub() => setState(() {
    _sub = SubView.none;
    _selectedId = null;
  });

  // Öffnet die Übungs-Detailansicht. Bereit für eine antippbare Übungsliste
  // (Person 1) oder den Aufruf aus dem Plan-Detail (Person 2).
  // ignore: unused_element
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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<UiState>();

    // Toast automatisch nach Ablauf der Standard-Dauer schließen.
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
            onOpenTip: _openTip,
            onStartRegion: (region) {
              // Sucht den ersten aktiven Plan dieser Region und startet ihn.
              final app = context.read<UiState>();
              TrainingPlan? match;
              for (final p in app.activePlans) {
                if (p.region == region) {
                  match = p;
                  break;
                }
              }
              if (match != null) {
                _startTraining(match.id);
              } else {
                app.showToast('Für $region gibt es noch keinen Plan.');
              }
            },
          );
          break;
        case AppTab.plans:
          screen = PlansScreen(
            onOpenProfile: _openProfile,
            onOpenPlan: _openPlan,
            onOpenLibrary: () => setState(() => _sub = SubView.library),
          );
          break;
        case AppTab.progress:
          screen = ProgressScreen(onOpenProfile: _openProfile);
          break;
      }
    }

    return _PhoneFrame(
      child: Column(
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
              onAddPlan: () {
                NewPlanChoiceSheet.show(
                  context,
                  onRecommend: () => setState(() => _sub = SubView.recommend),
                  onManual: () => setState(() => _sub = SubView.planCreate),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Phone-Frame wie im JSX-Prototyp (für Web/Desktop-Vorschau).
/// Auf einem echten Gerät kann dieser Rahmen entfallen — dann direkt
/// das [child] in ein Scaffold setzen.
class _PhoneFrame extends StatelessWidget {
  final Widget child;

  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
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
