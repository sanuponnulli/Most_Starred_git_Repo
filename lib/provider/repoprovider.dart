import 'dart:developer';

import 'package:exasignmt/services/localdbhelper.dart';
import 'package:exasignmt/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:exasignmt/models/repomodel.dart';
import 'package:exasignmt/services/generalresponse.dart';
import 'package:connectivity/connectivity.dart';

class GithubRepoProvider with ChangeNotifier {
  final GeneralRepository _repo;
  final Connectivity connectivity;
  ApiResponse<RepoModel>? _repoResponse;
  final List<Items> _allItems = []; // To hold all loaded items
  bool _isLoading = false;
  bool _hasMore = true; // To track if there are more items to load
  int _currentPage = 1; // To track the current page
  static const int _perPage = 30; // Number of items per page
  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance; // Database helper
  bool _live = true;
  GithubRepoProvider(this._repo, {Connectivity? connectivity})
      : connectivity = connectivity ?? Connectivity();
  ApiResponse<RepoModel>? get repoResponse => _repoResponse;

  List<Items> get allItems => _allItems;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get live => _live;
  int get pagecount => _currentPage;

  // Fetch repositories with pagination

  void reset() {
    _currentPage = 1;
    _allItems.clear();
    fetchRepositories();
  }

  Future<void> fetchRepositories() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // If no internet, load from database
      _live = false;

      await _loadFromDatabase();
    } else {
      _live = true;
      // If internet is available, fetch from API
      await _fetchRepositories();
    }
  }

  void addcache(List<Items> allitems) async {
    _currentPage < 4
        ? await _databaseHelper.insertRepos(RepoModel(items: allitems))
        : null;
  }

  Future<void> _fetchRepositories() async {
    if (_isLoading || !_hasMore) {
      log("message");
      return; // Prevent loading if already loading or no more items
    }

    if (_currentPage == 1 && _allItems.isNotEmpty) {
      _allItems.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      var response =
          await _repo.fetchRepositories(page: _currentPage, perPage: _perPage);
      if (response.status == Status.COMPLETED) {
        _repoResponse = response;
        final items = response.data!.items!;
        _allItems.addAll(items);
        _hasMore = items.length == _perPage;
        addcache(_allItems);
        // _databaseHelper.insertRepos(RepoModel(items: items));
        _currentPage++; // Increment the page for next API call
      } else {
        _hasMore = false; // No more items to load
      }
    } catch (e) {
      _repoResponse = ApiResponse.error('Failed to fetch data: $e');
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromDatabase() async {
    _isLoading = true;
    notifyListeners();
    var cachedData = await _databaseHelper.getRepos();
    if (cachedData != null && cachedData.items != null) {
      _allItems.clear();
      _allItems.addAll(cachedData.items!.take(90)); // Load only up to 90 items
      _hasMore = false; // No more items to fetch from API
    }

    _isLoading = false;
    notifyListeners();
  }
}
