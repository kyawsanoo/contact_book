import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sample/contact.dart';
import 'contact_detail_screen.dart';
import 'contacts_controller.dart';
import 'contacts_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ContactsController contactController;
  late List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    contactController = Provider.of<ContactsController>(context, listen: true);
    contacts = contactController.contacts;
    debugPrint("contacts size ${contacts.length}");

    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContactsEditScreen(),
            ),
          );
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF80DFEA),
            borderRadius: BorderRadius.circular(200),
          ),
          child: const Center(
            child: Text(
              "+",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFEAEFEF),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: contactController.isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Contacts",
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF46F35D),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    itemCount: contacts.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isThirdNote = (index + 1) % 3 == 0;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ContactDetailScreen(
                                contact: contacts[index],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB855F1)/*ColorConstant.notesBg[index % 5]*/,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contacts[index].name,
                                style: GoogleFonts.montserrat(
                                  fontSize: isThirdNote ? 32 : 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "***",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: /*ColorConstant
                                      .noteTextBg[index % 5]
                                      .withOpacity(1)*/const Color(0xFF0C0A0A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    staggeredTileBuilder: (int index) =>
                    StaggeredTile.count(
                        (index + 1) % 3 == 0 ? 2 : 1, 1),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

