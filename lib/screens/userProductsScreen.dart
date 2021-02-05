import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/app_Drawer.dart';

import '../widgets/UserProduct_Item.dart';
import '../screens/EditProductScreen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/UserProductScreen';
  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("My products"), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },
        )
      ]),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (ctx, dataSnapShot) =>
            dataSnapShot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: (ctx, productData, _) => ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItem(
                                productData.items[i].title,
                                productData.items[i].imageUrl,
                                productData.items[i].id,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
