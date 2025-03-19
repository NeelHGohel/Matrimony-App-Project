import 'package:flutter/cupertino.dart';
import 'package:matrimony_project/api/api_service.dart';
import '../utils/export.dart';

class FavoriteUserList extends StatefulWidget {
  const FavoriteUserList({Key? key}) : super(key: key);

  @override
  State<FavoriteUserList> createState() => _FavoriteUserListState();
}

class _FavoriteUserListState extends State<FavoriteUserList> {
  final ApiService apiService = ApiService();
  TextEditingController searchController = TextEditingController();
  List<dynamic> userList = []; // Store all favorite users
  List<dynamic> filteredUsers = []; // Store filtered favorite users

  @override
  void initState() {
    super.initState();
    _fetchFavoriteUsers();
    searchController.addListener(filterUsers);
  }

  Future<void> _fetchFavoriteUsers() async {
    try {
      List<dynamic> users = await apiService.getUser(context); // Fetch ALL users
      List<dynamic> favoriteUsers = users.where((user) => user['isFavorite'] == true).toList(); // Filter favorites locally

      setState(() {
        userList = favoriteUsers;
        filteredUsers = List.from(favoriteUsers);
      });
    } catch (e) {
      print('Error fetching favorite users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load favorite users: $e")),
      );
    }
  }

  void filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = userList.where((user) {
        return (user['name'] != null &&
            user['name'].toLowerCase().contains(query)) ||
            (user['phone'] != null &&
                user['phone'].toLowerCase().contains(query)) ||
            (user['city'] != null &&
                user['city'].toLowerCase().contains(query)) ||
            (user['gender'] != null &&
                user['gender'].toLowerCase().contains(query));
      }).toList();
    });
  }

  Future<void> _toggleFavorite(dynamic user) async {
    final userId = user['id'].toString();
    final isFavorite = user['isFavorite'] ?? false;

    try {
      // Optimistically update the UI
      setState(() {
        user['isFavorite'] = !isFavorite;

        if (!isFavorite) {
          filteredUsers.add(user);
          userList.add(user);
        } else {
          filteredUsers.remove(user);
          userList.remove(user);
        }
      });

      Map<String, dynamic> updateData = {'isFavorite': !isFavorite};
      await apiService.updateUser(id: userId, map: updateData, context: context);


    } catch (e) {
      // Revert UI if update fails
      setState(() {
        user['isFavorite'] = isFavorite;
        if (isFavorite) {
          filteredUsers.add(user);
          userList.add(user);
        } else {
          filteredUsers.remove(user);
          userList.remove(user);
        }
      });

      print('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update favorite status: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Favorite Users", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search People here...",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            filteredUsers.isEmpty
                ? const Center(
              child: Text(
                "No favorite users yet",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  var user = filteredUsers[index];
                  final isFavorite = user['isFavorite'] ?? false;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: user)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage:
                              NetworkImage(user['photo'] ?? ''),
                              onBackgroundImageError: (_, __) {},
                              child: user['photo'] == null
                                  ? const Icon(Icons.person,
                                  size: 30, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("${user['name']}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text("${user['age']}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                  Text("${user['gender']}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                  Text("${user['city']}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _toggleFavorite(user),
                              icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}