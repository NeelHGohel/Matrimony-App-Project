import 'package:flutter/cupertino.dart';
import '../utils/export.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchUserCounts();
  }

  Future<void> fetchUserCounts() async {
    try {
      List<dynamic> users = await apiService.getUser(context);
      List<dynamic> favoriteUsers =
      users.where((user) => user['isFavorite'] == true).toList();

      setState(() {
        countOfUser = users.length;
        countOfFavoriteUser = favoriteUsers.length;
      });
    } catch (e) {
      print('Error fetching user counts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load user counts: $e"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void refreshUserCounts() {
    fetchUserCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.red.shade400,
                Colors.red.shade700,
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/leading_logo.jpeg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Matrimony",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          SharedPrefs.logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text('Yes',
                            style: TextStyle(color: Colors.pink)),
                      ),
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with welcome message
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red.shade700,
                      Colors.red.shade400,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Connecting hearts, one match at a time",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: "Total Users",
                            value: countOfUser.toString(),
                            icon: Icons.people_alt_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: "Favorites",
                            value: countOfFavoriteUser.toString(),
                            icon: Icons.favorite_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Menu Options Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menu Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true, // Crucial for SingleChildScrollView
                  physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                  children: [
                    _buildMenuCard(
                      title: "Add User",
                      icon: Icons.person_add_rounded,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) => RegistrationForm()))
                            .then((_) => refreshUserCounts());
                      },
                    ),
                    _buildMenuCard(
                      title: "User List",
                      icon: Icons.view_list_rounded,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) => AllUserList()))
                            .then((_) => refreshUserCounts());
                      },
                    ),
                    _buildMenuCard(
                      title: "Favorites",
                      icon: Icons.favorite_rounded,
                      color: Colors.red,
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                            builder: (context) => FavoriteUserList()))
                            .then((_) => refreshUserCounts());
                      },
                    ),
                    _buildMenuCard(
                      title: "About Us",
                      icon: Icons.info_rounded,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => AboutUs()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Icon(
                icon,
                color: color,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}