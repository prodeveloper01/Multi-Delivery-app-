
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:emarket_delivery_boy/data/datasource/remote/dio/dio_client.dart';
import 'package:emarket_delivery_boy/data/datasource/remote/exception/api_error_handler.dart';
import 'package:emarket_delivery_boy/data/model/body/TrackBody.dart';
import 'package:emarket_delivery_boy/data/model/response/base/api_response.dart';
import 'package:emarket_delivery_boy/utill/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  TrackerRepo({@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getTrackList(String id, DateTime filterDate) async {
    try {
      String startDate = '${DateFormat('yyyy-MM-dd').format(filterDate)}T00:00:00.000Z';
      String endDate = '${DateFormat('yyyy-MM-dd').format(filterDate)}T23:59:59.000Z';
      Response response = await dioClient.get('/tracks?user.id=$id&date_gte=$startDate&date_lte=$endDate');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getHistoryList(String id) async {
    try {
      Response response = await dioClient.get('/track-histories?track=$id');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
  Future<ApiResponse> addHistory(TrackBody trackBody) async {
    try {
      Response response = await dioClient.post(AppConstants.RECORD_LOCATION_URI, data: trackBody.toJson());
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}