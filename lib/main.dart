import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Custom Gradient Text Widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design Workshop Cards',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1A1A1A),
      ),
      home: CardsScreen(),
    );
  }
}

class CardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Design Workshop Cards',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Headers
            GradientText(
              text: 'Card Variations',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            SizedBox(height: 20),

            // Minimal Cards
            GradientText(
              text: 'Minimal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            SizedBox(height: 16),
            MinimalCard(),
            SizedBox(height: 12),
            MinimalCtaCard(),
            SizedBox(height: 24),

            // Big Card
            GradientText(
              text: 'Big',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            SizedBox(height: 16),
            BigCard(),
            SizedBox(height: 24),

            // Event Details Cards
            GradientText(
              text: 'Event Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              gradient: LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            SizedBox(height: 16),
            EventDetailsCard(),
            SizedBox(height: 12),
            EventDetailsWithResourcesCard(),
          ],
        ),
      ),
    );
  }
}

// Minimal Card Widget
class MinimalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0x66393741),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,

            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red,
              child: Text(
                'W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awwwards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Aktiv Grotesk',
                    fontWeight: FontWeight.w800,
                    height: 1.33,
                  ),
                ),
                Text(
                  '22 July at 5:00 PM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 13,
                    fontFamily: 'Aktiv Grotesk',
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                    letterSpacing: 0.26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal CTA Card Widget
class MinimalCtaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0x66393741),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.red,
              child: Text(
                'W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awwwards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Aktiv Grotesk',
                    fontWeight: FontWeight.w800,
                    height: 1.33,
                  ),
                ),
                Text(
                  '22 July at 5:00 PM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 13,
                    fontFamily: 'Aktiv Grotesk',
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                    letterSpacing: 0.26,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(130),
            ),
            child: Text(
              'Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Aktiv Grotesk',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Big Card Widget
class BigCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0x66393741),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 335,
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white, Color(0xFF666666)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                'Design Workshop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontFamily: 'Aktiv Grotesk',
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -3,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.25),
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                'Starbucks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Aktiv Grotesk',
                  fontWeight: FontWeight.w500,
                  height: 1.20,
                ),
              ),
            ],
          ),
          SizedBox(height: 68),
          Opacity(
            opacity: 0.10,
            child: Container(
              width: 340,
              height: 1,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                height: 48,
                width: 48,

                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red,
                  child: Text(
                    'W',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Awwwards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Aktiv Grotesk',
                        fontWeight: FontWeight.w800,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      '22 July at 5:00 PM',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 13,
                        fontFamily: 'Aktiv Grotesk',
                        fontWeight: FontWeight.w400,
                        height: 1.38,
                        letterSpacing: 0.26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Event Details Card Widget
class EventDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BigCard(),
          SizedBox(height: 25),
          Text(
            'Agenda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Aktiv Grotesk',
              fontWeight: FontWeight.w800,
              height: 1.33,
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: ShapeDecoration(
              color: const Color(0x66393741),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Column(
              children: [

                AgendaItem(number: '01', title: 'Go through moodboards'),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 10),
                  child: Opacity(
                    opacity: 0.20,
                    child: Divider(
                      height: 1,
                      indent: 50,
                      color:  Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                ),
                AgendaItem(number: '02', title: 'Sketch initial concepts'),
                Padding(
                  padding:  EdgeInsets.symmetric(vertical: 10),
                  child: Opacity(
                    opacity: 0.20,
                    child: Divider(
                      height: 1,
                      indent: 50,
                      color:  Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                ),
                AgendaItem(number: '03', title: 'Develop wireframes'),
              ],
            ),
          )

        ],
      ),
    );
  }
}

// Event Details with Resources Card Widget
class EventDetailsWithResourcesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventDetailsCard(),
          SizedBox(height: 24),
          Text(
            'Resources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Aktiv Grotesk',
              fontWeight: FontWeight.w800,
              height: 1.33,
            ),
          ),

          SizedBox(height: 15),
          Row(
            children: [
              ResourceIcon(label: 'Figma', color: Colors.purple, icon: 'F'),
              SizedBox(width: 12),
              ResourceIcon(
                label: 'Miro Board',
                color: Colors.yellow,
                icon: 'M',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Agenda Item Widget
class AgendaItem extends StatelessWidget {
  final String number;
  final String title;

  const AgendaItem({Key? key, required this.number, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF404040),
            borderRadius: BorderRadius.circular(90),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 13,
                fontFamily: 'Aktiv Grotesk',
                fontWeight: FontWeight.w400,
                height: 1.38,
                letterSpacing: 0.26,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
         title,
          style: TextStyle(color: Colors.white,
            fontSize: 15,
            fontFamily: 'Aktiv Grotesk',
            fontWeight: FontWeight.w800,
            height: 1.33,),

        ),
      ],
    );
  }
}

// Resource Icon Widget
class ResourceIcon extends StatelessWidget {
  final String label;
  final Color color;
  final String icon;

  const ResourceIcon({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10,left: 10,right: 30,bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF404040),
        borderRadius: BorderRadius.circular(70),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: color,
              child: Text(
                icon,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          GradientText(
            text: label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey[300]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}
