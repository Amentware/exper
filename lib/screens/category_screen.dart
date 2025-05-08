import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/colors.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late CategoryController categoryController;
  late AuthController authController;
  late ProfileController profileController;
  final RxString selectedType = 'expense'.obs;
  late StreamSubscription<bool> _loadingSubscription;
  bool isLoading = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    categoryController = Get.find<CategoryController>();
    authController = Get.find<AuthController>();
    profileController = Get.find<ProfileController>();

    // Set initial filter to 'expense'
    categoryController.setCategoryType('expense');
    // Initial data load
    categoryController.fetchCategories();

    // Listen to controller loading state
    _loadingSubscription = categoryController.isLoading.listen((loading) {
      setState(() => isLoading = loading);
    });
  }

  @override
  void dispose() {
    _loadingSubscription?.cancel();
    super.dispose();
  }

  void _refreshCategories() {
    setState(() {
      categoryController.fetchCategories();
    });
  }

  void _hardRefreshCategories() {
    setState(() {
      categoryController.categories.clear();
      categoryController.expenseCategories.clear();
      categoryController.incomeCategories.clear();
      categoryController.categoryNames.clear();
      categoryController.isLoading.value = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      categoryController.fetchCategories().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((error) {
        print('Error refreshing categories: $error');
      }).whenComplete(() {
        categoryController.isLoading.value = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: () => _showAddCategoryDialog(context),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Obx(() => Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => selectedType.value = 'expense',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: selectedType.value == 'expense'
                                ? black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Expense',
                            style: TextStyle(
                              color: selectedType.value == 'expense'
                                  ? Colors.white
                                  : black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => selectedType.value = 'income',
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: selectedType.value == 'income'
                                ? black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Income',
                            style: TextStyle(
                              color: selectedType.value == 'income'
                                  ? Colors.white
                                  : black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Obx(() {
                if (categoryController.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: CircularProgressIndicator(
                        color: black,
                      ),
                    ),
                  );
                }

                final filteredCategories = categoryController.categories
                    .where((category) => category.type == selectedType.value)
                    .toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${selectedType.value} categories yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap Add Category to create one',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final List<Widget> categoryItems = [];

                for (int i = 0; i < filteredCategories.length; i++) {
                  final category = filteredCategories[i];

                  if (i > 0) {
                    categoryItems.add(
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade100,
                        indent: 16,
                        endIndent: 16,
                      ),
                    );
                  }

                  categoryItems.add(
                    Dismissible(
                      key: Key(category.id),
                      direction: DismissDirection.endToStart,
                      background: Container(),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Delete Category',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Are you sure you want to delete this category? This will also delete all transactions and budgets related to this category. This action cannot be undone.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Material(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () => Navigator.of(context)
                                                  .pop(false),
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 15),
                                                decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    side: BorderSide(
                                                        color: Colors
                                                            .grey.shade200),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: black,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Material(
                                            color: black,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () => Navigator.of(context)
                                                  .pop(true),
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 15),
                                                decoration:
                                                    const ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        final categoryId = category.id;
                        final categoryName = category.name;

                        setState(() {
                          categoryController.categories
                              .removeWhere((cat) => cat.id == categoryId);
                          categoryController.categoryNames.remove(categoryName);
                          categoryController.filterCategoriesByType();
                        });

                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          barrierDismissible: false,
                        );

                        categoryController.isLoading.value = true;

                        categoryController.deleteCategory(categoryId).then((_) {
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }

                          categoryController.isLoading.value = false;

                          setState(() {
                            categoryController.categories
                                .removeWhere((cat) => cat.id == categoryId);
                            categoryController.categoryNames
                                .remove(categoryName);
                            categoryController.filterCategoriesByType();
                          });
                        }).catchError((error) {
                          print('Error deleting category: $error');

                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }

                          categoryController.isLoading.value = false;

                          Get.snackbar(
                            'Error',
                            'Failed to delete category',
                            colorText: Colors.white,
                            backgroundColor: Colors.black,
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(10),
                          );

                          _hardRefreshCategories();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.category_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categoryItems,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Obx(() => Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectedType.value = 'expense',
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: selectedType.value == 'expense'
                                      ? black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: selectedType.value == 'expense'
                                        ? Colors.white
                                        : black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => selectedType.value = 'income',
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: selectedType.value == 'income'
                                      ? black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: selectedType.value == 'income'
                                        ? Colors.white
                                        : black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Category Name',
                    fillColor: const Color(0xFFF8F8F8),
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child:
                          Icon(Icons.category_outlined, color: black, size: 20),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 45, minHeight: 45),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }

                    final trimmedValue = value.trim();
                    final lowerCaseValue = trimmedValue.toLowerCase();

                    bool hasDuplicate = categoryController.categories
                        .where(
                            (category) => category.type == selectedType.value)
                        .any((category) =>
                            category.name.toLowerCase() == lowerCaseValue);

                    if (hasDuplicate) {
                      return 'A category with this name already exists';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Get.back(),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Material(
                        color: black,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              final categoryName = nameController.text.trim();
                              final type = selectedType.value;

                              final hasDuplicate = categoryController.categories
                                  .where((category) => category.type == type)
                                  .any((category) =>
                                      category.name.toLowerCase() ==
                                      categoryName.toLowerCase());

                              if (hasDuplicate) {
                                Get.snackbar(
                                  'Error',
                                  'A category with this name already exists',
                                  colorText: Colors.white,
                                  backgroundColor: Colors.black,
                                  snackPosition: SnackPosition.TOP,
                                  margin: const EdgeInsets.all(10),
                                );
                                return;
                              }

                              Get.dialog(
                                Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                barrierDismissible: false,
                              );

                              categoryController
                                  .addCategory(
                                categoryName,
                                type,
                                'category_outlined',
                              )
                                  .then((_) {
                                if (Get.isDialogOpen == true) {
                                  Get.back();
                                }
                                Get.back();

                                _hardRefreshCategories();
                              }).catchError((error) {
                                print('Error adding category: $error');

                                if (Get.isDialogOpen == true) {
                                  Get.back();
                                }

                                Get.snackbar(
                                  'Error',
                                  'Failed to add category: ${error.toString()}',
                                  colorText: Colors.white,
                                  backgroundColor: Colors.black,
                                  snackPosition: SnackPosition.TOP,
                                  margin: const EdgeInsets.all(10),
                                );
                              });
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 15),
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() => isRefreshing = true);
    categoryController.fetchCategories().then((_) {
      setState(() => isRefreshing = false);
    }).catchError((error) {
      print('Error refreshing categories: $error');
      setState(() => isRefreshing = false);
    });
  }
} 