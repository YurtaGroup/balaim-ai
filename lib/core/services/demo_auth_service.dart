import 'dart:async';

enum UserRole { parent, admin, doctor, vendor }

class DemoUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;

  const DemoUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isDoctor => role == UserRole.doctor;
  bool get isVendor => role == UserRole.vendor;
  bool get isParent => role == UserRole.parent;
}

class DemoAuthService {
  static final DemoAuthService _instance = DemoAuthService._();
  factory DemoAuthService() => _instance;
  DemoAuthService._();

  final _controller = StreamController<DemoUser?>.broadcast();
  DemoUser? _currentUser;

  DemoUser? get currentUser => _currentUser;
  Stream<DemoUser?> get authStateChanges => _controller.stream;

  // Pre-built demo accounts
  static const demoAccounts = <String, DemoUser>{
    'admin@balam.ai': DemoUser(
      uid: 'demo-admin-001',
      email: 'admin@balam.ai',
      displayName: 'Balam Admin',
      role: UserRole.admin,
    ),
    'parent@balam.ai': DemoUser(
      uid: 'demo-parent-001',
      email: 'parent@balam.ai',
      displayName: 'Sarah Johnson',
      role: UserRole.parent,
    ),
    'dad@balam.ai': DemoUser(
      uid: 'demo-parent-002',
      email: 'dad@balam.ai',
      displayName: 'Mike Thompson',
      role: UserRole.parent,
    ),
    'doctor@balam.ai': DemoUser(
      uid: 'demo-doctor-001',
      email: 'doctor@balam.ai',
      displayName: 'Dr. Amara Khan',
      role: UserRole.doctor,
    ),
    'vendor@balam.ai': DemoUser(
      uid: 'demo-vendor-001',
      email: 'vendor@balam.ai',
      displayName: 'TinySteps Photography',
      role: UserRole.vendor,
    ),
  };

  Future<DemoUser> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Accept any password for demo accounts
    final user = demoAccounts[email.toLowerCase()];
    if (user != null) {
      _currentUser = user;
      _controller.add(user);
      return user;
    }

    // Auto-create account for any email (demo mode)
    final newUser = DemoUser(
      uid: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      role: UserRole.parent,
    );
    _currentUser = newUser;
    _controller.add(newUser);
    return newUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
