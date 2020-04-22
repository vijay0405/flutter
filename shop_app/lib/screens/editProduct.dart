import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/editProduct";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _editedProduct = Product(
    id: null,
    title: "",
    description: "",
    price: 0,
    imageUrl: "",
  );
  var _initValues = {
    'title': "",
    'description': "",
    'price': "",
    'imageUrl': "",
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ""
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith("png") &&
              !_imageUrlController.text.endsWith('jpg') &&
              !_imageUrlController.text.endsWith('jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct)
      .then((_){
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
        ],
      ),
      body: _isLoading? Center(
        child: CircularProgressIndicator() ,
      ): Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  initialValue: _initValues['title'],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please provide a value";
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      id: _editedProduct.id ,
                      isFavorite: _editedProduct.isFavorite,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                      title: value,
                    );
                  },
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Price'),
                    initialValue: _initValues['price'],
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter a price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      if (double.parse(value) <= 0) {
                        return "Please enter a number greater then zero";
                      }
                      return null;
                    },
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        price: double.parse(value),
                        title: _editedProduct.title,
                      );
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    initialValue: _initValues['description'],
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please enter a description";
                      }
                      if (value.length < 10) {
                        return "Should be atleast ten characters long";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        isFavorite: _editedProduct.isFavorite,
                        description: value,
                        imageUrl: _editedProduct.imageUrl,
                        price: _editedProduct.price,
                        title: _editedProduct.title,
                      );
                    }),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text("Enter URL")
                          : FittedBox(
                              child: Image.network(_imageUrlController.text,
                                  fit: BoxFit.cover)),
                    ),
                    Expanded(
                      child: TextFormField(
                          decoration: InputDecoration(labelText: "Image URL"),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter an ImageUrl";
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Please enter a valid url';
                            }
                            if (!value.endsWith("png") &&
                                !value.endsWith('jpg') &&
                                !value.endsWith('jpeg')) {
                              return 'Please enter a valid image url';
                            }
                            return null;
                          },
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite,
                              description: _editedProduct.description,
                              imageUrl: value,
                              price: _editedProduct.price,
                              title: _editedProduct.title,
                            );
                          }),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
