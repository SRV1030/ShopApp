import 'package:ShopApp/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/userProductsScreen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('ShopApp'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("LogOut"),
            onTap: () {
              Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).logOut();
            },
          ),
        ],
      ),
    );
  }
}
