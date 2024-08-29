import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class Cartview extends StatefulWidget {
  @override
  _CartviewState createState() => _CartviewState();
}

class _CartviewState extends State<Cartview> {
  @override
  Widget build(BuildContext context) {
    var ccart = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Cart View [\$ ${ccart.totalPrice}]'),
        ),
        body: ccart.cartItems.length == 0
            ? Center(child: Text('no items in your cart'))
            : ListView.builder(
          itemCount: ccart.cartItems.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: Image.network(ccart.cartItems[index].image),
                title: Text(ccart.cartItems[index].title),
                subtitle: Text('\$${ccart.cartItems[index].price.toString()}', style: TextStyle(color: Colors.green),),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    ccart.remove(ccart.cartItems[index]);
                  },
                ),
              ),
            );
          },
        ));
  }
}



class Cart extends ChangeNotifier {
  List<Product> _products = [];

  dynamic _totalPrice = 0.0;

  void add(Product item) {
    _products.add(item);
    _totalPrice += item.price;
    notifyListeners();
  }

  void remove(Product item) {
    _totalPrice -= item.price;
    _products.remove(item);
    notifyListeners();
  }

  int get count {
    return _products.length;
  }

  dynamic get totalPrice {
    return _totalPrice;
  }

  List<Product> get cartItems {
    return _products;
  }
}