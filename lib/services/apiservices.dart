// import 'dart:developer';
// import 'package:exasignmt/models/repomodel.dart';
// import 'package:exasignmt/services/generalresponse.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ApiService {
//   final String baseUrl =
//       "https://api.github.com/search/repositories?q=created:>";

//   Future<ApiResponse<RepoModel>> fetchRepositories(
//       {int page = 1, int perPage = 2}) async {
//     try {
//       final date = DateTime.now()
//           .subtract(const Duration(days: 30))
//           .toIso8601String()
//           .split('T')[0];
//       final url = Uri.parse(
//           '$baseUrl$date&sort=stars&order=desc&page=$page&per_page=$perPage');

//       final response = await http.get(url);

//       log(response.toString());

//       if (response.statusCode == 200) {
//         final reposJson = json.decode(response.body);
//         RepoModel repos = RepoModel.fromJson(reposJson);
//         return ApiResponse.completed(repos);
//       } else {
//         return ApiResponse.error(
//             'Failed to load repositories with status code ${response.statusCode}');
//       }
//     } catch (e) {
//       return ApiResponse.error('Error occurred: $e');
//     }
//   }
// }

import 'dart:developer';
import 'package:exasignmt/models/repomodel.dart';
import 'package:exasignmt/services/generalresponse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "https://api.github.com/search/repositories?q=created:>";
  http.Client client;

  ApiService({http.Client? client}) : this.client = client ?? http.Client();

  Future<ApiResponse<RepoModel>> fetchRepositories(
      {int page = 1, int perPage = 2}) async {
    try {
      final date = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .split('T')[0];
      final url = Uri.parse(
          '$baseUrl$date&sort=stars&order=desc&page=$page&per_page=$perPage');

      final response = await client.get(url);

      log(response.toString());

      if (response.statusCode == 200) {
        final reposJson = json.decode(response.body);
        RepoModel repos = RepoModel.fromJson(reposJson);
        return ApiResponse.completed(repos);
      } else {
        return ApiResponse.error(
            'Failed to load repositories with status code ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error occurred: $e');
    }
  }
}
