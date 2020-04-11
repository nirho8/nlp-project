import 'package:final_project/providers/users.dart';
import 'package:final_project/widgets/user_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loadedUsers = Provider.of<Users>(context).users;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedUsers.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedUsers[i],
        child: UserItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 9 / 10,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}