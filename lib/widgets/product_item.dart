import '../providers/products.dart';
import '../providers/cart.dart';

import '../screens/product_detail_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
            child: Image.network(product.imageUrl, fit: BoxFit.cover),
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: product.id,
              );
            }),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, product, /*child*/ _) => IconButton(
              icon: Icon(
                  product.isFavourite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
              onPressed: () {
                product.toggleFavouriteScreen(
                  authData.token,
                  authData.userId,
                );
              },
            ),
            // child: ,Add the child whose value wont change. say Text
          ),
          title: Text(product.title, textAlign: TextAlign.center),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Added item to the cart",
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => cart.removeSingleItem(product.id)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
