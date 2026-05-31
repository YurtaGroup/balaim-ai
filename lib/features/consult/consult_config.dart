// Consult configuration — transitioning from single-doctor dogfood
// to a multi-doctor directory (see Phase 1 of the Bishkek plan).
//
// Today: Jane Mone NP is the anchor doctor. The `kDoctor*` constants
// below are kept for backwards compatibility with the existing
// new-consult UI and the email-fallback gate in firestore.rules. They
// become metadata seeds for her `doctors/jane-mone` Firestore record
// once `setDoctorClaim` has been called for her.
//
// Tomorrow: this file becomes a thin re-export of helpers that read
// from the `doctors` collection (see [doctors_provider.dart]).
import '../../core/services/auth_service.dart';

/// The anchor doctor's Firebase Auth sign-in email. Used by the
/// transitional email-fallback in firestore.rules' `isDoctor()` until
/// Jane's account has been migrated by calling `setDoctorClaim`.
const String kDoctorEmail = 'jmone1@aol.com';

const String kDoctorName = 'Jane Mone, NP';
const String kDoctorSpecialty = 'Endocrinology';
const String kDoctorBlurb =
    'Board-certified nurse practitioner in endocrinology — diabetes, '
    'thyroid, and hormone health. Practicing in New Jersey, USA.';

/// Flat per-consultation price (USD). KG pricing lives on each
/// `doctors/{id}` Firestore record (`ratePerConsult` + `currency`).
const int kConsultPriceUsd = 49;

/// RevenueCat / App Store Connect consumable product id for one consult.
const String kConsultProductId = 'balam_consult';

/// True when the signed-in account is a doctor.
///
/// Reads the synchronously-cached custom claim first (populated by
/// `AuthService.initClaimWatcher`) — that's the post-migration path
/// for any onboarded doctor including new ones in the Bishkek roster.
/// Falls back to the email check for Jane Mone's account until her
/// claim has been assigned by `setDoctorClaim`.
bool get isDoctorAccount {
  if (AuthService().cachedDoctorClaim) return true;
  return (AuthService().currentEmail ?? '').toLowerCase() ==
      kDoctorEmail.toLowerCase();
}
