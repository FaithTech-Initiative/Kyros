import 'dart:convert';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_ai/firebase_ai.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/main_note_page.dart';
import 'package:kyros/highlighted_verses_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kyros/auth_screen.dart';
import 'package:kyros/profile_screen.dart';
import 'package:kyros/settings_screen.dart';
import 'package:kyros/study_tools_screen.dart';
import 'package:kyros/my_wiki_screen.dart';
import 'package:kyros/expanding_fab.dart';
import 'package:kyros/database.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _widgetOptions = <Widget>[
      HomeScreenContent(
        userId: widget.userId,
        navigateToNotePage: _navigateToNotePage,
        searchQuery: _searchQuery,
      ),
      const BibleLookupScreen(),
      const StudyToolsScreen(),
      const MyWikiScreen(),
    ];
  }

  void _navigateToNotePage(BuildContext context, {Note? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MainNotePage(userId: widget.userId, note: note)),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    _widgetOptions[0] = HomeScreenContent(
      userId: widget.userId,
      navigateToNotePage: _navigateToNotePage,
      searchQuery: _searchQuery,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isSearchField = child.key == const ValueKey('search-field');
            final offsetAnimation = Tween<Offset>(
              begin: isSearchField
                  ? const Offset(1.0, 0.0)
                  : const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return ClipRRect(
              child: SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
          child: _isSearchActive
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  child: TextField(
                    key: const ValueKey('search-field'),
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      filled: true,
                      fillColor: theme.colorScheme.surface.withAlpha(245),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                            color: theme.colorScheme.onSurface.withAlpha(80),
                            width: 1.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(150)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                    style: TextStyle(
                        color: theme.colorScheme.onSurface, fontSize: 18.0),
                  ),
                )
              : Text(
                  key: const ValueKey('app-title'),
                  'Kyros',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: _isSearchActive
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Study Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: 'My Wiki',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Giving functionality
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.colorScheme.primary,
                          side: BorderSide(
                              color: theme.colorScheme.onPrimary, width: 1.0),
                        ),
                        child: const Text('Give Now'),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()));
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.displayName ?? 'No Name',
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary, fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?.email ?? 'No Email',
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.collections_bookmark),
                title: const Text('Collections'),
                onTap: () {
                  Navigator.pushNamed(context, '/collections');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Highlights'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const HighlightedVersesScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive),
                title: const Text('Archive'),
                onTap: () {
                  // TODO: Implement Archive functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Trash'),
                onTap: () {
                  // TODO: Implement Trash functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  // TODO: Implement About functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism),
                title: const Text('Giving'),
                onTap: () {
                  // TODO: Implement Giving functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Setting'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Feedback'),
                onTap: () {
                  // TODO: Implement Help & Feedback functionality
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ExpandingFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () {
              // TODO: Implement Audio functionality
            },
            icon: const Icon(Icons.mic),
            label: 'Audio',
          ),
          ActionButton(
            onPressed: () {
              // TODO: Implement Image functionality
            },
            icon: const Icon(Icons.image),
            label: 'Image',
          ),
          ActionButton(
            onPressed: () => _navigateToNotePage(context),
            icon: const Icon(Icons.edit),
            label: 'New Note',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class HomeScreenContent extends StatefulWidget {
  final String userId;
  final Function(BuildContext, {Note? note}) navigateToNotePage;
  final String searchQuery;
  const HomeScreenContent({
    super.key,
    required this.userId,
    required this.navigateToNotePage,
    required this.searchQuery,
  });

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late final FirestoreService _firestoreService;
  late Stream<List<Note>> _notesStream;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _notesStream = _firestoreService.getNotes(widget.userId);
  }

  String _getPlainText(String jsonString) {
    if (jsonString.isEmpty) return '';
    try {
      final json = jsonDecode(jsonString) as List<dynamic>;
      final buffer = StringBuffer();
      for (var item in json) {
        if (item is Map<String, dynamic> && item.containsKey('insert')) {
          buffer.write(item['insert']);
        }
      }
      return buffer.toString().replaceAll('\n', ' ').trim();
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Note>>(
      stream: _notesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.note_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  'You have no notes yet.',
                  style: GoogleFonts.lato(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap the "+" button to create your first note!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        } else {
          final allNotes = snapshot.data!;
          final filteredNotes = allNotes.where((note) {
            final title = note.title.toLowerCase();
            final content = _getPlainText(note.content).toLowerCase();
            final query = widget.searchQuery.toLowerCase();
            return title.contains(query) || content.contains(query);
          }).toList();

          if (filteredNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No notes found.',
                    style: GoogleFonts.lato(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Try a different search term or create a new note.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                final plainTextContent = _getPlainText(note.content);

                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () =>
                            widget.navigateToNotePage(context, note: note),
                        child: Card(
                          elevation: 4.0,
                          shadowColor: theme.colorScheme.primary.withAlpha(75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title,
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    plainTextContent,
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(180),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  timeago.format(note.updatedAt),
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
