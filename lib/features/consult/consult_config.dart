// Single-doctor dogfood configuration.
//
// Balam's first consultation doctor is the founder's mother — an
// endocrinology NP. The whole consult feature is hardcoded to one
// doctor on purpose: it tests demand without a directory, a booking
// engine, or a doctor-onboarding flow. When doctor #2 joins, this
// constant set becomes a Firestore `doctors` collection.
import '../../core/services/auth_service.dart';

/// The doctor's Firebase Auth sign-in email. Signing in with this email
/// turns the app into the doctor inbox (see app_router redirect).
/// TODO: set to Jane's real sign-in email before the dogfood.
const String kDoctorEmail = 'jane.mone@balam.ai';

const String kDoctorName = 'Jane Mone, NP';
const String kDoctorSpecialty = 'Endocrinology';
const String kDoctorBlurb =
    'Board-certified nurse practitioner in endocrinology — diabetes, '
    'thyroid, and hormone health. Practicing in New Jersey, USA.';

/// Flat per-consultation price. The doctor sets this; change freely.
const int kConsultPriceUsd = 49;

/// RevenueCat / App Store Connect consumable product id for one consult.
const String kConsultProductId = 'balam_consult';

/// True when the signed-in account is the doctor.
bool get isDoctorAccount =>
    (AuthService().currentEmail ?? '').toLowerCase() ==
    kDoctorEmail.toLowerCase();
