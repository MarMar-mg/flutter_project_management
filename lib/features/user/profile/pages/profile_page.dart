import 'package:flutter/material.dart';

class ProfileCardPage extends StatefulWidget {
  @override
  _ProfileCardPageState createState() => _ProfileCardPageState();
}

class _ProfileCardPageState extends State<ProfileCardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF35524A), // Updated to deep green-blue from the new palette
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Color(0xFFEAD2AC), // Light beige from the palette
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile.jpg'), // Replace with actual image asset
                ),
                SizedBox(height: 10),
                Text(
                  'Samantha Jones',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C41), // Updated to brownish hue
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'New York, United States',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA3A380), // Soft greenish tone
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Web Producer - Web Specialist\nColumbia University - New York',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF28D7B), // Coral pink for emphasis
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('65', 'Friends'),
                    _buildStatItem('43', 'Photos'),
                    _buildStatItem('21', 'Comments'),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF28D7B), // Coral pink for button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'Show more',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6D4C41), // Brownish hue
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFA3A380), // Soft greenish tone
          ),
        ),
      ],
    );
  }
}
