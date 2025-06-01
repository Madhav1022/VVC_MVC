import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
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

  Future<void> _loadContact() async {
    try {
      final contact = await _controller.getContactById(widget.id);
      if (mounted) {
        setState(() {
          _contact = contact;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading contact: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        backgroundColor: const Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contact == null
          ? const Center(child: Text('Contact not found'))
          : FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (context, dirSnap) {
          if (!dirSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Determine image widget
          final imgRef = _contact!.image;
          Widget imageWidget;
          if (imgRef.startsWith('http')) {
            imageWidget = Image.network(
              imgRef,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            );
          } else {
            final file = File(p.join(dirSnap.data!.path, imgRef));
            imageWidget = file.existsSync()
                ? Image.file(
              file,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.person, size: 100, color: Colors.grey);
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              imageWidget,
              const SizedBox(height: 16),

              // Name
              if (_contact!.name.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.name,
                  icon: Icons.person,
                  color: Colors.purple,
                ),

              // Mobile
              if (_contact!.mobile.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.mobile,
                  icon: Icons.phone,
                  color: Colors.green,
                  onTap: () => _callContact(_contact!.mobile),
                ),

              // Email
              if (_contact!.email.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.email,
                  icon: Icons.email,
                  color: Colors.red,
                  onTap: () => _emailContact(_contact!.email),
                ),

              // Address
              if (_contact!.address.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.address,
                  icon: Icons.location_on,
                  color: Colors.purple,
                  onTap: () => _openMap(_contact!.address),
                ),

              // Website
              if (_contact!.website.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.website,
                  icon: Icons.web,
                  color: Colors.blue,
                  onTap: () => _openWebsite(_contact!.website),
                ),

              // Company
              if (_contact!.company.isNotEmpty)
                _buildDetailRow(
                  label: _contact!.company,
                  icon: Icons.business,
                  color: Colors.teal,
                ),

              // Designation
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
          child: Text(label,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis),
        ),
        IconButton(onPressed: onTap, icon: Icon(icon, color: color)),
      ],
    );
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _emailContact(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String addr) async {
    final uri = Uri.parse(
        Theme.of(context).platform == TargetPlatform.iOS
            ? 'https://maps.apple.com/?q=$addr'
            : 'geo:0,0?q=$addr');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}






















