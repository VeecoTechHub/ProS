import 'package:firebase_crashlytics/firebase_crashlytics.dart';

proZCrashId(String id) => FirebaseCrashlytics.instance.setUserIdentifier(id);