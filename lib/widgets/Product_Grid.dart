import '../providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    //only those with product listener will rebuild. Products is the typeinstance
    final productsData = Provider.of<Products>(context);
    final products = showFavs? productsData.favoriteItems: productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //no. of items
        childAspectRatio:
            3 / 2, //dimension of grid tile, kength is 3x and width is 2x
        crossAxisSpacing: 10, //spacing in between the columns
        mainAxisSpacing: 10, //spacing between rows
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],//here we used products[i] cz we wanted build every product individually
        child: ProductItem(
          // products[i].id,
          // products[i].title,
          // products[i].imageUrl,
        ),
      ),
      itemCount: products.length,
    );
  }
}
