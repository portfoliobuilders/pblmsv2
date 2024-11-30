import 'package:flutter/material.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dash> {
  int? selectedButton; // Track the selection state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check screen width to determine if it's mobile, tablet, or desktop
          bool isDesktop = constraints.maxWidth >= 1024;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 50 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Row with title, description, categories, and button
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Courses',
                            style: TextStyle(
                              fontSize: isDesktop ? 32 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your courses here.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      Spacer(),
                      if (!isDesktop && !isTablet)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () {
                              print('Create Course button tapped');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Create Course',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      if (isDesktop || isTablet)
                        Row(
                          children: [
                            Text('12 categories | 139 courses',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'Create Course',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 30 : 20),
                  // Category header row with separator
                  Row(
                    // Adds spacing between elements
                    children: [
                      Flexible(
                        child: Text(
                          'Course Category',
                          style: TextStyle(fontSize: isDesktop ? 18 : 16),
                          overflow: TextOverflow
                              .ellipsis, // This ensures long text is truncated on smaller screens
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_document),
                        onPressed: () {},
                        tooltip: 'Edit Category',
                      ),
                      if (isDesktop)
                        Container(
                          width: 900, // Fixed width for desktop
                          height: 1,
                          color: Colors.grey,
                        ),
                      if (!isDesktop)
                        Flexible(
                          child: Container(
                            width: 900, // Stretches the line on smaller screens
                            height: 1, // Height adjusted for mobile
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: isDesktop ? 30 : 20),
                  // Card Row
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(3, (index) {
                      return GestureDetector(
                        onTap: () {
                          print("Card tapped!");
                        },
                        child: Container(
                          width: isDesktop ? 200 : 160,
                          height: isDesktop ? 200 : 160,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: isDesktop ? 160 : 120,
                                    color: Color.fromARGB(255, 0, 86, 156),
                                    child: Center(
                                      // child: Image.asset(
                                      //   'assets/sap.png',
                                      //   width: 100,
                                      //   height: 100,
                                      //   fit: BoxFit.contain,
                                      // ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'SAP Cloud',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_document,
                                            color: Colors.grey,
                                            size: 18,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: isDesktop ? 20 : 15),
                  // Pagination Row
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          print('Prev button pressed');
                        },
                        child: Text('Prev'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      ...List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedButton = index + 1;
                              });
                              print("Button ${index + 1} tapped");
                            },
                            highlightColor: Colors.blue,
                            splashColor: Colors.blue,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selectedButton == index + 1
                                    ? Colors.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: selectedButton == index + 1
                                      ? Colors.transparent
                                      : Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selectedButton == index + 1
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      TextButton(
                        onPressed: () {
                          print('Next button pressed');
                        },
                        child: Text('Next'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 30 : 20),

                  // On smaller screens, move 'Create Course' to bottom
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}