// import 'dart:convert';
// import 'package:connectivity/connectivity.dart';
// import 'package:exasignmt/models/repomodel.dart';
// import 'package:exasignmt/provider/repoprovider.dart';
// import 'package:exasignmt/services/apiservices.dart';
// import 'package:exasignmt/services/generalresponse.dart';
// import 'package:exasignmt/services/localdbhelper.dart';
// import 'package:exasignmt/services/repository.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' as http;

// import 'testdata.dart';

// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// // Replace with the actual path

// class MockDatabase extends Mock implements Database {}

// class MockClient extends Mock implements http.Client {}

// class MockApiService extends Mock implements ApiService {}

// class MockGeneralRepository extends Mock implements GeneralRepository {}

// class MockConnectivity extends Mock implements Connectivity {}

// void main() {
//   group('ApiService Tests', () {
//     // Mock HTTP client
//     late MockClient mockClient;
//     late ApiService apiService;

//     setUp(() {
//       mockClient = MockClient();
//       apiService = ApiService();
//       apiService.client =
//           mockClient; // Assuming you have a way to inject the mock client in ApiService
//     });

//     test('Successful API call returns RepoModel', () async {
//       // Mock response
//       when(mockClient.get(testuri)).thenAnswer(
//           (_) async => http.Response(jsonEncode(jsonresponse), 200));

//       // Call the API
//       var response = await apiService.fetchRepositories();

//       // Check if ApiResponse is successful and data is of type RepoModel
//       expect(response.status, Status.COMPLETED);
//       expect(response.data, isA<RepoModel>());
//     });

//     test('Non-200 response returns error', () async {
//       final testuri = Uri.parse('your_api_endpoint');

//       // Mock non-200 response
//       when(mockClient.get(testuri))
//           .thenAnswer((_) async => http.Response('Not Found', 404));

//       // Call the API
//       var response = await apiService.fetchRepositories();

//       // Check if ApiResponse is an error
//       expect(response.status, Status.ERROR);
//     });

//     test('Exception during API call returns error', () async {
//       // Mock exception
//       when(mockClient.get(testuri))
//           .thenThrow(Exception('Failed to fetch data'));

//       // Call the API
//       var response = await apiService.fetchRepositories();

//       // Check if ApiResponse is an error
//       expect(response.status, Status.ERROR);
//     });

//     // Add more tests as needed for different scenarios
//   });

//   group('ApiResponse Tests', () {
//     test('ApiResponse.completed sets status to COMPLETED', () {
//       // Arrange
//       var expectedData = "Test Data";

//       // Act
//       var response = ApiResponse.completed(expectedData);

//       // Assert
//       expect(response.status, Status.COMPLETED);
//       expect(response.data, expectedData);
//       expect(response.message, isNull);
//     });
//   });

//   group('DatabaseHelper Tests', () {
//     late DatabaseHelper dbHelper;

//     setUp(() {
//       // Set the sqflite_common_ffi databaseFactory before initializing dbHelper
//       sqfliteFfiInit(); // Initialize sqflite_ffi
//       databaseFactory = databaseFactoryFfi; // Set the databaseFactory

//       dbHelper = DatabaseHelper.instance;
//     });

//     test('Insert and Retrieve RepoModel', () async {
//       final expectedRepoModel = RepoModel(
//           // Initialize with your desired RepoModel data
//           );

//       // Insert RepoModel into the database
//       await dbHelper.insertRepos(expectedRepoModel);

//       // Retrieve RepoModel from the database
//       final actualRepoModel = await dbHelper.getRepos();

//       // Check if the retrieved RepoModel is not null
//       expect(actualRepoModel, isNotNull);

//       // Compare the attributes of the expected and retrieved RepoModels
//       expect(actualRepoModel!.items, equals(expectedRepoModel.items));
//       expect(actualRepoModel.totalCount, equals(expectedRepoModel.totalCount));
//       // Add more assertions for other attributes as needed
//     });

//     test('Delete RepoModel', () async {
//       // Delete RepoModel from the database
//       await dbHelper.deleteRepos();

//       // Retrieve RepoModel after deletion
//       final deletedRepoModel = await dbHelper.getRepos();

//       // Check if the retrieved RepoModel is null after deletion
//       expect(deletedRepoModel, isNull);
//     });
//   });

//   group('GeneralRepository Tests', () {
//     late GeneralRepository generalRepository;
//     late MockApiService mockApiService;

//     setUp(() {
//       mockApiService = MockApiService();
//       generalRepository = GeneralRepository(mockApiService);
//     });

//     test('fetchRepositories returns ApiResponse<RepoModel>', () async {
//       // Define the parameters for the fetchRepositories method
//       final page = 1;
//       final perPage = 10;

//       // Define a sample RepoModel
//       final sampleRepoModel = RepoModel(
//           // Initialize with your desired RepoModel data
//           );

//       // Mock the behavior of the ApiService's fetchRepositories method
//       when(mockApiService.fetchRepositories(page: page, perPage: perPage))
//           .thenAnswer(
//               (_) async => ApiResponse<RepoModel>.completed(sampleRepoModel));

//       // Call the fetchRepositories method
//       final result = await generalRepository.fetchRepositories(
//           page: page, perPage: perPage);

//       // Verify that the ApiService's fetchRepositories method was called with the expected parameters
//       verify(mockApiService.fetchRepositories(page: page, perPage: perPage));

//       // Check if the result is of type ApiResponse<RepoModel> and contains the sampleRepoModel
//       expect(result, isA<ApiResponse<RepoModel>>());
//       expect(result.data, equals(sampleRepoModel));
//     });

//     // Add more test cases as needed
//   });

//   group('GithubRepoProvider Tests', () {
//     late GithubRepoProvider githubRepoProvider;
//     late MockGeneralRepository mockGeneralRepository;
//     late MockConnectivity mockConnectivity;

//     setUp(() {
//       mockGeneralRepository = MockGeneralRepository();
//       mockConnectivity = MockConnectivity();
//       githubRepoProvider = GithubRepoProvider(mockGeneralRepository,
//           connectivity: mockConnectivity);
//     });

//     test('fetchRepositories should call _fetchRepositories when connected',
//         () async {
//       // Mock connectivity to return ConnectivityResult.mobile (you can change this based on your needs)
//       when(mockConnectivity.checkConnectivity())
//           .thenAnswer((_) async => ConnectivityResult.mobile);

//       // Mock the behavior of _fetchRepositories method
//       when(mockGeneralRepository.fetchRepositories(page: 1, perPage: 30))
//           .thenAnswer(
//               (_) async => ApiResponse<RepoModel>.completed(RepoModel()));

//       await githubRepoProvider.fetchRepositories();

//       // Verify that _fetchRepositories was called
//       verify(mockGeneralRepository.fetchRepositories(page: 1, perPage: 30));
//     });

//     // Add more test cases for other scenarios and methods as needed
//   });
// }

import 'package:exasignmt/services/apiservices.dart';
import 'package:exasignmt/services/repository.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

@GenerateMocks([http.Client, ApiService, GeneralRepository, Connectivity])
void main() {}
