import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamra/presentation/screens/add_address_screen.dart';
import 'package:tamra/services/addresses_service.dart';

class AddressesScreen extends StatefulWidget {
  final String? selectedAddressId; // للسماح باختيار عنوان من القائمة
  final Function(String addressId, String addressName, String addressDescription)? onAddressSelected;

  const AddressesScreen({
    Key? key,
    this.selectedAddressId,
    this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressesService _addressesService = AddressesService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا العنوان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _addressesService.deleteAddress(addressId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'تم الحذف'),
            backgroundColor: result['success'] == true ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.white,
          toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
          leadingWidth: 300,
          leading: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    color: Color(0XFF575757),
                    Icons.arrow_back,
                    size: 30.0,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  'عناويني',
                  style: TextStyle(
                    color: Color(0XFF3D3D3D),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _addressesService.getClientAddresses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('حدث خطأ: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد عناوين',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0Xff7C3425),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAddressScreen(),
                          ),
                        );
                        if (result == true) {
                          setState(() {}); // إعادة تحميل
                        }
                      },
                      child: Text('إضافة عنوان جديد'),
                    ),
                  ],
                ),
              );
            }

            final addresses = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final addressId = address.id;
                      final addressData = address.data() as Map<String, dynamic>;
                      final addressName = addressData['addressName'] ?? '';
                      final addressDescription = addressData['addressDescription'] ?? '';
                      final isDefault = addressData['isDefault'] ?? false;
                      final isSelected = widget.selectedAddressId == addressId;

                      return Card(
                        margin: EdgeInsets.only(bottom: 15),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? Color(0Xff7C3425)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Color(0Xff7C3425),
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            addressName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0XFF3D3D3D),
                                            ),
                                          ),
                                        ),
                                        if (isDefault)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(0Xff7C3425),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'افتراضي',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (widget.onAddressSelected != null)
                                    IconButton(
                                      icon: Icon(Icons.check_circle,
                                          color: isSelected
                                              ? Color(0Xff7C3425)
                                              : Colors.grey),
                                      onPressed: () {
                                        widget.onAddressSelected!(
                                          addressId,
                                          addressName,
                                          addressDescription,
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                addressDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0XFF707070),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0Xff7C3425),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddAddressScreen(
                                            addressId: addressId,
                                            initialName: addressName,
                                            initialDescription: addressDescription,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {}); // إعادة تحميل
                                      }
                                    },
                                    child: Text('تعديل', style: TextStyle(fontSize: 14)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0XffA8A8A8),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: () => _deleteAddress(addressId),
                                    child: Text('حذف', style: TextStyle(fontSize: 14)),
                                  ),
                                  if (!isDefault) ...[
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Color(0Xff7C3425),
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide(color: Color(0Xff7C3425)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () async {
                                        final result =
                                            await _addressesService.setDefaultAddress(
                                                addressId);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result['message'] ?? ''),
                                              backgroundColor: result['success'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      child: Text('افتراضي', style: TextStyle(fontSize: 14)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0Xff7C3425),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddAddressScreen(),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {}); // إعادة تحميل
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text('إضافة عنوان جديد'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


