import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './products.dart';

class Products with ChangeNotifier {
  final String authToken;  
  final String userId;
  //used by provider package
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

// var _showFavoritesonly=false;to apply appWide filter

  List<Product> get items {
    // if(_showFavoritesonly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // } to apply appWide filter
    return [..._items]; //when products change
  }
  Products(this.authToken,this.userId,this._items);//auth token is to feed in the url of fetchAndSet data so that the data from server can be received and _items is to save previous data._userId is used n fetch and set data to get favourites


  // void showFavourites(){
  //   _showFavoritesonly=true;
  //   notifyListeners();
  // }
  // void showAll(){
  //   _showFavoritesonly=false;
  //   notifyListeners();
  // }to apply appWide filter
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://srvshopapp-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        //since http.post returns a future and it is the code block that will be executed as whole we can return that future method so as to use .then in our app and show a loader till future is being executed
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
            // 'isFavourite': product.isFavourite, to fetch favourite iindividually from dbms
          },
        ),
      );
      final newProduct = Product(
        description: product.description,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      items
          .add(newProduct); //_items.insert(0,newProduct) to insert at beginning
      // _items.add(value);
    } catch (error) {
      print(error);
      throw error; //throw takes an error object and we use it bczwe want to throw another error in the edit product screens
    }
    notifyListeners();
  }

/* Execution without asyn and await
  Future<void> addProduct(Product product) {
    const url = 'https://srvshopapp-default-rtdb.firebaseio.com/products.json';
    return http.post(//since http.post returns a future and it is the code block that will be executed as whole we can return that future method so as to use .then in our app and show a loader till future is being executed
      url,
      body: json.encode(
        {
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
        },
      ),
    ).then((response) {
      final newProduct = Product(
        description: product.description,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct); //_items.insert(0,newProduct) to insert at beginning
      // _items.add(value);
      notifyListeners();
    }).catchError((error) {
        print(error);
        throw error; //throw takes an error object and we use it bczwe want to throw another error in the edit product screens
      });
  }

 */
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://srvshopapp-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
              'isFavourite': newProduct.isFavourite,
            },
          )); //merges with the previous data
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

   Future<void> removeProduct(String id) async{//error is handled on widget/user Product Item
    final url =
        'https://srvshopapp-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';//$id is to go for specific url id
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response=await http.delete(url);
      //As delete doesnt throw any error if we get an error for server status code
      //tocheck just print response.statusCode
      if(response.statusCode>=400){
        _items.insert(existingProductIndex, existingProduct);
         notifyListeners();
        throw HttpException('Could not delete Product');//throw is like return
      }
      existingProduct = null;
       // _items.removeWhere((prod) => prod.id == id);
  }
  /*
  void removeProduct(String id) {
    final url =
        'https://srvshopapp-default-rtdb.firebaseio.com/products/$id.json';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    http.delete(url).then((response) {
      //As delete doesnt throw any error if we get an error for server status code
      //tocheck just print response.statusCode
      if(response.statusCode>=400){
        throw HttpException('Could not delete Product');
      }
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex, existingProduct);
    });

    // _items.removeWhere((prod) => prod.id == id);
    _items.removeAt(existingProductIndex);
    notifyListeners();
  }*/


//auth token is to feed in the url of fetchAndSet data so that the data from server can be received and _items is to save previous data
  Future<void> fetchAndSetProducts([bool filterByUser=false]) async {//ZUse of sqare brackets make it optional positional arguments
    final filterString=  filterByUser? 'orderBy="creatorId"&equalTo="$userId"':'';
    var url = 'https://srvshopapp-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
     //var url = 'https://srvshopapp-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"';//?auth=$authToken is addedd after json link whichh only allows the authenticated user view the data.& is ude to add more info= here orderBy creatorId==userId helps us to return the data when oyr condn is satisfied. the keys are firebase specific. To make things work we need to configure in the firebase site rules.
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null) return;
      final url2 =
        'https://srvshopapp-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken';//for favourites
      final favoriteResponse= await http.get(url2);
      final favoriteData=json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            // isFavourite: prodData['isFavourite'],
            isFavourite: favoriteData==null? false:favoriteData[prodId]??false,//?? it means if fav data is not null then we set fav status fromm fav data and if favdata[prodId] doesn't exost then using ?? which is else if then we use dafault value false
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
