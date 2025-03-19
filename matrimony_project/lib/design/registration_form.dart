import 'package:intl/intl.dart';
import 'package:matrimony_project/api/api_service.dart';
import '../utils/export.dart';

class RegistrationForm extends StatefulWidget {
  final Map<String, dynamic>? user;

  RegistrationForm({super.key, this.user});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form data
  String _radioVal = 'Male';
  String? selectedCity;
  String dob = "Select Date of Birth";
  DateTime? date = DateTime.now();
  int? age;
  List<String> selectedHobbies = [];

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // Constants
  final Color primaryColor = Colors.red;
  final Color secondaryColor = Colors.redAccent;
  final Color backgroundColor = Colors.grey.shade50;
  final double borderRadius = 12.0;

  // Data
  List<String> cities = [
    'Anand', 'Ahmedabad', 'Bharuch', 'Bhavnagar', 'Dahegam',
    'Gandhinagar', 'Godhra', 'Jamnagar', 'Junagadh', 'Mehsana',
    'Morbi', 'Nadiad', 'Navsari', 'Patan', 'Porbandar',
    'Rajkot', 'Surat', 'Vadodara', 'Valsad', 'Himatnagar'
  ];

  List<String> hobbies = ['Reading', 'Traveling', 'Cooking', 'Sports', 'Music'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (widget.user != null) {
      nameController.text = widget.user!['name'] ?? '';
      addressController.text = widget.user!['address'] ?? '';
      emailController.text = widget.user!['email'] ?? '';
      phoneController.text = widget.user!['phone'] ?? '';

      selectedCity = (widget.user!['city'] is String)
          ? (widget.user!['city'] as String).trim()
          : null;

      if (selectedCity != null && !cities.contains(selectedCity)) {
        selectedCity = cities.isNotEmpty ? cities.first : null;
      } else if (selectedCity == null && cities.isNotEmpty) {
        selectedCity = cities.first;
      }

      _radioVal = widget.user!['gender'] ?? 'Male';

      // Handle DOB and Age correctly
      if (widget.user!['dob'] != null && widget.user!['dob'].isNotEmpty) {
        dob = widget.user!['dob'];
        try {
          date = DateFormat('dd-MM-yyyy').parse(dob);
          if (date != null) {
            calculateAge();
          }
        } catch (e) {
          print('Error parsing date: $e');
          dob = 'Select Date of Birth';
        }
      } else {
        dob = 'Select Date of Birth';
      }

      String hobbiesString = widget.user!['hobbies'] ?? '';
      selectedHobbies = hobbiesString.isNotEmpty
          ? hobbiesString.split(',').map((hobby) => hobby.trim()).toList()
          : [];
    }
  }

  void calculateAge() {
    if (date != null) {
      DateTime currentDate = DateTime.now();
      int years = currentDate.year - date!.year;
      if (currentDate.month < date!.month ||
          (currentDate.month == date!.month && currentDate.day < date!.day)) {
        years--;
      }
      setState(() {
        age = years;
      });
    }
  }

  Future<void> updateUserInList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    Map<String, dynamic> updatedUser = {
      'name': nameController.text,
      'address': addressController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'city': selectedCity,
      'gender': _radioVal,
      'dob': dob,
      'hobbies': selectedHobbies.join(', '),
      'age': age,
    };

    ApiService apiService = ApiService();
    if (widget.user != null) {
      await apiService.updateUser(
          id: widget.user!['id'], map: updatedUser, context: context);
    } else {
      await apiService.addUser(map: updatedUser, context: context);
    }
    Navigator.pop(context, true); // Pass true to indicate data change
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.user != null ? "Update Profile" : "Registration",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative top curve
            Container(
              height: 30,
              color: primaryColor,
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
            ),

            // Form content
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 10),
                        // Form container with shadow
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Personal Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 16),

                                // Name input field
                                TextFormField(
                                  controller: nameController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter your name";
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration("Full Name", Icons.person),
                                ),
                                SizedBox(height: 16),

                                // Email input field
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[A-Z]'))
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter email address";
                                    }
                                    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                    RegExp regex = RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return "Please enter a valid email address";
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration("Email Address", Icons.email),
                                ),
                                SizedBox(height: 16),

                                // Phone input field
                                TextFormField(
                                  controller: phoneController,
                                  maxLength: 10,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]'))
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty || value.length != 10) {
                                      return "Please enter a valid 10-digit mobile number";
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration("Mobile Number", Icons.phone),
                                ),
                                SizedBox(height: 8),

                                // Gender selection
                                Text(
                                  "Gender",
                                  style: TextStyle(
                                    color: primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Card(
                                  margin: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(child: _buildRadioOption('Male')),
                                        Expanded(child: _buildRadioOption('Female')),
                                        Expanded(child: _buildRadioOption('Other')),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Date of birth selector
                                Text(
                                  "Date of Birth",
                                  style: TextStyle(
                                    color: primaryColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    try {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2000),
                                        firstDate: DateTime(1947),
                                        lastDate: DateTime(2008),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: primaryColor,
                                              ),
                                              buttonTheme: ButtonThemeData(
                                                textTheme: ButtonTextTheme.primary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (pickedDate != null) {
                                        setState(() {
                                          date = pickedDate;
                                          dob = DateFormat('dd-MM-yyyy').format(pickedDate);
                                          calculateAge();
                                        });
                                      }
                                    } catch (e) {
                                      print('Error showing date picker: $e');
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(borderRadius),
                                      border: Border.all(color: Colors.grey.shade300),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: primaryColor),
                                        SizedBox(width: 12),
                                        Text(
                                          dob,
                                          style: TextStyle(
                                            color: dob == "Select Date of Birth" ? Colors.grey.shade600 : Colors.black87,
                                          ),
                                        ),
                                        if (age != null) ...[
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "$age years",
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Address section
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Address Details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 16),

                                // Address field
                                TextFormField(
                                  controller: addressController,
                                  keyboardType: TextInputType.streetAddress,
                                  maxLines: 2,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter your address";
                                    }
                                    return null;
                                  },
                                  decoration: _buildInputDecoration("Address", Icons.location_on),
                                ),
                                SizedBox(height: 16),

                                // City dropdown
                                DropdownButtonFormField<String>(
                                  value: selectedCity,
                                  decoration: _buildInputDecoration("City", Icons.location_city),
                                  items: cities.map((city) {
                                    String trimmedCity = city.trim();
                                    return DropdownMenuItem<String>(
                                      value: trimmedCity,
                                      child: Text(trimmedCity),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCity = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please select a city";
                                    }
                                    return null;
                                  },
                                  isDense: true,
                                  isExpanded: true,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Hobbies section
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Interests & Hobbies",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Divider(),
                                SizedBox(height: 8),

                                // Hobbies selection
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: hobbies.map((hobby) {
                                    bool isSelected = selectedHobbies.contains(hobby);
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedHobbies.remove(hobby);
                                          } else {
                                            selectedHobbies.add(hobby);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryColor : Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected ? primaryColor : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                                              size: 16,
                                              color: isSelected ? Colors.white : Colors.grey.shade600,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              hobby,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black87,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                label: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  nameController.clear();
                  addressController.clear();
                  emailController.clear();
                  phoneController.clear();
                  setState(() {
                    selectedCity = null;
                    dob = "Select Date of Birth";
                    _radioVal = 'Male';
                    selectedHobbies.clear();
                    date = DateTime.now();
                    age = null;
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  "Reset",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: updateUserInList,
                icon: Icon(
                  widget.user != null ? Icons.save : Icons.check_circle,
                  color: Colors.white,
                ),
                label: Text(
                  widget.user != null ? "Update" : "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    final bool isSelected = _radioVal == value;
    return InkWell(
      onTap: () {
        setState(() {
          _radioVal = value;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio<String>(
            value: value,
            groupValue: _radioVal,
            activeColor: primaryColor,
            onChanged: (String? newValue) {
              setState(() {
                _radioVal = newValue!;
              });
            },
          ),
          Text(
            value,
            style: TextStyle(
              color: isSelected ? primaryColor : Colors.grey.shade800,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}