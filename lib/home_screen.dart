import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/bible_lookup_screen.dart';
import 'package:kyros/note_screen.dart';
import 'package:kyros/highlighted_verses_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kyros/auth_screen.dart';
import 'package:kyros/profile_screen.dart';

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

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreenContent(userId: widget.userId),
      const BibleLookupScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _scaffoldKey.currentState!.openDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0.0,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          child: _isSearchActive
              ? TextField(
                  key: const ValueKey('search-field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  onChanged: (value) {
                    // TODO: Implement search logic
                  },
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
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
            icon: Icon(Icons.book),
            label: 'Bible',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? 'No Name'),
                accountEmail: Text(user?.email ?? 'No Email'),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                  },
                  child: CircleAvatar(
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                          )
                        : null,
                  ),
                ),
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
                  // TODO: Implement Setting functionality
                  Navigator.pop(context);
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
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final String userId;
  const HomeScreenContent({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Welcome Back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'What would you like to do today?',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withAlpha(178),
            ),
          ),
          const SizedBox(height: 30),
          _buildQuickJotCard(context),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context,
            icon: Icons.edit,
            label: 'My Notes',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen(userId: userId)));
            },
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context,
            icon: Icons.bookmark,
            label: 'Highlighted Verses',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HighlightedVersesScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJotCard(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController quickJotController = TextEditingController();
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withAlpha(102),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: quickJotController,
              decoration: const InputDecoration(
                hintText: 'Jot down a quick thought...',
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Save the quick jot
              },
              child: const Text('Save Jot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withAlpha(102),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
              Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
