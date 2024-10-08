import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/auth_provider.dart';

import '../utils/utils.dart';

class UserTab extends ConsumerStatefulWidget {
  const UserTab({super.key});

  @override
  ConsumerState<UserTab> createState() => _UserTabState();
}

class _UserTabState extends ConsumerState<UserTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Center(
       child: InkWell(
         onTap: () async {
           await ref.watch(authProvider.notifier).signOut();
           context.go('/');
         },
         child: Container(
           height: 50,
           width: 150,
           decoration: containerButton,
           child: const Center(
             child: Text("Log out", style: buttonText,),
           ),
         ),
       )
     ),
    );
  }
}
