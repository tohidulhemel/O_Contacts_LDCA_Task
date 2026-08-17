import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_form.dart';

class EditContactScreen extends StatelessWidget {
  final Contact contact;

  const EditContactScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final contactService = ContactService();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact')),
      body: ContactForm(
        initialContact: contact,
        submitButtonText: 'Update Contact',
        onSubmit: (updatedContact) async {
          try {
            await contactService.updateContact(updatedContact);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact updated successfully')),
            );
            Navigator.pop(context, true); // true tells caller data changed
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
              ),
            );
          }
        },
      ),
    );
  }
}