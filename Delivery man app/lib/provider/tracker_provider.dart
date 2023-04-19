import 'dart:async';

import 'package:flutter/material.dart';
import 'package:emarket_delivery_boy/data/model/body/TrackBody.dart';
import 'package:emarket_delivery_boy/data/model/response/base/api_response.dart';
import 'package:emarket_delivery_boy/data/model/response/base/error_response.dart';
import 'package:emarket_delivery_boy/data/model/response/response_model.dart';
import 'package:emarket_delivery_boy/data/repository/tracker_repo.dart';

class TrackerProvider extends ChangeNotifier {
  final TrackerRepo trackerRepo;

  TrackerProvider({@required this.trackerRepo});

  List<TrackBody> _trackList = [];

  int _selectedTrackIndex = 0;
  bool _isBlockButton = false;
  bool _canDismiss = true;

  List<TrackBody> get trackList => _trackList;

  int get selectedTrackIndex => _selectedTrackIndex;

  bool get isBlockButton => _isBlockButton;

  bool get canDismiss => _canDismiss;

  bool _startTrack = false;
  Timer timer;

  bool get startTrack => _startTrack;

  updateTrackStart(bool status) {
    _startTrack = status;
    if (status == false && timer != null) {
      timer.cancel();
    }
    notifyListeners();
  }

  Future<ResponseModel> addTrack({TrackBody trackBody}) async {
    ResponseModel responseModel;
    timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (_startTrack) {
        ApiResponse apiResponse = await trackerRepo.addHistory(trackBody);
        if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
          responseModel = ResponseModel(true, 'Successfully start track');
        } else {
          String errorMessage;
          if (apiResponse.error is String) {
            print(apiResponse.error.toString());
            errorMessage = apiResponse.error.toString();
          } else {
            ErrorResponse errorResponse = apiResponse.error;
            print(errorResponse.errors[0].message);
            errorMessage = errorResponse.errors[0].message;
          }
          responseModel = ResponseModel(false, errorMessage);
        }
        notifyListeners();
      } else {
        timer.cancel();
      }
    });

    return responseModel;
  }
}

class MyBackgroundService {
  static StreamSubscription timer;

  static void stop() {
    timer?.cancel();
  }
}
