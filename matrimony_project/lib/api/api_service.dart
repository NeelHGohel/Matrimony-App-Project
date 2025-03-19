import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:matrimony_project/api/api_const.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import '../utils/export.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ApiService {
  String baseURL = "https://67d0f1c3825945773eb2616e.mockapi.io/";
  ProgressDialog? pd;

  // Show progress dialog
  Future<void> _showProgressDialog(BuildContext context) async {
    if (pd == null) {
      pd = ProgressDialog(context);
      pd!.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: SpinKitChasingDots(
          itemBuilder: (context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(

                color: Colors.black,
              ),
            );
          },
          size: 60,
        ),
        elevation: 10.0,
        progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
        ),
        messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 19.0,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (!pd!.isShowing()) {
      // Add this check!
      await pd!.show();
    }
  }

  // Dismiss progress dialog
  void _dismissProgress() {
    if (pd != null && pd!.isShowing()) {
      pd!.hide();
    }
  }

  // Fetch all users
  Future<List<dynamic>> getUser(context) async {
    // Changed return type to List<dynamic>
    await _showProgressDialog(context);
    http.Response res = await http.get(Uri.parse("${baseURL}Matrimony"));
    _dismissProgress();
    return convertData(res); // Use the correct converter
  }

  // Add a new user
  Future<dynamic> addUser({
    required Map<String, dynamic> map,
    required context,
  }) async {
    await _showProgressDialog(context);
    http.Response res = await http.post(
      Uri.parse("${baseURL}Matrimony"),
      body: jsonEncode(map),
      headers: {"Content-Type": "application/json"},
    );
    _dismissProgress();
    return convertData(res);
  }

// Update an existing user
  Future<dynamic> updateUser({
    required Map<String, dynamic> map,
    required String id,
    required context,
  }) async {
    await _showProgressDialog(context);
    http.Response res = await http.put(
      Uri.parse("${baseURL}Matrimony/$id"),
      body: jsonEncode(map),
      headers: {"Content-Type": "application/json"},
    );
    _dismissProgress();
    return convertData(res);
  }

  // Delete a user
  Future<bool> deleteUser({
    // Changed return type to Future<bool>
    required String id,
    required context,
  }) async {
    await _showProgressDialog(context);
    http.Response res = await http.delete(Uri.parse("${baseURL}Matrimony/$id"));
    _dismissProgress();
    return res.statusCode == 200; // Return true if successful, false otherwise
  }

  // Fetch favorite users
  Future<List<dynamic>> getFavouriteUsers(context) async {
    await _showProgressDialog(context);
    http.Response res = await http.get(Uri.parse("${baseURL}Matrimony"));
    var data = convertData(res); // Use _convertDataToList here
    if (data is List) {
      _dismissProgress();
      return data.where((user) => user[ISFAVOURITE] == true).toList();
    }
    _dismissProgress();
    return [];
  }

  // Convert response data
  dynamic convertData(http.Response res) {
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 404) {
      return "Server Not found";
    } else {
      return "No data found";
    }
  }
}
