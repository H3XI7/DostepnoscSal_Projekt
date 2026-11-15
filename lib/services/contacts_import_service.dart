import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/contact_model.dart';
import 'database_helper.dart';

class ContactsImportService {
  static final ContactsImportService instance = ContactsImportService._();
  ContactsImportService._();

  Future<bool> requestPermission() async {
    try {
      return await FlutterContacts.requestPermission();
    } catch (_) {
      return false;
    }
  }

  Future<List<Contact>> getDeviceContacts() async {
    try {
      final granted = await FlutterContacts.requestPermission();
      if (!granted) return [];
      return await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
    } catch (_) {
      return [];
    }
  }

  Future<int> importContacts(
    List<Contact> deviceContacts, {
    String defaultCategory = 'Prywatny',
  }) async {
    int count = 0;
    final db = DatabaseHelper.instance;

    for (final c in deviceContacts) {
      String first = c.name.first.trim();
      String last = c.name.last.trim();

      if (first.isEmpty && last.isEmpty) {
        if (c.displayName.trim().isNotEmpty) {
          final parts = c.displayName.trim().split(' ');
          first = parts.first;
          if (parts.length > 1) {
            last = parts.sublist(1).join(' ');
          }
        }
      }

      // If still empty, use whatever display name exists or skip
      if (first.isEmpty && last.isEmpty) {
        if (c.displayName.isNotEmpty) {
          first = c.displayName;
        } else {
          continue;
        }
      }

      final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
      final email = c.emails.isNotEmpty ? c.emails.first.address : '';

      String street = '';
      String city = '';
      String postalCode = '';

      if (c.addresses.isNotEmpty) {
        final a = c.addresses.first;
        street = a.street.isNotEmpty ? a.street : a.address;
        city = a.city;
        postalCode = a.postalCode;
      }

      String notes = '';
      if (c.notes.isNotEmpty) {
        notes = c.notes.first.note;
      }

      final newContact = AddressContact(
        firstName: first,
        lastName: last,
        phone: phone,
        email: email,
        street: street,
        city: city,
        postalCode: postalCode,
        category: defaultCategory,
        notes: notes,
      );

      await db.insertContact(newContact);
      count++;
    }

    return count;
  }
}
