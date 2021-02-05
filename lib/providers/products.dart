import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavourite = false});

  void _setFavourite(bool oldStatus){
    isFavourite=oldStatus;
      notifyListeners();
  }

  Future<void> toggleFavouriteScreen(String authToken,String userId ) async {//optimistic updating
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://srvshopapp-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$authToken';//weget user Id and data from auth and we do it to make favourites juser Specific. we use this url in producs rovider in fetch and set data to get the data of favourites
    try {//$id helps us to get product id/;favourite format
      final respose= await http.put(
        url,
        body: json.encode(
          isFavourite,
        ),
      );
      if(respose.statusCode>=400){
        _setFavourite(oldStatus);
      }
    } catch (error) {
       _setFavourite(oldStatus);
    }
  }
}
