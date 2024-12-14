import 'package:client/elements/bottom_navbar.dart';
import 'package:client/elements/loading.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/tools.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/tools/api_handler.dart';

/// A screen for managing friends and pending friend requests.
class Friends extends ConsumerStatefulWidget {
  const Friends({super.key});

  @override
  FriendsState createState() => FriendsState();
}

class FriendsState extends ConsumerState<Friends> {
  late final RouterNotifier router;
  late final UserNotifier user;
  List<Map<String, dynamic>>? _friendsData;
  List<Map<String, dynamic>>? _pendingRequestsData;
  bool loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
      _initFriends();
    });
  }

  Widget buildAvatar(String username, String? profilePicture) {
    if (profilePicture != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          '${ApiHandler.url}/api/user/pfp/$username',
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
    }
  }

  /// Fetches friends and pending friend requests from the API.
  Future<void> _initFriends() async {
    final token = user.token;
    if (token == null) return;

    try {
      final friends = await ApiHandler.getFriends(token);
      final pendingRequests = await ApiHandler.getPendingFriendRequests(token);

      setState(() {
        _friendsData = friends;
        _pendingRequestsData = pendingRequests;
        loading = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        loading = false;
      });
    }
  }

  /// Sends a friend request to a user.
  Future<void> _sendFriendRequest(String username) async {
    final token = user.token;
    if (token == null) return;

    try {
      await ApiHandler.sendFriendRequest(token, username);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent successfully')),
      );
      _searchController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// Accepts a pending friend request.
  Future<void> _acceptFriendRequest(int friendRequestId) async {
    final token = user.token;
    if (token == null) return;

    try {
      await ApiHandler.acceptFriendRequest(token, friendRequestId);
      _initFriends(); // Refresh the lists
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// Removes a friend.
  Future<void> _removeFriend(String username) async {
    final token = user.token;
    if (token == null) return;

    try {
      await ApiHandler.removeFriend(token, username);
      _initFriends(); // Refresh the lists
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// Builds a user's avatar, using a profile picture if available.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Add friend by username...',
          fillColor: Colors.white, // Set the input field background color
          filled: true, // Enable filling the background
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _sendFriendRequest(_searchController.text);
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  /// Builds the search bar for adding friends.
  Widget _buildFriendsList() {
    return Expanded(
      child: ListView(
        children: [
          if (_pendingRequestsData != null && _pendingRequestsData!.isNotEmpty)
            Card(
              margin: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Pending Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pendingRequestsData!.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequestsData![index];
                      return ListTile(
                        leading: buildAvatar(
                          request['username'],
                          request['profilePicture'],
                        ),
                        title: Text(request['username']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () =>
                                  _acceptFriendRequest(request['friendId']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () =>
                                  _removeFriend(request['username']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Friends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_friendsData != null && _friendsData!.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _friendsData!.length,
                    itemBuilder: (context, index) {
                      final friend = _friendsData![index];
                      return ListTile(
                        leading: buildAvatar(
                          friend['username'],
                          friend['profilePicture'],
                        ),
                        title: Text(friend['username']),
                        subtitle: Text(
                          'Last seen: ${Tools.formatCreatedAt(friend['lastLoggedIn'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => router.setPath(context, "join"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove),
                              onPressed: () =>
                                  _removeFriend(friend['username']),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                          'No friends yet. Add some friends to get started!'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: loading
          ? const Center(child: LogoLoading())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFriendsList(),
              ],
            ),
      bottomNavigationBar: const BottomNavbar(
        path: "friends",
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
