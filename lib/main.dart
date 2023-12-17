import 'package:cached_network_image/cached_network_image.dart';
import 'package:exasignmt/provider/repoprovider.dart';
import 'package:exasignmt/services/apiservices.dart';
import 'package:exasignmt/services/generalresponse.dart';
import 'package:exasignmt/services/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import your models and providers

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                GithubRepoProvider(GeneralRepository(ApiService()))),
        // You can add more providers here if needed
      ],
      child: MaterialApp(
        title: 'GitHub Trending Repos',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const TrendingReposPage(),
      ),
    );
  }
}

class TrendingReposPage extends StatefulWidget {
  const TrendingReposPage({super.key});

  @override
  State<TrendingReposPage> createState() => _TrendingReposPageState();
}

class _TrendingReposPageState extends State<TrendingReposPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GithubRepoProvider>(context, listen: false)
          .fetchRepositories();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<GithubRepoProvider>(context, listen: false)
          .fetchRepositories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending GitHub Repos'),
      ),
      body: Consumer<GithubRepoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pagecount == 1) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.repoResponse?.status == Status.ERROR &&
              provider.pagecount == 1) {
            return const Center(child: Text(
                // provider.repoResponse?.message ??

                'Error fetching data'));
          }

          var repos = provider.allItems;
          if (repos.isEmpty) {
            return const Center(child: Text('No repositories found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              Provider.of<GithubRepoProvider>(context, listen: false).reset();
            },
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(height: 10),
              controller: _scrollController,
              itemCount: repos.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == repos.length && provider.hasMore) {
                  return const Center(child: CircularProgressIndicator());
                } else if (index == repos.length &&
                    provider.repoResponse?.status == Status.ERROR) {
                  return const Center(
                      child: Icon(Icons.error_outline_sharp,
                          color: Colors.redAccent));
                } else {
                  var repo = repos[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        repo.name ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        repo.description ?? 'No Description',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '${repo.stargazersCount ?? 0} stars',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      leading: repo.owner?.avatarUrl != null && provider.live
                          ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                repo.owner!.avatarUrl!,
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
