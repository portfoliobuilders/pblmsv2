import 'package:flutter/material.dart';



class AddCoursePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Course',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'DELETE COURSE',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'SAVE CHANGES',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'HOME > EDIT COURSE',
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      buildSection(
                        title: 'BASIC INFORMATION',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInputField('COURSE TITLE', 'Angular Fundamentals'),
                            SizedBox(height: 8),
                            Text(
                              'Please see our course title guideline',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            SizedBox(height: 16),
                            buildDescriptionEditor(),
                            SizedBox(height: 8),
                            Text(
                              'Shortly describe this course.',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      buildSection(
                        title: 'SECTIONS',
                        content: Column(
                          children: [
                            buildSectionItem('Course Overview', Icons.expand_more),
                            buildExpandableSection(
                              'Getting Started with Angular',
                              items: [
                                buildLessonItem('Introduction', '8m 42s'),
                                buildLessonItem('Introduction to TypeScript', '50m 13s'),
                                buildLessonItem('Comparing Angular to AngularJS', '12m 10s'),
                                buildLessonItem('Quiz: Getting Started With Angular', ''),
                              ],
                            ),
                            buildSectionItem('Creating and Communicating Between Angular Components', Icons.expand_more),
                            buildSectionItem('Exploring the Angular Template Syntax', Icons.expand_more),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          'ADD SECTION',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      buildSection(
                        title: 'THUMBNAIL',
                        content: Column(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                'https://storage.googleapis.com/a1aa/image/EVJ0p8xsBj58ANpWTbhreP9G4xrVmlJNHtnVZpbfUYUjqhuTA.jpg',
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: Text('UPLOAD IMAGE'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      buildSection(
                        title: 'LIVE CLASS LINK',
                        content: buildInputField(
                          'Enter a valid Zoom Meeting URL.',
                          'https://Zoom.meeting/972432',
                        ),
                      ),
                      SizedBox(height: 16),
                      buildSection(
                        title: 'VIDEO',
                        content: Column(
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              child: Image.network(
                                'https://storage.googleapis.com/a1aa/image/7tmJHb14iWLnEhJ5txhY7TY79fZqGRfgbcWnbo9eDf4TqG6OB.jpg',
                              ),
                            ),
                            SizedBox(height: 8),
                            buildInputField(
                              'Enter a valid video URL.',
                              'https://player.vimeo.com/video/972432',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      buildSection(
                        title: 'OPTIONS',
                        content: DropdownButtonFormField<String>(
                          items: [
                            DropdownMenuItem(
                              child: Text('VueJS'),
                              value: 'VueJS',
                            ),
                          ],
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({required String title, required Widget content}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget buildInputField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDescriptionEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(icon: Icon(Icons.format_bold), onPressed: () {}),
            IconButton(icon: Icon(Icons.format_italic), onPressed: () {}),
            IconButton(icon: Icon(Icons.format_underline), onPressed: () {}),
            IconButton(icon: Icon(Icons.format_strikethrough), onPressed: () {}),
            IconButton(icon: Icon(Icons.format_quote), onPressed: () {}),
            IconButton(icon: Icon(Icons.code), onPressed: () {}),
          ],
        ),
        Divider(),
        Text(
          'Hello World!',
          style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
        ),
        Text(
          'Some initial bold text',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget buildSectionItem(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Icon(icon, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget buildExpandableSection(String title, {required List<Widget> items}) {
    return Column(
      children: [
        buildSectionItem(title, Icons.expand_less),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget buildLessonItem(String title, String duration) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.drag_handle, color: Colors.grey[500]),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        Text(duration, style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }
}
