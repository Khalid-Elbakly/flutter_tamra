import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/services/addresses_service.dart';
import '../../l10n/app_localizations.dart';

class AddAddressScreen extends StatefulWidget {
  final String? addressId; // إذا تم تمريره، يكون التحديث
  final String? initialName;
  final String? initialDescription;
  
  const AddAddressScreen({
    Key? key,
    this.addressId,
    this.initialName,
    this.initialDescription,
  }) : super(key: key);
  
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AddressesService _addressesService = AddressesService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // إذا كان تحديث، املأ الحقول
    if (widget.addressId != null) {
      _nameController.text = widget.initialName ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;
    
    if (widget.addressId != null) {
      // تحديث
      result = await _addressesService.updateAddress(
        addressId: widget.addressId!,
        addressName: _nameController.text.trim(),
        addressDescription: _descriptionController.text.trim(),
      );
    } else {
      // إضافة
      result = await _addressesService.addAddress(
        addressName: _nameController.text.trim(),
        addressDescription: _descriptionController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'تم الحفظ بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // إرجاع true للإشارة إلى التحديث
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'حدث خطأ أثناء الحفظ'),
            backgroundColor: Colors.red,
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          //  shape:Border.n
          bottomOpacity: 0.0,
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Colors.white,
          toolbarHeight: kToolbarHeight,
          leadingWidth: 300,
          leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    color: Color(0XFF575757),
                    Icons.arrow_back,
                    size: 30.0,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                    AppLocalizations.of(context)?.newAddress ?? 'عنوان جديد',
                    style: TextStyle(
                      color: Color(0XFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.addressName ??
                          'اسم العنوان',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: 'نجاة الشامسي للفواكه فرع الاول',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'من فضلك أدخل اسم العنوان';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.addressDescription ??
                          'وصف العنوان',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText:
                              'الدمام - حي العنود - شارع الخليج - بعد بنك ساب',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'من فضلك أدخل وصف العنوان';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0Xff7C3425),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                      onPressed: () {
                        // TODO: فتح الخريطة لاختيار الموقع
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            color: Colors.white,
                            Icons.location_on_outlined,
                            size: 25.0,
                          ),
                          SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context)?.addressOnMap ??
                                'العنوان على الخريطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0Xff7C3425),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveAddress,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 80),
                                Icon(
                                  color: Colors.white,
                                  Icons.arrow_back_ios,
                                  size: 18.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  AppLocalizations.of(context)?.save ?? 'حفظ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 80),
                              ],
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
