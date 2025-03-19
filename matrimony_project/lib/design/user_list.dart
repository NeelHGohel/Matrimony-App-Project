import 'package:flutter/cupertino.dart';
import 'package:matrimony_project/api/api_service.dart';
import '../utils/export.dart';

class AllUserList extends StatefulWidget {
  AllUserList({Key? key}) : super(key: key);

  @override
  State<AllUserList> createState() => _AllUserListState();
}

class _AllUserListState extends State<AllUserList> {
  TextEditingController searchController = TextEditingController();
  ApiService apiService = ApiService();
  String selectedFilter = 'Recently Added';

  // Define a primary color to use throughout the UI
  final Color primaryColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    searchController.addListener(filterUsers);
  }

  Future<void> _fetchUsers() async {
    try {
      List<dynamic> users = await apiService.getUser(context);
      setState(() {
        userList = users;
        filteredUsers = List.from(userList);
        applySorting();
      });
    } catch (e) {
      // Handle errors appropriately (show a message, log the error)
      print('Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load users: $e")),
      );
    }
  }

  void filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = userList.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString().toLowerCase() ?? '';
        final city = user['city']?.toString().toLowerCase() ?? '';

        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            city.contains(query);
      }).toList();
      applySorting();
    });
  }

  void applySorting() {
    if (selectedFilter == 'A-Z') {
      filteredUsers.sort((a, b) =>
          (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''));
    } else if (selectedFilter == 'Z-A') {
      filteredUsers.sort((a, b) =>
          (b['name']?.toString() ?? '').compareTo(a['name']?.toString() ?? ''));
    } else if (selectedFilter == 'By Age (0-9)') {
      filteredUsers.sort((a, b) {
        final ageA = _parseAge(a['age']);
        final ageB = _parseAge(b['age']);
        return ageA.compareTo(ageB);
      });
    } else if (selectedFilter == 'By Age (9-0)') {
      filteredUsers.sort((a, b) {
        final ageA = _parseAge(a['age']);
        final ageB = _parseAge(b['age']);
        return ageB.compareTo(ageA);
      });
    } else if (selectedFilter == 'Recently Added') {
      filteredUsers.sort((a, b) {
        final idA = (a['id']);
        final idB = (b['id']);
        return idB.compareTo(idA);
      });
    }
  }

  int _parseAge(dynamic age) {
    if (age is int) {
      return age;
    } else if (age is String) {
      return int.tryParse(age) ?? 0;
    }
    return 0;
  }

  Future<void> _deleteUser(dynamic user) async {
    String userId = (user[ID]);
    try {
      bool success = await apiService.deleteUser(id: userId, context: context);

      if (success) {
        setState(() {
          userList.remove(user);
          filteredUsers.remove(user);
          applySorting();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User deleted successfully"),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete user"),
            backgroundColor: Colors.grey[700],
          ),
        );
      }
    } catch (e) {
      print('Error deleting user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete user: $e"),
          backgroundColor: Colors.grey[700],
        ),
      );
    }
  }

  Future<void> _toggleFavorite(dynamic user) async {
    final userId = user['id'].toString();
    final isFavorite = user['isFavorite'] ?? false;

    try {
      setState(() {
        user['isFavorite'] = !isFavorite;
      });

      // Prepare the update map. Crucially, you ONLY send the `isFavorite` flag.
      Map<String, dynamic> updateData = {'isFavorite': !isFavorite};

      // Call the API to update the user's favorite status
      await apiService.updateUser(
          id: userId, map: updateData, context: context);

      // If the API call was successful, the UI remains updated.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Favorite status updated."),
          backgroundColor: primaryColor,
        ),
      );

      // Refresh the user list after update
      _fetchUsers(); // Re-fetch to ensure data is consistent.
    } catch (e) {
      // If there's an error, revert the UI change and show an error message
      setState(() {
        user['isFavorite'] = isFavorite; // Revert the UI change
      });

      print('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update favorite status: $e"),
          backgroundColor: Colors.grey[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Users",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Filter Users',
                      style: TextStyle(color: primaryColor),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Recently Added'),
                          onTap: () {
                            setState(() {
                              selectedFilter = 'Recently Added';
                              Navigator.of(context).pop();
                              applySorting();
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('By Name (A-Z)'),
                          onTap: () {
                            setState(() {
                              selectedFilter = 'A-Z';
                              Navigator.of(context).pop();
                              applySorting();
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('By Name (Z-A)'),
                          onTap: () {
                            setState(() {
                              selectedFilter = 'Z-A';
                              Navigator.of(context).pop();
                              applySorting();
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('By Age (0-9)'),
                          onTap: () {
                            setState(() {
                              selectedFilter = 'By Age (0-9)';
                              Navigator.of(context).pop();
                              applySorting();
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('By Age (9-0)'),
                          onTap: () {
                            setState(() {
                              selectedFilter = 'By Age (9-0)';
                              Navigator.of(context).pop();
                              applySorting();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  var user = filteredUsers[index];
                  final userId = (user['id']);
                  final isFavorite =
                      user['isFavorite'] ?? false; // Default to false if null

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailScreen(user: user),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.grey,
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                  NetworkImage(user['photo'] ?? ''),
                                  onBackgroundImageError: (_, __) {},
                                  child: user['photo'] == null
                                      ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        user['email'] ?? 'No Email',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Phone: ${user['phone']}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "City: ${user['city']}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.grey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegistrationForm(
                                          user: user,
                                        ),
                                      ),
                                    ).then((_) {
                                      _fetchUsers();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 28,
                                    color: isFavorite ?Colors.red : Colors.grey,

                                  ),
                                  onPressed: () => _toggleFavorite(user),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: const Text("Delete"),
                                          content: const Text(
                                              'Are you sure you want to Delete this user?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await _deleteUser(user);
                                              },
                                              child: Text('Yes', style: TextStyle(color: primaryColor)),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('No', style: TextStyle(color: Colors.grey)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
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
      floatingActionButton: Tooltip(
        message: 'Add New User',
        enableTapToDismiss: true,
        child: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrationForm(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}