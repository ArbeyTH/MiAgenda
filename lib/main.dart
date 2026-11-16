
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


const MethodChannel pipChannel =
MethodChannel('com.arbey.miagenda/pip');

void main() {
  runApp(const MiAgendaApp());
}

class MiAgendaApp extends StatelessWidget {
  const MiAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MiAgenda',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5378E8),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class AgendaTask {
  String title;
  DateTime date;
  TimeOfDay start;
  TimeOfDay end;
  Color color;
  IconData icon;
  bool completed;

  AgendaTask({
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.color,
    required this.icon,
    this.completed = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  DateTime selectedDate = _dateOnly(DateTime.now());

  DateTime visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  final List<AgendaTask> tasks = [
    AgendaTask(
      title: 'Ir al gimnasio',
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      start: const TimeOfDay(hour: 7, minute: 0),
      end: const TimeOfDay(hour: 8, minute: 0),
      color: const Color(0xFF5B82E8),
      icon: Icons.fitness_center,
      completed: true,
    ),
    AgendaTask(
      title: 'Estudiar programación',
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 0),
      color: const Color(0xFF9B72D8),
      icon: Icons.code,
    ),
    AgendaTask(
      title: 'Realizar tareas',
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      start: const TimeOfDay(hour: 12, minute: 0),
      end: const TimeOfDay(hour: 14, minute: 0),
      color: const Color(0xFFE89B53),
      icon: Icons.menu_book,
    ),
    AgendaTask(
      title: 'Tiempo libre',
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      start: const TimeOfDay(hour: 17, minute: 0),
      end: const TimeOfDay(hour: 18, minute: 0),
      color: const Color(0xFF42A99A),
      icon: Icons.self_improvement,
    ),
  ];

  String get currentDate {
    const days = [
      'domingo', 'lunes', 'martes', 'miércoles',
      'jueves', 'viernes', 'sábado'
    ];

    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo',
      'junio', 'julio', 'agosto', 'septiembre',
      'octubre', 'noviembre', 'diciembre'
    ];

    final now = DateTime.now();

    return '${days[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]}';
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo',
      'junio', 'julio', 'agosto', 'septiembre',
      'octubre', 'noviembre', 'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String formatMonth(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo',
      'Junio', 'Julio', 'Agosto', 'Septiembre',
      'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  int get completedTasks =>
      tasks.where((task) =>
      isSameDay(task.date, DateTime.now()) &&
          task.completed).length;

  int get pendingTasks =>
      tasks.where((task) =>
      isSameDay(task.date, DateTime.now()) &&
          !task.completed).length;

  List<AgendaTask> get todayTasks {
    final result = tasks
        .where((task) => isSameDay(task.date, DateTime.now()))
        .toList();

    result.sort((a, b) {
      final aMinutes = a.start.hour * 60 + a.start.minute;
      final bMinutes = b.start.hour * 60 + b.start.minute;
      return aMinutes.compareTo(bMinutes);
    });

    return result;
  }

  List<AgendaTask> get selectedDayTasks {
    final result = tasks
        .where((task) => isSameDay(task.date, selectedDate))
        .toList();

    result.sort((a, b) {
      final aMinutes = a.start.hour * 60 + a.start.minute;
      final bMinutes = b.start.hour * 60 + b.start.minute;
      return aMinutes.compareTo(bMinutes);
    });

    return result;
  }

  void toggleTask(AgendaTask task) {
    setState(() {
      task.completed = !task.completed;
    });
  }

  Future<void> _showTestPipAd() async {
    try {
      final message = await pipChannel.invokeMethod<String>(
        'loadAndShowPipAd',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'Solicitud de anuncio enviada.'),
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Error al cargar el anuncio.'),
        ),
      );
    } on MissingPluginException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el canal nativo de anuncios.'),
        ),
      );
    }
  }

  Future<void> addTask() async {
    final initialDate = selectedIndex == 2
        ? selectedDate
        : _dateOnly(DateTime.now());

    final newTask = await showModalBottomSheet<AgendaTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        initialDate: initialDate,
      ),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0
            ? buildHome()
            : selectedIndex == 2
            ? buildCalendar()
            : buildComingSoon(),
      ),
      floatingActionButton: selectedIndex == 0 || selectedIndex == 2
          ? FloatingActionButton(
        onPressed: addTask,
        backgroundColor: const Color(0xFF5378E8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE7ECFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_kanban_outlined),
            label: 'Tablero',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF5378E8),
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MiAgenda',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202A44),
                    ),
                  ),
                  Text(
                    'Organiza tu tiempo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          '¡Hola! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202A44),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currentDate,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF7B849A),
          ),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            buildStatCard(
              'Total',
              todayTasks.length.toString(),
              Icons.checklist_rounded,
              const Color(0xFFE7ECFF),
              const Color(0xFF5378E8),
            ),
            const SizedBox(width: 10),
            buildStatCard(
              'Hechas',
              completedTasks.toString(),
              Icons.check_circle_outline,
              const Color(0xFFE1F5EC),
              const Color(0xFF249C70),
            ),
            const SizedBox(width: 10),
            buildStatCard(
              'Pendientes',
              pendingTasks.toString(),
              Icons.access_time_rounded,
              const Color(0xFFFFF0DD),
              const Color(0xFFE89B53),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'Mi agenda de hoy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202A44),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Organiza tus actividades durante el día',
          style: TextStyle(
            color: Color(0xFF8992A5),
            fontSize: 13,
          ),
        ),


        const SizedBox(height: 15),

        FilledButton.icon(
          onPressed: _showTestPipAd,
          icon: const Icon(Icons.picture_in_picture_alt),
          label: const Text('Mostrar anuncio de prueba'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF5378E8),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        const SizedBox(height: 15),



        const SizedBox(height: 18),
        if (todayTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              'Todavía no tienes actividades. '
                  'Presiona + para agregar una.',
              textAlign: TextAlign.center,
            ),
          ),
        ...todayTasks.map((task) => buildTaskCard(task)),
      ],
    );
  }

  Widget buildStatCard(
      String label,
      String value,
      IconData icon,
      Color background,
      Color foreground,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: foreground, size: 21),
            ),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202A44),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8992A5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskCard(AgendaTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDF0F6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(task.start),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF202A44),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatTime(task.end),
                  style: const TextStyle(
                    color: Color(0xFF8992A5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: task.color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.completed
                        ? Colors.grey
                        : const Color(0xFF202A44),
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.completed ? 'Completada' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 11,
                    color: task.completed
                        ? const Color(0xFF249C70)
                        : const Color(0xFF8992A5),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: task.completed,
            activeColor: const Color(0xFF249C70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (_) => toggleTask(task),
          ),
        ],
      ),
    );
  }

  Widget buildCalendar() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text(
          'Mi calendario',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202A44),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Organiza tus actividades por fecha',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8992A5),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatMonth(visibleMonth),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202A44),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Mes anterior',
                        onPressed: () {
                          setState(() {
                            visibleMonth = DateTime(
                              visibleMonth.year,
                              visibleMonth.month - 1,
                            );
                            selectedDate = visibleMonth;
                          });
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Mes siguiente',
                        onPressed: () {
                          setState(() {
                            visibleMonth = DateTime(
                              visibleMonth.year,
                              visibleMonth.month + 1,
                            );
                            selectedDate = visibleMonth;
                          });
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                    .map(
                      (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8992A5),
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 12),
              buildCalendarGrid(),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedDate = _dateOnly(DateTime.now());
                    visibleMonth = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                    );
                  });
                },
                icon: const Icon(Icons.today),
                label: const Text('Volver a hoy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'Actividades del ${formatDate(selectedDate)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202A44),
          ),
        ),
        const SizedBox(height: 14),
        if (selectedDayTasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 40,
                  color: Color(0xFF9AA5BC),
                ),
                SizedBox(height: 10),
                Text(
                  'No tienes actividades para este día.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8992A5)),
                ),
                SizedBox(height: 5),
                Text(
                  'Presiona + para programar una.',
                  style: TextStyle(
                    color: Color(0xFF8992A5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ...selectedDayTasks.map((task) => buildTaskCard(task)),
      ],
    );
  }

  Widget buildCalendarGrid() {
    final firstDay = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;

    final offset = firstDay.weekday - 1;
    final cells = ((offset + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 7,
        crossAxisSpacing: 3,
        childAspectRatio: 0.85,
      ),
      itemCount: cells,
      itemBuilder: (context, index) {
        final dayNumber = index - offset + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final day = DateTime(
          visibleMonth.year,
          visibleMonth.month,
          dayNumber,
        );

        final selected = isSameDay(day, selectedDate);
        final today = isSameDay(day, DateTime.now());

        final hasTasks = tasks.any(
              (task) => isSameDay(task.date, day),
        );

        return InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            setState(() {
              selectedDate = _dateOnly(day);
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5378E8)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: today && !selected
                      ? Border.all(
                    color: const Color(0xFF5378E8),
                    width: 1.5,
                  )
                      : null,
                ),
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontWeight: selected || today
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF202A44),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: hasTasks
                      ? const Color(0xFF5378E8)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildComingSoon() {
    final isAgenda = selectedIndex == 1;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAgenda ? Icons.schedule : Icons.view_kanban,
              size: 75,
              color: const Color(0xFF5378E8),
            ),
            const SizedBox(height: 20),
            Text(
              isAgenda ? 'Mi agenda de 24 horas' : 'Tablero Kanban',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202A44),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAgenda
                  ? 'Aquí podrás consultar todas las horas '
                  'y actividades de tu día.'
                  : 'Aquí podrás organizar tus tareas en '
                  'Pendiente, En progreso y Completado.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF8992A5),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  final DateTime initialDate;

  const AddTaskSheet({
    super.key,
    required this.initialDate,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController titleController =
  TextEditingController();

  late DateTime selectedDate;

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha de tu actividad',
    );

    if (date != null) {
      setState(() {
        selectedDate = DateTime(date.year, date.month, date.day);
      });
    }
  }

  Future<void> chooseTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? startTime : endTime,
      helpText: isStart ? 'Hora de inicio' : 'Hora de finalización',
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          startTime = time;
        } else {
          endTime = time;
        }
      });
    }
  }

  void saveTask() {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe el nombre de la actividad.'),
        ),
      );
      return;
    }

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La hora de finalización debe ser posterior al inicio.',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      AgendaTask(
        title: title,
        date: selectedDate,
        start: startTime,
        end: endTime,
        color: const Color(0xFF5378E8),
        icon: Icons.event_note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        20,
        22,
        MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nueva actividad',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202A44),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nombre de la actividad',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ej. Estudiar Flutter',
                prefixIcon: const Icon(Icons.edit_note),
                filled: true,
                fillColor: const Color(0xFFF5F7FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fecha',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: chooseDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Horario',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => chooseTime(true),
                    child: Text('Inicio: ${formatTime(startTime)}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => chooseTime(false),
                    child: Text('Fin: ${formatTime(endTime)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: saveTask,
                icon: const Icon(Icons.add),
                label: const Text('Guardar actividad'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
