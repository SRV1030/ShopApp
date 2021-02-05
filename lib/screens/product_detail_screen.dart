import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = 'product_details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(
        productId); //listen:false is a argyment of of() whic on falsse makes sure that this list is no rebuild even if the data is updated some where else. By default listen is true
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            SizedBox(height: 10),
            Card(
              color: Theme.of(context).canvasColor,
              elevation: 7,
              child: Text(
                loadedProduct.description,
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
