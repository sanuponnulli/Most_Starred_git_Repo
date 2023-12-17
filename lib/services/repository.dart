import 'package:exasignmt/models/repomodel.dart';
import 'package:exasignmt/services/apiservices.dart';
import 'package:exasignmt/services/generalresponse.dart';

class GeneralRepository {
  final ApiService apiService;

  GeneralRepository(this.apiService);

  Future<ApiResponse<RepoModel>> fetchRepositories(
      {required int page, required int perPage}) async {
    return apiService.fetchRepositories(page: page, perPage: perPage);
  }
}
