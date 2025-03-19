import '../utils/export.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  UserDetailScreen({required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final Color primaryColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    var hobbies = widget.user['hobbies'] ?? "None";
    List<String> hobbiesList =
    hobbies is String ? hobbies.split(', ') : hobbies;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "${widget.user['name'].toUpperCase()}'s Details",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(widget.user['photo'] ?? ''),
                    onBackgroundImageError: (_, __) {},
                    child: widget.user['photo'] == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 30),
              buildInfoCard("Name", widget.user['name'], Icons.person),
              buildInfoCard("Email", widget.user['email'], Icons.email),
              buildInfoCard(
                  "Address", widget.user['address'], Icons.location_on),
              buildInfoCard("Phone", widget.user['phone'], Icons.phone),
              buildInfoCard("City", widget.user['city'], Icons.location_city),
              buildInfoCard("Age", widget.user['age'].toString(), Icons.cake),
              buildGenderInfoCard(),
              buildInfoCard("Hobbies", hobbiesList.join(', '), Icons.star),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Back to Users List',
      ),
    );
  }

  Widget buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenderInfoCard() {
    String gender = widget.user['gender'] ?? 'Unknown';
    IconData genderIcon;

    if (gender.toLowerCase() == 'male') {
      genderIcon = Icons.male;
    } else if (gender.toLowerCase() == 'female') {
      genderIcon = Icons.female;
    } else {
      genderIcon = Icons.transgender;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(genderIcon, color: primaryColor, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    gender,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}