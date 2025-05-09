import 'package:flutter/material.dart';
import 'package:healthadmin/models/appointment_model.dart';
import 'package:healthadmin/services/firestore_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add appointment
  Future<bool> addAppointment(AppointmentModel appointment) async {
    try {
      _setLoading(true);
      await FirestoreService.addAppointment(appointment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user appointments
  void loadUserAppointments(String userId) {
    FirestoreService.getUserAppointmentsStream(userId).listen((appointments) {
      _appointments = appointments;
      notifyListeners();
    });
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(
      String appointmentId,
      AppointmentStatus status,
      ) async {
    try {
      _setLoading(true);
      await FirestoreService.updateAppointmentStatus(appointmentId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}