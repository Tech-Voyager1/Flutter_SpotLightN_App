import 'package:flutter/material.dart';
import 'package:spotlight/appColor.dart';
import 'package:spotlight/heroSection.dart';

class Drawer_ extends StatefulWidget {
  const Drawer_({Key? key}) : super(key: key);

  @override
  State<Drawer_> createState() => _Drawer_State();
}

class _Drawer_State extends State<Drawer_> {
  final _scaffkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            key: _scaffkey,
            appBar: AppBar(
              backgroundColor: AppColors.darkpurple, //Color(0xfff6649ef),
              elevation: 5,
              shadowColor: Color(0xff5b26d7),
              title: Text(
                "SPOTLIGHT NEARBY",
                style: TextStyle(
                    fontFamily: "Roboto", fontSize: 26, color: Colors.white),
              ),
              toolbarHeight: 130,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    _scaffkey.currentState!.openDrawer();
                  },
                ),
              ),
            ),
            drawer: Drawer(
              child: Column(
                // padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    //  curve: Curves.bounceIn,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200, // Light purple color
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo on the left side
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.darkpurple, width: 2.3),
                            image: DecorationImage(
                              image: AssetImage(
                                  'asset/icons/app_icon.png'), // Your logo path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // App name and creator names
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SpotLight Nearby',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Created by \nVIPIN C & MP ADITHYAN',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.purple.shade300),
                    title: Text('About'),
                    onTap: () {
                      // Navigate to About
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.map, color: Colors.purple.shade300),
                    title: Text('Radius'),
                    onTap: () {
                      // Navigate to Radius
                    },
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.contact_page, color: Colors.purple.shade300),
                    title: Text('Contact'),
                    onTap: () {
                      // Navigate to Contact
                    },
                  ),
                ],
              ),
            ),
            body: HeroSection()));
  }
}
