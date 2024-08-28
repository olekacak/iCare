import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:icare/Model/editProfile_model.dart';
import 'editProfile.dart';
import 'login.dart';
import 'package:icare/Model/device_model.dart'; // Import your DeviceModel class

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  EditProfileModel? userProfile;
  List<DeviceModel> devices = [];

  @override
  void initState() {
    super.initState();
    print('DashboardPage initState called'); // Debugging print statement
    loadByEmail();
    loadDevices();
  }

  Future<void> loadByEmail() async {
    EditProfileModel? profile = await EditProfileModel.loadByUserId();
    setState(() {
      userProfile = profile;
    });
  }

  Future<void> loadDevices() async {
    print('loadDevices called'); // Debugging print statement
    List<DeviceModel> loadedDevices = await DeviceModel.getDevice();
    print('Devices loaded: ${loadedDevices.length}'); // Debugging print statement
    setState(() {
      devices = loadedDevices;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (_) => false,
    );
  }

  void _editProfile(BuildContext context) {
    if (userProfile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage(editProfile: userProfile!)),
      ).then((_) {
        loadByEmail(); // Refresh profile data after editing
      });
    }
  }

  void _showDevicesDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userIdValue = prefs.get('userId');
    int userId = 0;

    if (userIdValue is int) {
      userId = userIdValue;
    } else if (userIdValue is String) {
      userId = int.tryParse(userIdValue) ?? 0;
    }

    print('Retrieved userId in dashboard: $userId');

    List<DeviceModel> devices = await DeviceModel.getDevice(); // Fetch devices

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manage Devices'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connected Devices:'),
                if (devices.isEmpty)
                  Text('No devices connected.'),
                for (var device in devices)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${device.id}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text(device.name),
                        subtitle: Text('Age: ${device.age}, Relationship: ${device.relationship}'),
                        onTap: () {
                          // Handle device selection if needed
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      Divider(), // Add a divider between devices
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _showAddDeviceDialog(context, userId); // Open add device dialog
              },
              child: Text('Add Device'),
            ),
          ],
        );
      },
    );
  }



  void _showAddDeviceDialog(BuildContext context, int userId) {
    TextEditingController nameController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Device'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Device Name'),
                ),
                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(labelText: 'Device Age'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: relationshipController,
                  decoration: InputDecoration(labelText: 'Relationship'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _showDevicesDialog(context); // Reopen the manage devices dialog
              },
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                int age = int.tryParse(ageController.text.trim()) ?? 0;
                String relationship = relationshipController.text.trim();

                if (name.isEmpty || age <= 0 || relationship.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invalid Input'),
                      content: Text('Please enter valid details for all fields.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                DeviceModel newDevice = DeviceModel(
                  id: '',
                  deviceId: '48:3f:da:09:0a:c1', // This will be set by the backend
                  name: name,
                  age: age,
                  relationship: relationship,
                  userId: userId, // Assign userId retrieved from SharedPreferences as int
                );

                bool added = await newDevice.addDevice();
                if (added) {
                  // Refresh device list after adding
                  await loadDevices();
                  Navigator.pop(context); // Close the dialog
                  _showDevicesDialog(context); // Show devices dialog again to reflect changes

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Device added successfully!'),
                      duration: Duration(seconds: 2), // Adjust as needed
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Failed to Add Device'),
                      content: Text('Unable to add device at the moment. Please try again later.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Add Device'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null, // Remove the title from app bar
        backgroundColor: Colors.transparent, // Make the AppBar transparent
        elevation: 0, // Remove the AppBar shadow
      ),
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey[800]!, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: -50,
            right: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.tealAccent.withOpacity(0.3),
            ),
          ),
          userProfile == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80), // Add some space below the AppBar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    userProfile!.profileImage.isNotEmpty
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(
                        base64Decode(userProfile!.profileImage),
                      ),
                    )
                        : CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Name:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Email:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Phone Number:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.phoneNo,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Address:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.address,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Birth Date:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.birthDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Gender:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  userProfile!.gender,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _editProfile(context), // Replace with your function
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueGrey[800],
                        backgroundColor: Colors.tealAccent, // Text color
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _showDevicesDialog(context), // Replace with your function
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueGrey[800],
                        backgroundColor: Colors.tealAccent, // Text color
                      ),
                      child: Text(
                        'Devices',
                        style: TextStyle(
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _logout(context), // Replace with your logout function
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueGrey[800],
                        backgroundColor: Colors.tealAccent, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
