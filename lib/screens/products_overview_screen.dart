import '../widgets/app_Drawer.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';

import '../widgets/Product_Grid.dart';
import '../widgets/badge.dart';

import '../screens/cart_screen.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOviewScreen extends StatefulWidget {
  @override
  _ProductsOviewScreenState createState() => _ProductsOviewScreenState();
}

class _ProductsOviewScreenState extends State<ProductsOviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true; //for getting the products in database
  var _isLoading = false; //to load a spiner till we fetch data

  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndSetProducts();//Wont work directly
    //-------M_I______//
    // Future.delayed(Duration.zero).then((_){
    //    Provider.of<Products>(context).fetchAndSetProducts();
    // });
    //Method II is to use didchangedependencies which runs only after entire page is loaded
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      //As didChange dependencies runs more often we use a variable isInit so that weonly call our provider once at the begining
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsContainer= Provider.of<Products>(context,listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text("My Shop"),
          actions: <Widget>[
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (FilterOptions selectedValue) {
                setState(
                  () {
                    if (selectedValue == FilterOptions.Favourites) {
                      //   productsContainer.showFavourites();
                      _showOnlyFavourites = true;
                    } else {
                      // productsContainer.showAll();
                      _showOnlyFavourites = false;
                    }
                  },
                );
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text("Only Favourites"),
                  value: FilterOptions.Favourites,
                ),
                PopupMenuItem(
                  child: Text("Show All"),
                  value: FilterOptions.All,
                )
              ],
            ),
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                child: ch,
                value: cart.itemCount.toString(),
              ),
              child: IconButton(
                //the ch in the builder refers to this child
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routename);
                },
              ),
            ) //icon with labels
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductsGrid(_showOnlyFavourites));
  }
}
