import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) =>'');
final forceReload = StateProvider((ref) => false);

//Booking State
final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) =>'' );
final selectedSalon = StateProvider((ref) => '');
// final selectedBarber = StateProvider((ref) => BarberModel());
// final selectedDate = StateProvider((ref) => DateTime.now());
// final selectedTimeSlot = StateProvider((ref) => -1);
// final selectedTime = StateProvider((ref) => '');