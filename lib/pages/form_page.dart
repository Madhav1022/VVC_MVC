import 'package:flutter/material.dart';
import '../controllers/contact_list_controller.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';
import 'package:go_router/go_router.dart';
import 'homepage.dart';

class FormPage extends StatefulWidget {
  static const String routeName = 'form';
  final ContactModel contactModel;

  const FormPage({
    super.key,
    required this.contactModel,
  });

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final ContactListController _controller = ContactListController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final companyController = TextEditingController();
  final designationController = TextEditingController();
  final webController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    nameController.text = widget.contactModel.name;
    mobileController.text = widget.contactModel.mobile;
    emailController.text = widget.contactModel.email;
    addressController.text = widget.contactModel.address;
    companyController.text = widget.contactModel.company;
    designationController.text = widget.contactModel.designation;
    webController.text = widget.contactModel.website;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Page'),
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextField(nameController, 'Contact Name', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(mobileController, 'Mobile Number',
                keyboardType: TextInputType.phone, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(addressController, 'Street Address'),
            const SizedBox(height: 16),
            _buildTextField(companyController, 'Company Name'),
            const SizedBox(height: 16),
            _buildTextField(designationController, 'Designation'),
            const SizedBox(height: 16),
            _buildTextField(webController, 'Website'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return emptyFieldErrMsg;
        }
        return null;
      },
    );
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        final contact = ContactModel(
          id: widget.contactModel.id,
          name: nameController.text,
          mobile: mobileController.text,
          email: emailController.text,
          address: addressController.text,
          company: companyController.text,
          designation: designationController.text,
          website: webController.text,
          image: widget.contactModel.image,
          favorite: widget.contactModel.favorite,
        );

        await _controller.addContact(contact);

        if (mounted) {
          showMsg(context, 'Saved');
          context.goNamed(HomePage.routeName);
        }
      } catch (error) {
        showMsg(context, 'Failed to save');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    companyController.dispose();
    designationController.dispose();
    webController.dispose();
    super.dispose();
  }
}