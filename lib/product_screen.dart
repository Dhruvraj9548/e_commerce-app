import 'dart:convert';

import 'package:ecommerce_app/product_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_view.dart';
import 'model.dart';
import 'package:http/http.dart' as http;


class ProductListView extends StatefulWidget {
  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  double _maxPrice = 1000; // Adjust this based on your product prices
  String _sortOption = 'Price: Low to High';
  List<String> _selectedCategories = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final List<String> _categories = ["Electronics", "Jewelery", "Men's Clothing", "Women's Clothing"];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    List<Product> products = await _getProducts();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
  }

  Future<List<Product>> _getProducts() async {
    final productURL = 'https://fakestoreapi.com/products';
    final response = await http.get(Uri.parse(productURL));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products from fake API');
    }
  }

  void _filterProducts() {
    List<Product> filtered = _allProducts
        .where((product) => product.price <= _maxPrice)
        .where((product) => _selectedCategories.isEmpty || _selectedCategories.contains(product.category))
        .toList();

    if (_sortOption == 'Price: Low to High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'Price: High to Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Price Range'),
                    Slider(
                      value: _maxPrice,
                      min: 0,
                      max: 1000, // Adjust this based on your product price range
                      divisions: 20,
                      label: "\$${_maxPrice.round()}",
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('Sort By'),
                    DropdownButton<String>(
                      value: _sortOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _sortOption = newValue!;
                        });
                      },
                      items: <String>['Price: Low to High', 'Price: High to Low']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Text('Categories'),
                    ..._categories.map((category) {
                      return CheckboxListTile(
                        title: Text(category),
                        value: _selectedCategories.contains(category.toLowerCase()),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedCategories.add(category.toLowerCase());
                            } else {
                              _selectedCategories.remove(category.toLowerCase());
                            }
                          });
                        },
                      );
                    }).toList(),
                    ElevatedButton(
                      onPressed: () {
                        _filterProducts();
                        Navigator.of(context).pop();
                      },
                      child: Text('Apply Filter'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _productGridView(_filteredProducts),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterBottomSheet(context),
        child: Icon(Icons.filter_list, color: Colors.white,),
        backgroundColor: Colors.black,
      ),
    );
  }

  GridView _productGridView(List<Product> data) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var ccart = Provider.of<Cart>(context);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => ProductDetailPage(
                  id: data[index].id,
                  title: data[index].title,
                  price: data[index].price,
                  description: data[index].description,
                  category: data[index].category,
                  image: data[index].image,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      data[index].image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data[index].title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${data[index].price.toString()}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          ccart.add(data[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Added to Cart"),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

