import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'contact.dart';
import 'contacts_controller.dart';
import 'home_screen.dart';

class ContactsEditScreen extends StatefulWidget {
  Contact? contact;
  ContactsEditScreen({this.contact, super.key});

  @override
  State<ContactsEditScreen> createState() => _ContactsEditScreenState();
}

class _ContactsEditScreenState extends State<ContactsEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late ContactsController contactsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.contact != null ? widget.contact?.name : '');
    _companyController = TextEditingController(
        text: widget.contact != null ? widget.contact?.company : '');
    _phoneController = TextEditingController(
        text: widget.contact != null ? widget.contact?.phone : '');
  }

  handleCreateNote() async {
    Contact contact = Contact(
      '0',
      name: _nameController.text,
      company: _companyController.text,
      phone: _phoneController.text,
    );
    await contactsController.addContact(contact);
  }

  handleEditNote() async {
    Contact contact = Contact(
      widget.contact!.id,
      name: _nameController.text,
      company: _companyController.text,
      phone: _phoneController.text,
    );
    await contactsController.editContact(contact);
  }

  @override
  Widget build(BuildContext context) {
    contactsController = Provider.of<ContactsController>(context);
    return Scaffold(
      backgroundColor: Colors.black12,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: contactsController.isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (widget.contact == null) {
                            handleCreateNote();
                          } else {
                            handleEditNote();
                          }
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                                  (route) => false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            widget.contact == null ? "Create" : "Update",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[100],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.montserrat(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: " Name",
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _companyController,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                    decoration: InputDecoration(
                      hintText: " Company",
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _phoneController,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: " Phone",
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}