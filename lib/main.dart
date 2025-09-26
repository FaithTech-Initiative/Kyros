import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ChurchPadApp());
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
      home: const HomeScreen(),
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
  int _selectedFilter = 0; // 0: All, 1: Favorites, 2: Tags
  bool _isGrid = false;
  bool _showArcMenu = false;
  int _currentIndex = 0;
  bool _sortAsc = true;

  final List<_Note> _notes = [
    _Note('Sunday Service Notes', isFavorite: true),
    _Note('Bible Study: John 3', isFavorite: false),
    _Note('Prayer Points', isFavorite: true),
    _Note('Youth Meeting', isFavorite: false),
    _Note('Choir Practice', isFavorite: false),
    _Note('Outreach Plan', isFavorite: false),
    _Note('Thanksgiving List', isFavorite: false),
    _Note('Sermon: Faith & Works', isFavorite: true),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Note> get _filteredNotes {
    List<_Note> filtered = List.of(_notes);
    if (_selectedFilter == 1) {
      filtered = filtered.where((note) => note.isFavorite).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((note) => note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    filtered.sort((a, b) => _sortAsc
        ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
        : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final double fabBottom = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 16;

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
                  builder: (context) => const _FullScreenProfileCard(),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/profile.jpg'),
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
              _HomePageContent(
                isGrid: _isGrid,
                selectedFilter: _selectedFilter,
                filteredNotes: _filteredNotes,
                onToggleGrid: () => setState(() => _isGrid = !_isGrid),
                onSelectFilter: (int index) => setState(() => _selectedFilter = index),
                sortAsc: _sortAsc,
                onToggleSort: () => setState(() => _sortAsc = !_sortAsc),
              ),
              const Center(child: Text('Shared (coming soon)')),
              const Center(child: Text('Menu (coming soon)')),
            ],
          ),
          if (_currentIndex == 0 && _showArcMenu) ..._buildArcMenuButtons(fabBottom),
          if (_currentIndex == 0)
            Positioned(
              right: 24,
              bottom: fabBottom,
              child: FloatingActionButton(
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
          NavigationDestination(icon: Icon(Icons.group), label: 'Shared'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  List<Widget> _buildArcMenuButtons(double baseBottom) {
    final List<_ArcMenuItem> items = [
      _ArcMenuItem(icon: Icons.mic, label: 'Audio', color: Colors.deepPurple),
      _ArcMenuItem(icon: Icons.image, label: 'Image', color: Colors.green),
      _ArcMenuItem(icon: Icons.brush, label: 'Drawing', color: Colors.orange),
      _ArcMenuItem(icon: Icons.text_fields, label: 'Text', color: Colors.blue),
    ];
    const double radius = 120;
    const double startAngle = 180;
    const double sweep = 90;
    final double step = sweep / (items.length - 1);

    return List.generate(items.length, (i) {
      final angle = (startAngle - step * i) * (pi / 180);
      return Positioned(
        right: 24 - radius * cos(angle),
        bottom: baseBottom + radius * sin(angle),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: items[i].color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 6,
          ),
          icon: Icon(items[i].icon, size: 20),
          label: Text(items[i].label),
          onPressed: () {},
        ),
      );
    });
  }
}

class _FullScreenProfileCard extends StatelessWidget {
  const _FullScreenProfileCard();

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
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            const SizedBox(height: 16),
            const Text('Hi, Philip!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            const Text('philzybreeze19@gmail.com', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
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
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('Donate Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  onPressed: () {},
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

class _Note {
  final String title;
  final bool isFavorite;
  _Note(this.title, {this.isFavorite = false});
}

class _ArcMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  _ArcMenuItem({required this.icon, required this.label, required this.color});
}

class _HomePageContent extends StatelessWidget {
  final bool isGrid;
  final int selectedFilter;
  final List<_Note> filteredNotes;
  final VoidCallback onToggleGrid;
  final Function(int) onSelectFilter;
  final bool sortAsc;
  final VoidCallback onToggleSort;

  const _HomePageContent({
    required this.isGrid,
    required this.selectedFilter,
    required this.filteredNotes,
    required this.onToggleGrid,
    required this.onSelectFilter,
    required this.sortAsc,
    required this.onToggleSort,
  });

  @override
  Widget build(BuildContext context) {
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
            _NoteGridView(notes: filteredNotes)
          else
            _NoteListView(notes: filteredNotes),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _NoteGridView extends StatelessWidget {
  final List<_Note> notes;
  const _NoteGridView({required this.notes});
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
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, color: note.isFavorite ? Colors.amber : Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(note.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 3, overflow: TextOverflow.ellipsis),
                const Spacer(),
                if (note.isFavorite) const Align(alignment: Alignment.bottomRight, child: Icon(Icons.star, color: Colors.amber, size: 20)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoteListView extends StatelessWidget {
  final List<_Note> notes;
  const _NoteListView({required this.notes});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: notes.map((note) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text(note.title),
          leading: Icon(Icons.note, color: note.isFavorite ? Colors.amber : Theme.of(context).colorScheme.primary),
          trailing: note.isFavorite ? const Icon(Icons.star, color: Colors.amber) : null,
        ),
      )).toList(),
    );
  }
}
