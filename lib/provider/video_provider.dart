import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gracetech_video_player_app/helpers/app_constants.dart';
import 'package:gracetech_video_player_app/models/video_model.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:get/get.dart';

class VideoProvider extends ChangeNotifier {
  VideoModel? videoModel;
  bool isLoading = true;
  int? index;

  Future<void> fetchVideos() async {
    final connectivity = await Connectivity().checkConnectivity();

    // check that app is connected with the internet or not
    if (connectivity == ConnectivityResult.wifi ||
        connectivity == ConnectivityResult.mobile) {
      // call the api for data in try catch block
      try {
        var response = await http.get(
          Uri.parse(AppConstants.API_URL),
        );

        // check the status code of request
        if (response.statusCode == 200) {
          // Remove the "var mediaJSON = " and "semicolon" string from the beginning and end of the response
          String jsonString = response.body;
          String jsonStr = jsonString.substring(15);
          RegExp exp = new RegExp(r';$');
          jsonStr = jsonStr.replaceAll(exp, '');

          // decode the jscon response and assing data to model class
          var decodeResponse = json.decode(jsonStr);

          videoModel = VideoModel.fromJson(decodeResponse);

          isLoading = false;
          notifyListeners();
        } else {
          // show error message

          MotionToast.warning(
            description: const Text(
              'Something went wrong! please try again later',
              style: TextStyle(fontSize: 16),
            ),
          ).show(Get.context!);
        }
      } catch (e) {
        // show error message

        MotionToast.warning(
          description: const Text(
            'Something went wrong! please try again later',
            style: TextStyle(fontSize: 16),
          ),
        ).show(Get.context!);
      }
    } else {
      //show error message if app is not connected with internet

      MotionToast.warning(
        description: const Text(
          'Please make sure your device is connected to the internet',
          style: TextStyle(fontSize: 16),
        ),
      ).show(Get.context!);
    }
    notifyListeners();
  }
}
