library;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;

class AppLinks {
  AppLinks();

  Stream<Uri?> get uriLinkStream {
    return const Stream<Uri?>.empty();
  }

  Future<Uri?> getInitialLink() async {
    if (kIsWeb) {
      return Uri.base;
    }
    return null;
  }

  Future<Uri?> getLatestLink() async {
    if (kIsWeb) {
      return Uri.base;
    }
    return null;
  }

  Future<String?> getInitialLinkString() async {
    final uri = await getInitialLink();
    return uri?.toString();
  }

  Future<String?> getLatestLinkString() async {
    final uri = await getLatestLink();
    return uri?.toString();
  }
}
