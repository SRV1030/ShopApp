import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import './screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import './screens/userProductsScreen.dart';
import './screens/EditProductScreen.dart';
import './screens/auth_screen.dart';
import './screens/SplashScreen.dart';

import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
              //Proxy provider depeends on the mentioned provider too. We mention the class to follow auth and depeneding class Products
              update: (ctx, auth, previousProducts) => Products(
                  auth.token,
                  auth.userId,
                  previousProducts == null
                      ? []
                      : previousProducts
                          .items) //update instead of create. and we only use the proxyProvider when we need to cahange one provider when otheris changed
              ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              //Proxy provider depeends on the mentioned provider too. We mention the class to follow auth and depeneding class Products
              update: (ctx, auth, previousOrders) => Orders(
                  auth.token,
                  auth.userId,
                  previousOrders == null
                      ? []
                      : previousOrders
                          .orders) //update instead of create. and we only use the proxyProvider when we need to cahange one provider when otheris changed
              ),
        ],
        /*
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth,Products>(//Proxy provider depeends on the mentioned provider too. We mention the class to follow auth and depeneding class Products
            update: (ctx,auth,previousProducts) => Products(auth.token, previousProducts==null ? []: previousProducts.items)//update instead of create. and we only use the proxyProvider when we need to cahange one provider when otheris changed
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Orders(),
          )
        ],
         */
        /*ChangeNotifierProvider(
        create: (ctx)=> Products(),//Products is our root provider. builder was used instead of creater in 3.0.0 version*/
        //ChangeNotifierProvider.value(
        //value: Products(),
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'ShopApp',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              accentColor: Colors.blue,
              canvasColor: Color.fromRGBO(227, 220, 220, 1),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductsOviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routename: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductScreen.routeName: (ctx) => UserProductScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
