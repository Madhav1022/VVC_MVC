import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controllers/contact_list_controller.dart';
import '../models/contact_model.dart';
import '../utils/helper_functions.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final ContactListController _controller = ContactListController();

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
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
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
          );
          context.goNamed(CameraPage.routeName, extra: newContact);
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        elevation: 8,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: StreamBuilder<List<ContactModel>>(
        stream: _controller.contactStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found'));
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
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 70, // 👈 Increased height to prevent overflow
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
        alignment: FractionalOffset.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, size: 25, color: Colors.white),
      ),
      confirmDismiss: _showConfirmationDialog,
      onDismissed: (_) async {
        await _controller.deleteContact(contact.id);
        showMsg(context, 'Deleted Successfully');
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            contact.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          onTap: () => context.go('/details/${contact.id}'),
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
