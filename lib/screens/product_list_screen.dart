import 'dart:io'; // Thêm thư viện này để sử dụng Image.file
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crud/models/product.dart';
import 'package:crud/screens/add_product_screen.dart';

class ListProductScreen extends StatefulWidget {
  @override
  _ListProductScreenState createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final DatabaseReference _productRef =
      FirebaseDatabase.instance.ref('products');
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Hàm lấy sản phẩm từ Firebase và cập nhật vào danh sách
  Future<void> _fetchProducts() async {
    _productRef.onValue.listen((event) {
      final List<Product> products = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          products.add(Product.fromJson(value, key));
        });
      }

      setState(() {
        _products = products;
        _filteredProducts = products; // Khởi tạo danh sách sản phẩm đã lọc
      });

      print(
          "Products fetched: ${_products.length}"); // Kiểm tra số lượng sản phẩm
    });
  }

  // Hàm lọc sản phẩm theo tên hoặc danh mục
  void _filterProducts(String searchText) {
    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(searchText.toLowerCase()) ||
            product.category.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  // Hàm hiển thị hộp thoại xác nhận khi xóa sản phẩm
  void _showDeleteConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text(
              'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}" không?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            TextButton(
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteProduct(product.id); // Xóa sản phẩm nếu nhấn "Xóa"
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm xóa sản phẩm
  void _deleteProduct(String productId) {
    _productRef.child(productId).remove().then((_) {
      _fetchProducts(); // Cập nhật lại danh sách sản phẩm sau khi xóa
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              ).then((_) {
                _fetchProducts(); // Cập nhật lại danh sách sản phẩm khi quay lại
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm kiếm sản phẩm',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  Divider(), // Thêm dòng phân cách giữa các sản phẩm
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Giá: ${product.price} VND\nDanh mục: ${product.category}'),
                  leading: product.imageUrl.isNotEmpty
                      ? _buildProductImage(product.imageUrl)
                      : Icon(Icons.image,
                          size:
                              50), // Hiển thị biểu tượng nếu không có hình ảnh
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                          product); // Hiển thị hộp thoại xác nhận
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddProductScreen(product: product),
                      ),
                    ).then((_) {
                      _fetchProducts(); // Cập nhật lại danh sách sản phẩm khi quay lại
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hàm xây dựng widget hiển thị hình ảnh sản phẩm
  Widget _buildProductImage(String imageUrl) {
    // Nếu URL là từ Firebase Storage
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image,
              size: 50); // Biểu tượng nếu không tải được hình ảnh
        },
      );
    } else {
      // Nếu URL là đường dẫn cục bộ, sử dụng Image.file
      return Image.file(
        File(imageUrl),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }
}
