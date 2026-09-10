import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. MODEL Produk
class Product {
  final String id, name, imageUrl;
  final double price;
  Product({required this.id, required this.name, required this.price, required this.imageUrl});
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

// 2. STATE MANAGEMENT (PROVIDER)
class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get totalAmount => _items.fold(0.0, (sum, i) => sum + (i.product.price * i.quantity));

  void addToCart(Product p) {
    int idx = _items.indexWhere((i) => i.product.id == p.id);
    idx >= 0 ? _items[idx].quantity++ : _items.add(CartItem(product: p));
    notifyListeners();
  }

  void updateQty(String pId, int delta) {
    int idx = _items.indexWhere((i) => i.product.id == pId);
    if (idx >= 0) {
      _items[idx].quantity += delta;
      if (_items[idx].quantity <= 0) _items.removeAt(idx);
      notifyListeners();
    }
  }

  void clearCart() { _items.clear(); notifyListeners(); }
}

// 3. MAIN ENTRY POINT
void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => CartProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple, scaffoldBackgroundColor: Colors.white),
      home: const ProductListScreen(),
    ),
  ),
);

// 4. HALAMAN PRODUK / E-CATALOG
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(id: '1', name: 'Laptop RPL Pro', price: 12500000, imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500'),
    Product(id: '2', name: 'Mouse Wireless', price: 250000, imageUrl: 'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500'),
    Product(id: '3', name: 'Keyboard Mechanical', price: 750000, imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500'),
    Product(id: '4', name: 'Monitor 24 Inch', price: 2100000, imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500'),
    Product(id: '5', name: 'Headset Gaming', price: 350000, imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500'),
    Product(id: '6', name: 'Flashdisk 64GB', price: 100000, imageUrl: 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=500'),
  ];
  String selectedCategory = 'Semua';
  final List<String> categories = ['Semua', 'Laptop', 'Aksesoris', 'Komponen', 'Monitor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('E-Catalog SMKN 3 Tuban', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()))),
                if (cart.itemCount > 0)
                  Positioned(right: 8, top: 8, child: CircleAvatar(radius: 8, backgroundColor: const Color(0xFFC837E1), child: Text('${cart.itemCount}', style: const TextStyle(fontSize: 10, color: Colors.white)))),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(hintText: 'Cari produk...', prefixIcon: const Icon(Icons.search, size: 20), contentPadding: EdgeInsets.zero, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.grey.shade100)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontSize: 12, color: selectedCategory == cat ? Colors.white : Colors.black)),
                    selected: selectedCategory == cat, selectedColor: const Color(0xFFC837E1), backgroundColor: Colors.grey.shade200,
                    onSelected: (_) => setState(() => selectedCategory = cat),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemBuilder: (_, i) {
                  final prod = products[i];
                  return Card(
                    elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(prod.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey))),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(alignment: Alignment.centerLeft, child: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Align(alignment: Alignment.centerLeft, child: Text('Rp ${prod.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 11))),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity, height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC837E1), padding: EdgeInsets.zero),
                              onPressed: () {
                                context.read<CartProvider>().addToCart(prod);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${prod.name} ditambahkan'), duration: const Duration(seconds: 1)));
                              },
                              child: const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFFC837E1), unselectedItemColor: Colors.grey, selectedFontSize: 11, unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategori'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// 5. HALAMAN KERANJANG BELANJA
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFE899F0), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Rp ${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Keranjang masih kosong'))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey, size: 20))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Total: Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () => cart.updateQty(item.product.id, -1)),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => cart.updateQty(item.product.id, 1)),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity, height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC837E1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: cart.items.isEmpty ? null : () {
                  cart.clearCart();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout berhasil!')));
                },
                child: const Text('Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, type: BottomNavigationBarType.fixed, selectedItemColor: const Color(0xFFC837E1), unselectedItemColor: Colors.grey, selectedFontSize: 11, unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategori'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Keranjang'),
        ],
      ),
    );
  }
}