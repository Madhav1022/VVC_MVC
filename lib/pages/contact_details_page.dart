import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/contact_list_controller.dart';
import '../models/contact_model.dart';

class ContactDetailsPage extends StatefulWidget {
  static const String routeName = 'details';
  final int id;
  const ContactDetailsPage({super.key, required this.id});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage> {
  final ContactListController _controller = ContactListController();
  ContactModel? _contact;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  void _loadContact() async {
    final contact = await _controller.getContactById(widget.id);
    if (mounted) {
      setState(() {
        _contact = contact;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contact == null
          ? const Center(child: Text('Contact not found'))
          : FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (context, dirSnapshot) {
          if (!dirSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final String fullPath = '${dirSnapshot.data!.path}/${_contact!.image}';
          final File file = File(fullPath);

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // Displaying Image or Placeholder
              file.existsSync()
                  ? Image.file(file, width: double.infinity, height: 250, fit: BoxFit.cover)
                  : const Icon(Icons.person, size: 100, color: Colors.grey),

              const SizedBox(height: 16),

              if (_contact!.name.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.name,
                  icon: Icons.person,
                  color: Colors.purple,
                ),

              if (_contact!.mobile.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.mobile,
                  onTap: () => _callContact(_contact!.mobile),
                  icon: Icons.phone,
                  color: Colors.green,
                ),

              if (_contact!.email.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.email,
                  onTap: () => _emailContact(_contact!.email),
                  icon: Icons.email,
                  color: Colors.red,
                ),

              if (_contact!.address.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.address,
                  onTap: () => _openMap(_contact!.address),
                  icon: Icons.location_on,
                  color: Colors.purple,
                ),

              if (_contact!.website.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.website,
                  onTap: () => _openWebsite(_contact!.website),
                  icon: Icons.web,
                  color: Colors.blue,
                ),

              if (_contact!.company.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.company,
                  icon: Icons.business,
                  color: Colors.teal,
                ),

              if (_contact!.designation.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.designation,
                  icon: Icons.work,
                  color: Colors.orange,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color),
        ),
      ],
    );
  }

  Future<void> _callContact(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Cannot make call.');
    }
  }

  Future<void> _emailContact(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Cannot send email.');
    }
  }

  Future<void> _openMap(String address) async {
    final Uri url = Uri.parse(Platform.isAndroid
        ? 'geo:0,0?q=$address'
        : 'https://maps.apple.com/?q=$address');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Cannot open map.');
    }
  }

  Future<void> _openWebsite(String website) async {
    final Uri url = Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError('Cannot open website.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

