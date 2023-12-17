import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:exasignmt/models/repomodel.dart';
import 'package:exasignmt/provider/repoprovider.dart';
import 'package:exasignmt/services/apiservices.dart';
import 'package:exasignmt/services/generalresponse.dart';
import 'package:exasignmt/services/localdbhelper.dart';
import 'package:exasignmt/services/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;

import 'mocks.dart.mocks.dart';

void main() {
  late MockClient mockClient;
  late MockApiService mockApiService;
  late MockGeneralRepository mockGeneralRepository;
  late MockConnectivity mockConnectivity;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockClient = MockClient();
    mockApiService = MockApiService();
    mockGeneralRepository = MockGeneralRepository();
    mockConnectivity = MockConnectivity();
  });

  group('ApiService Tests', () {
    late ApiService apiService;
    late Uri testUri;

    setUp(() {
      apiService = ApiService();
      apiService.client = mockClient; // Inject the mock client
      testUri = Uri.parse(
          'your_api_endpoint'); // Replace with your actual API endpoint
    });

    test('Successful API call returns RepoModel', () async {
      // Mock response
      final jsonresponse = {/* Your JSON response here */};
      when(mockClient.get(testUri)).thenAnswer(
          (_) async => http.Response(jsonEncode(jsonresponse), 200));

      // Call the API
      var response = await apiService.fetchRepositories();

      // Check if ApiResponse is successful and data is of type RepoModel
      expect(response.status, Status.COMPLETED);
      expect(response.data, isA<RepoModel>());
    });

    test('Non-200 response returns error', () async {
      // Mock non-200 response
      when(mockClient.get(testUri))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Call the API
      var response = await apiService.fetchRepositories();

      // Check if ApiResponse is an error
      expect(response.status, Status.ERROR);
    });

    test('Exception during API call returns error', () async {
      // Mock exception
      when(mockClient.get(testUri))
          .thenThrow(Exception('Failed to fetch data'));

      // Call the API
      var response = await apiService.fetchRepositories();

      // Check if ApiResponse is an error
      expect(response.status, Status.ERROR);
    });

    // Add more tests as needed for different scenarios
  });

  group('GeneralRepository Tests', () {
    late GeneralRepository generalRepository;
    final int testPage = 1;
    final int testPerPage = 10;

    setUp(() {
      generalRepository = GeneralRepository(mockApiService);
    });

    test('fetchRepositories returns ApiResponse<RepoModel> on success',
        () async {
      // Define a sample RepoModel
      final sampleRepoModel = RepoModel(
          // Initialize with your desired RepoModel data
          );

      // Mock the behavior of the ApiService's fetchRepositories method
      when(mockApiService.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .thenAnswer(
              (_) async => ApiResponse<RepoModel>.completed(sampleRepoModel));

      // Call the fetchRepositories method
      final result = await generalRepository.fetchRepositories(
          page: testPage, perPage: testPerPage);

      // Verify that the ApiService's fetchRepositories method was called
      verify(mockApiService.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .called(1);

      // Check if the result is successful and contains the sampleRepoModel
      expect(result.status, Status.COMPLETED);
      expect(result.data, equals(sampleRepoModel));
    });

    test('fetchRepositories returns error on API failure', () async {
      // Mock the ApiService to return an error
      when(mockApiService.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .thenAnswer(
              (_) async => ApiResponse<RepoModel>.error('Error occurred'));

      // Call the fetchRepositories method
      final result = await generalRepository.fetchRepositories(
          page: testPage, perPage: testPerPage);

      // Verify that the ApiService's fetchRepositories method was called
      verify(mockApiService.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .called(1);

      // Check if the result is an error
      expect(result.status, Status.ERROR);
      expect(result.message, 'Error occurred');
    });

    // Add more test cases as needed
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;
    late Database database;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Initialize an in-memory database
      database = await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions());
      dbHelper = DatabaseHelper.instance;
    });

    test('Insert and Retrieve RepoModel', () async {
      final expectedRepoModel = RepoModel(
          // Initialize with your desired RepoModel data
          );

      // Insert RepoModel into the database
      await dbHelper.insertRepos(expectedRepoModel);

      // Retrieve RepoModel from the database
      final actualRepoModel = await dbHelper.getRepos();

      // Check if the retrieved RepoModel matches the expected one
      expect(actualRepoModel, isNotNull);
      expect(actualRepoModel?.items, equals(expectedRepoModel.items));
      expect(actualRepoModel?.totalCount, equals(expectedRepoModel.totalCount));
      // Add more assertions for other attributes as needed
    });

    tearDown(() async {
      await database.close(); // Close the database when done
    });
  });
  group('GithubRepoProvider Tests', () {
    late GithubRepoProvider githubRepoProvider;
    late MockGeneralRepository mockGeneralRepository;

    setUp(() {
      mockGeneralRepository = MockGeneralRepository();
      // Initialize GithubRepoProvider possibly with a mock implementation that does not invoke platform channels
      githubRepoProvider = GithubRepoProvider(mockGeneralRepository);
    });

    test('fetchRepositories should call GeneralRepository', () async {
      final int testPage = 1;
      final int testPerPage = 10;
      final sampleRepoModel = RepoModel(
          // Initialize with your desired RepoModel data
          );

      // Mock the response of the connectivity check
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      // Mock the GeneralRepository to return a sample RepoModel
      when(mockGeneralRepository.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .thenAnswer(
              (_) async => ApiResponse<RepoModel>.completed(sampleRepoModel));

      await githubRepoProvider.fetchRepositories();

      // Verify that the GeneralRepository's fetchRepositories method was called
      verify(mockGeneralRepository.fetchRepositories(
              page: testPage, perPage: testPerPage))
          .called(1);
    });

    // Add more test cases for other scenarios and methods as needed
  });
}
