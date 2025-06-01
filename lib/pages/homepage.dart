import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/contact_list_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/contact_model.dart';
import '../models/user_model.dart';
import '../utils/helper_functions.dart';
import 'camera_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final ContactListController _controller = ContactListController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _controller.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () async {
              // Navigate using pushNamed so we can await a result from ProfilePage.
              final result = await context.pushNamed(ProfilePage.routeName);
              // If the profile was updated, refresh the state to update the welcome message.
              if (result == true) {
                setState(() {});
              }
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newContact = ContactModel(
            name: '',
            mobile: '',
            email: '',
            address: '',
            company: '',
            designation: '',
            website: '',
            image: '',
            favorite: false,
            userId: _authController.userId ?? '',
          );
          context.goNamed(CameraPage.routeName, extra: newContact);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        elevation: 8,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Column(
        children: [
          // Welcome message via StreamBuilder so that any auth state changes are reflected.
          StreamBuilder<UserModel?>(
            stream: _authController.authStateChanges,
            builder: (context, snapshot) {
              final user = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome, ${user?.displayName ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6200EE),
                  ),
                ),
              );
            },
          ),
          // Contacts list
          Expanded(
            child: StreamBuilder<List<ContactModel>>(
              stream: _controller.contactStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contacts_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No contacts found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a contact',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final contact = snapshot.data![index];
                    return _buildContactCard(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 70, // Prevent overflow with increased height
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[100],
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
            _controller.loadContacts(favorites: index == 1);
          },
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xFF6200EE),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'All',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(ContactModel contact) {
    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, size: 25, color: Colors.white),
      ),
      confirmDismiss: _showConfirmationDialog,
      onDismissed: (_) async {
        await _controller.deleteContact(contact.id);
        showMsg(context, 'Deleted Successfully');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            contact.mobile,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          trailing: IconButton(
            onPressed: () async {
              await _controller.toggleFavorite(contact);
            },
            icon: Icon(
              contact.favorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.pink,
            ),
          ),
          onTap: () => context.go('/home/details/${contact.id}'),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(DismissDirection direction) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          OutlinedButton(
            onPressed: () => context.pop(false),
            child: const Text('NO'),
          ),
          OutlinedButton(
            onPressed: () => context.pop(true),
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }
}
