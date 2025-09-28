import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:myapp/database.dart';
import 'package:myapp/note_repository.dart';
import 'note_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'firebase_options.dart';
import 'auth_screen.dart';
import 'bible_lookup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChurchPadApp());
}

String _getPlainText(String content) {
  if (content.isEmpty) return '';
  try {
    final json = jsonDecode(content);
    final doc = quill.Document.fromJson(json);
    return doc.toPlainText().replaceAll('\n', ' ').trim();
  } catch (e) {
    return content.replaceAll('\n', ' ').trim();
  }
}

class ChurchPadApp extends StatelessWidget {
  const ChurchPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.latoTextTheme();

    return MaterialApp(
      title: 'ChurchPad Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE5EDF8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF334155),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return const HomeScreen();
          }
          return const AuthScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilter = 0;
  bool _isGrid = false;
  bool _showArcMenu = false;
  int _currentIndex = 0;
  bool _sortAsc = true;

  late final NoteRepository _noteRepository;
  late Future<List<Note>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _noteRepository = NoteRepository(AppDatabase());
    _notesFuture = _noteRepository.getNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = _noteRepository.getNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteScreen()),
    );
    if (result == true) {
      _refreshNotes();
    }
  }

  void _openFileUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FileUploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Search your notes',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => _FullScreenProfileCard(user: user),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/illustration.png') as ImageProvider,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              FutureBuilder<List<Note>>(
                future: _notesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final notes = snapshot.data ?? [];
                  return _HomePageContent(
                    notes: notes,
                    isGrid: _isGrid,
                    selectedFilter: _selectedFilter,
                    searchQuery: _searchQuery,
                    onToggleGrid: () => setState(() => _isGrid = !_isGrid),
                    onSelectFilter: (int index) => setState(() => _selectedFilter = index),
                    sortAsc: _sortAsc,
                    onToggleSort: () => setState(() => _sortAsc = !_sortAsc),
                    noteRepository: _noteRepository,
                    onNoteUpdated: _refreshNotes,
                  );
                },
              ),
              const BibleLookupScreen(),
              const Center(child: Text('Shared (coming soon)')),
              const Center(child: Text('Menu (coming soon)')),
            ],
          ),
          if (_showArcMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showArcMenu = false),
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                ),
              ),
            ),
          ..._buildArcMenuButtons(24.0),
          if (_currentIndex == 0)
            Positioned(
              right: 16,
              bottom: 24.0,
              child: FloatingActionButton(
                heroTag: 'main_fab',
                onPressed: () => setState(() => _showArcMenu = !_showArcMenu),
                child: Icon(_showArcMenu ? Icons.close : Icons.add),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          setState(() {
            _currentIndex = i;
            if (i != 0) _showArcMenu = false;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Bible'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Shared'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  List<Widget> _buildArcMenuButtons(double fabBottom) {
    final List<_ArcMenuItem> items = [
      _ArcMenuItem(icon: Icons.mic, label: 'Audio', color: Colors.deepPurple, onPressed: () {}),
      _ArcMenuItem(icon: Icons.image, label: 'Image', color: Colors.green, onPressed: () {}),
      _ArcMenuItem(icon: Icons.brush, label: 'Drawing', color: Colors.orange, onPressed: () {}),
      _ArcMenuItem(icon: Icons.text_fields, label: 'Text', color: Colors.blue, onPressed: _addNote),
      _ArcMenuItem(icon: Icons.upload_file, label: 'Upload', color: Colors.red, onPressed: _openFileUpload),
    ];

    const double radius = 130.0;
    const double startAngle = pi;
    const double endAngle = pi / 3;
    const double sweepAngle = startAngle - endAngle;
    final double angleStep = sweepAngle / (items.length - 1);

    return List.generate(items.length, (i) {
      final double angle = startAngle - (i * angleStep);
      final double x = cos(angle) * radius;
      final double y = sin(angle) * radius;

      return Positioned(
        right: 16 - x,
        bottom: fabBottom + y,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showArcMenu ? 1.0 : 0.0,
          child: Transform.scale(
            scale: _showArcMenu ? 1.0 : 0.0,
            child: Tooltip(
              message: items[i].label,
              child: FloatingActionButton(
                heroTag: 'fab_arc_$i',
                backgroundColor: items[i].color,
                onPressed: () {
                  setState(() => _showArcMenu = false);
                  items[i].onPressed();
                },
                child: Icon(items[i].icon, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    });
  }
}
class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  UploadTask? _uploadTask;
  XFile? _pickedFile;
  double _progress = 0;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _startUpload() async {
    if (_pickedFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }
    final file = File(_pickedFile!.path);
    final fileName = _pickedFile!.name;
    final destination = 'uploads/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      setState(() {
        _uploadTask = ref.putFile(file);
      });

      _uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _progress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await _uploadTask!;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload complete!')),
      );
      if (mounted) {
        setState(() {
          _uploadTask = null;
          _pickedFile = null;
          _progress = 0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }

  void _pauseUpload() {
    _uploadTask?.pause();
  }

  void _resumeUpload() {
    _uploadTask?.resume();
  }

  void _cancelUpload() {
    _uploadTask?.cancel();
    setState(() {
      _uploadTask = null;
      _pickedFile = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick a File'),
            ),
            if (_pickedFile != null)
              Text('Selected file: ${_pickedFile!.name}'),
            const SizedBox(height: 20),
            if (_uploadTask != null)
              Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toStringAsFixed(2)}%'),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startUpload,
                  child: const Text('Start Upload'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pauseUpload,
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _resumeUpload,
                  child: const Text('Resume'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _cancelUpload,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenProfileCard extends StatelessWidget {
  final User? user;
  const _FullScreenProfileCard({this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28, color: Color(0xFF64748B)),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 48,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/illustration.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            if (user != null)
              Column(
                children: [
                  Text('Hi, ${user!.displayName ?? 'User'}!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(user!.email!, style: const TextStyle(fontSize: 16)),
                ],
              )
            else
              const Text('Hi, Guest!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 32),
            if (user == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.login),
                    label: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    },
                  ),
                ),
              ),
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => FirebaseAuth.instance.signOut(),
                  ),
                ),
              ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Privacy Policy'), SizedBox(width: 8), Text('•'), SizedBox(width: 8), Text('Terms of Service')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  _ArcMenuItem({required this.icon, required this.label, required this.color, required this.onPressed});
}

class _HomePageContent extends StatelessWidget {
  final List<Note> notes;
  final bool isGrid;
  final int selectedFilter;
  final String searchQuery;
  final VoidCallback onToggleGrid;
  final Function(int) onSelectFilter;
  final bool sortAsc;
  final VoidCallback onToggleSort;
  final NoteRepository noteRepository;
  final VoidCallback onNoteUpdated;

  const _HomePageContent({
    required this.notes,
    required this.isGrid,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onToggleGrid,
    required this.onSelectFilter,
    required this.sortAsc,
    required this.onToggleSort,
    required this.noteRepository,
    required this.onNoteUpdated,
  });

  @override
  Widget build(BuildContext context) {
    List<Note> filteredNotes = List.of(notes);
    if (selectedFilter == 1) {
      filteredNotes = filteredNotes.where((note) => note.isFavorite).toList();
    }
    if (searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes
          .where((note) => note.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    filteredNotes.sort((a, b) => sortAsc
        ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
        : b.title.toLowerCase().compareTo(a.title.toLowerCase()));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              FilterChip(label: const Text('All'), selected: selectedFilter == 0, onSelected: (_) => onSelectFilter(0)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Favorites'), selected: selectedFilter == 1, onSelected: (_) => onSelectFilter(1)),
              const SizedBox(width: 8),
              FilterChip(label: const Text('Tags'), selected: selectedFilter == 2, onSelected: (_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tags coming soon')));
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onToggleSort,
                child: Row(
                  children: [Text(sortAsc ? 'Title A–Z' : 'Title Z–A'), const Icon(Icons.swap_vert)],
                ),
              ),
              IconButton(
                icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
                onPressed: onToggleGrid,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (filteredNotes.isEmpty)
            Center(
              child: Column(
                children: [
                  Image.asset('assets/illustration.png', height: 180, fit: BoxFit.contain),
                  const SizedBox(height: 24),
                  const Text('Start creating your first note here.'),
                ],
              ),
            )
          else if (isGrid)
            _NoteGridView(notes: filteredNotes, noteRepository: noteRepository, onNoteUpdated: onNoteUpdated)
          else
            _NoteListView(notes: filteredNotes, noteRepository: noteRepository, onNoteUpdated: onNoteUpdated),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _NoteGridView extends StatelessWidget {
  final List<Note> notes;
  final NoteRepository noteRepository;
  final VoidCallback onNoteUpdated;

  const _NoteGridView({required this.notes, required this.noteRepository, required this.onNoteUpdated});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteScreen(note: note)),
            );
            if (result == true) {
              onNoteUpdated();
            }
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.note, color: note.isFavorite ? Colors.amber : Theme.of(context).colorScheme.primary),
                      IconButton(
                        icon: Icon(note.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
                        onPressed: () async {
                          final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
                          await noteRepository.updateNote(updatedNote);
                          onNoteUpdated();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(_getPlainText(note.content), style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoteListView extends StatelessWidget {
  final List<Note> notes;
  final NoteRepository noteRepository;
  final VoidCallback onNoteUpdated;

  const _NoteListView({required this.notes, required this.noteRepository, required this.onNoteUpdated});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: notes.map((note) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(note.title),
          subtitle: Text(_getPlainText(note.content), maxLines: 2, overflow: TextOverflow.ellipsis),
          leading: Icon(Icons.note, color: note.isFavorite ? Colors.amber : Theme.of(context).colorScheme.primary),
          trailing: IconButton(
            icon: Icon(note.isFavorite ? Icons.star : Icons.star_border, color: Colors.amber),
            onPressed: () async {
              final updatedNote = note.copyWith(isFavorite: !note.isFavorite);
              await noteRepository.updateNote(updatedNote);
              onNoteUpdated();
            },
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteScreen(note: note)),
            );
            if (result == true) {
              onNoteUpdated();
            }
          },
        ),
      )).toList(),
    );
  }
}
