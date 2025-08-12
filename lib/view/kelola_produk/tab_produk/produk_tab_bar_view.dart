import 'package:flutter/material.dart';
import 'package:bpkp_pos_test/view/colors.dart';

class ProdukTabBarView extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final Widget? floatingActionButton;
  final TabController? tabController; // Tambahkan ini

  const ProdukTabBarView({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.floatingActionButton,
    this.tabController, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Kelola Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: tabController, // Tambahkan ini
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: AppColors.text,
              ),
            ),
            labelColor: AppColors.text,
            unselectedLabelColor: AppColors.hidden,
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          controller: tabController, // Tambahkan ini
          children: tabViews,
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
