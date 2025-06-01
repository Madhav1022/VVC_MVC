import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:virtual_visiting_card_mvc/controllers/contact_controller.dart';
import 'package:virtual_visiting_card_mvc/models/contact_model.dart';
import 'package:go_router/go_router.dart';
import 'package:virtual_visiting_card_mvc/pages/form_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:virtual_visiting_card_mvc/utils/constants.dart';

class CameraPage extends StatefulWidget {
  static const String routeName = 'camera';
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ContactController controller = ContactController();
  bool isScanOver = false;
  List<String> lines = [];
  String name = '', mobile = '', email = '', company = '', designation = '', address = '', website = '', image = '';

  bool get isFormValid => name.isNotEmpty && mobile.isNotEmpty && email.isNotEmpty;

  void createContact() {
    final contact = ContactModel(
      name: name,
      mobile: mobile,
      email: email,
      address: address,
      company: company,
      designation: designation,
      website: website,
      image: image,
    );
    context.goNamed(FormPage.routeName, extra: contact);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Page'),
        backgroundColor: Color(0xFF6200EE),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: isFormValid ? createContact : null,
            icon: const Icon(Icons.arrow_forward),
            color: isFormValid ? Colors.white : Colors.grey.shade400,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Camera', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.deepPurple,
                  elevation: 5,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('Gallery', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.indigo,
                  elevation: 5,
                ),
              ),
            ],
          ),
          if (isScanOver)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    DragTargetItem(property: ContactProperties.name, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.mobile, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.email, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.company, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.designation, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.address, onDrop: getPropertyValue),
                    const SizedBox(height: 12),
                    DragTargetItem(property: ContactProperties.website, onDrop: getPropertyValue),
                  ],
                ),
              ),
            ),
          if (isScanOver)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(hint),
            ),
          Wrap(
            spacing: 8,
            children: lines.map((line) => LineItem(line: line)).toList(),
          )
        ],
      ),
    );
  }

  void getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      try {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';

        final File newImage = await File(pickedFile.path).copy(newPath);
        setState(() {
          image = fileName;
        });

        EasyLoading.show(status: "Processing...");

        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final recognizedText = await textRecognizer.processImage(InputImage.fromFile(newImage));
        EasyLoading.dismiss();

        final tempList = <String>[];
        for (var block in recognizedText.blocks) {
          for (var line in block.lines) {
            tempList.add(line.text);
          }
        }
        setState(() {
          lines = tempList;
          isScanOver = true;
        });

      } catch (e) {
        print('Error processing image: $e');
      }
    }
  }

  void getPropertyValue(String property, String value) {
    setState(() {
      switch (property) {
        case ContactProperties.name:
          name = name.isEmpty ? value : "$name $value";
          break;
        case ContactProperties.mobile:
          mobile = mobile.isEmpty ? value : "$mobile $value";
          break;
        case ContactProperties.email:
          email = email.isEmpty ? value : "$email, $value"; // Comma-separated for emails
          break;
        case ContactProperties.company:
          company = company.isEmpty ? value : "$company $value";
          break;
        case ContactProperties.designation:
          designation = designation.isEmpty ? value : "$designation $value";
          break;
        case ContactProperties.address:
          address = address.isEmpty ? value : "$address, $value"; // Comma-separated for addresses
          break;
        case ContactProperties.website:
          website = website.isEmpty ? value : "$website, $value"; // Comma-separated for websites
          break;
      }
    });
  }
}
class DragTargetItem extends StatefulWidget {
  final String property;
  final Function(String, String) onDrop;

  const DragTargetItem({super.key, required this.property, required this.onDrop});

  @override
  State<DragTargetItem> createState() => _DragTargetItemState();
}

class _DragTargetItemState extends State<DragTargetItem> {
  List<String> dragItems = []; // Store multiple dropped text values

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            widget.property,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          flex: 2,
          child: DragTarget<String>(
            builder: (context, candidateData, rejectedData) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.red, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dragItems.isEmpty ? 'Drop here' : dragItems.join(' '), // Joins multiple texts
                    ),
                  ),
                  if (dragItems.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          dragItems.clear(); // Clear all dropped text
                        });
                        widget.onDrop(widget.property, ''); // Reset value in parent
                      },
                      child: const Icon(Icons.clear, size: 15, color: Colors.red),
                    ),
                ],
              ),
            ),
            onAccept: (value) {
              setState(() {
                if (!dragItems.contains(value)) { // Prevent duplicates
                  dragItems.add(value);
                }
              });
              widget.onDrop(widget.property, dragItems.join(' ')); // Pass combined value
            },
          ),
        ),
      ],
    );
  }
}
class LineItem extends StatelessWidget {
  final String line;
  const LineItem({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: line,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          color: Colors.black38,
        ),
        child: Text(line, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
      ),
      child: Chip(
        label: Text(line),
      ),
    );
  }
}

