import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../widgets/contact_form.dart';

class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactService = ContactService();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Contact')),
      body: ContactForm(
        submitButtonText: 'Save Contact',
        onSubmit: (contact) async {
          try {
            await contactService.addContact(contact);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contact saved successfully')),
            );
            Navigator.pop(context);
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
