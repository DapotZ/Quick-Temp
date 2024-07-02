import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:firebase_database/firebase_database.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animationController.repeat();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedOpacity(
        opacity: _isLoading ? 1.0 : 0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff536ACD),
                Color(0xffF395FF),
                Color(0xff53ACE7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/iconlogo.png',
                  width: 110,
                  height: 100,
                ),
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'QUICKTEMP',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Carousel(),
    );
  }
}

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _opacityController;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isPanelOpen = false;
  late DatabaseReference _temperatureRef;
  late CollectionReference _historyRef;
  String _temperature = '';

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacityController.repeat(reverse: true);

    _temperatureRef = FirebaseDatabase.instance.ref().child('temperature');
    _temperatureRef.onValue.listen((event) {
      setState(() {
        _temperature = event.snapshot.value.toString();
        _buildPageData[1].suhu = _temperature;
      });
    });

    _historyRef = FirebaseFirestore.instance.collection('Temperatures');
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    String formattedDay = formatHari(formattedDate);
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildPage(
              "Page 1",
              const Color(0xff50BCE9),
              const Color(0xff5A6CDD),
              "QUICKTEMP",
              _buildPageData[1].suhu,
              "assets/images/fever.png",
              "You're sick, see a doctor!",
              formattedDay,
              formattedDate,
            ),
            _buildPage(
              "Page 2",
              const Color(0xffE0A1E8),
              const Color(0xffF79D82),
              "QUICKTEMP",
              _buildPageData[1].suhu,
              "assets/images/fever.png",
              "You're sick, see a doctor!",
              formattedDay,
              formattedDate,
            ),
          ],
        ),
        Positioned(
          top: 230,
          left: 10,
          child: AnimatedBuilder(
            animation: _opacityController,
            builder: (context, child) {
              return Opacity(
                opacity: _currentPage == 1 ? _opacityController.value : 0.0,
                child: IconButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        _isPanelOpen = !_isPanelOpen;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 230,
          right: 10,
          child: AnimatedBuilder(
            animation: _opacityController,
            builder: (context, child) {
              return Opacity(
                opacity: _currentPage == 0 ? _opacityController.value : 0.0,
                child: IconButton(
                  onPressed: () {
                    if (_currentPage < 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        _isPanelOpen = !_isPanelOpen;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
        ),
        SlidingUpPanel(
          minHeight: 250,
          maxHeight: 700,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          panel: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 12, right: 12, bottom: 0),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "History",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: Color(0xffB9B9B9),
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                    ),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _historyRef
                        .orderBy('TimeStamp', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const CircularProgressIndicator();
                      }

                      var data = snapshot.data!.docs;
                      var halfLength = (data.length / 2).ceil();

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: halfLength,
                        itemBuilder: (context, index) {
                          var leftIndex = index * 2;
                          var rightIndex = leftIndex + 1;

                          return Row(
                            children: [
                              Expanded(
                                child: _buildListItem(data[leftIndex]),
                              ),
                              Expanded(
                                child: rightIndex < data.length
                                    ? _buildListItem(data[rightIndex])
                                    : const SizedBox(),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  Widget _buildPage(
    String title,
    Color color1,
    Color color2,
    String namaaplikasi,
    String suhu,
    String emot,
    String kondisi,
    String hari,
    String tanggal,
  ) {
    if (double.parse(suhu.replaceAll(',', '.')) >= 36.5 &&
        double.parse(suhu.replaceAll(',', '.')) <= 37.5) {
      emot = "assets/images/love.png";
      kondisi = "You are healthy";
    } else if (double.parse(suhu.replaceAll(',', '.')) > 37.5 &&
        double.parse(suhu.replaceAll(',', '.')) <= 38) {
      emot = "assets/images/sadface.png";
      kondisi = "You might need more rest";
    } else if (double.parse(suhu.replaceAll(',', '.')) > 38) {
      emot = "assets/images/fever.png";
      kondisi = "You're sick, see a doctor!";
    } else {
      emot = "assets/images/fever.png";
      kondisi = "You're sick, see a doctor!";
    }

    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 1.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.67],
              colors: [color1, color2],
            ),
          ),
        ),
        Positioned(
          top: 55,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/iconlogo.png', // Ganti dengan path gambar Anda
                width: 20, // Sesuaikan dengan lebar yang diinginkan
                height: 20, // Sesuaikan dengan tinggi yang diinginkan
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                namaaplikasi,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Rubik',
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 6.5,
          left: 20,
          right: 20,
          child: Text(
            _currentPage == 0
                ? '$suhu°C'
                : suhu == '0' // Jika suhu dalam Celsius adalah 0
                    ? '0°F' // Tetapkan nilai Fahrenheit ke 32
                    : '${_celsiusToFahrenheit(double.parse(suhu.replaceAll(',', '.'))).toStringAsFixed(1)}°F',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 3.28,
          left: 20,
          right: 20,
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(
              emot,
              width: 68,
              height: 68,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2.5,
          left: 20,
          right: 20,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              kondisi,
              style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontFamily: 'Poppins'),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 1.55,
          left: 20,
          right: 20,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              hari,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Poppins'),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 1.49,
          left: 20,
          right: 20,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              tanggal,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'Poppins'),
            ),
          ),
        ),
      ],
    );
  }

  String formatTglIndo(String timeStampString) {
    // Memisahkan tanggal, bulan, dan tahun dari timeStampString
    List<String> parts = timeStampString.split(' ')[0].split('-');
    String year = parts[0];
    String month = parts[1];
    String day = parts[2];

    // Membuat daftar nama bulan dalam bahasa Indonesia
    List<String> months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];

    // Mengambil nama bulan sesuai dengan indeks bulan
    String monthName = months[int.parse(month) - 1];

    // Mengembalikan tanggal dalam format "d bulan tahun"
    return "$day $monthName $year";
  }

  Widget _buildListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String suhu = data['Temperature'] ?? '';
    String timeStampString = data['TimeStamp'] ?? DateTime.now().toString();
    DateTime timestamp;
    try {
      timestamp = DateTime.parse(timeStampString);
    } catch (e) {
      timestamp = DateTime.now();
    }
    String emot = '';
    String kondisi = '';

    if (suhu.isNotEmpty) {
      double suhuDouble = double.parse(suhu.replaceAll(',', '.'));

      if (suhuDouble >= 36.5 && suhuDouble <= 37.5) {
        emot = "assets/images/love.png";
        kondisi = "You are healthy";
      } else if (suhuDouble > 37.5 && suhuDouble <= 38) {
        emot = "assets/images/sadface.png";
        kondisi = "You might need more rest";
      } else if (suhuDouble > 38) {
        emot = "assets/images/fever.png";
        kondisi = "You're sick, see a doctor!";
      } else {
        emot = "assets/images/fever.png";
        kondisi = "You're sick, see a doctor!";
      }
    }

    String formattedDate = formatTglIndo(timeStampString);
    String formattedTime = DateFormat('jm').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
      child: Container(
        decoration: BoxDecoration(
          color: _currentPage == 0
              ? const Color(0xffBBEAFF)
              : const Color(0xffFFD7CF),
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        height: 150,
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 12,
                right: 12,
              ),
              child: Text(
                _currentPage == 0
                    ? '$suhu°C'
                    : '${_celsiusToFahrenheit(double.parse(suhu.replaceAll(',', '.'))).toStringAsFixed(1)}°F',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 17,
                top: 3,
                right: 12,
              ),
              child: Row(
                children: [
                  Image.asset(
                    emot,
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      kondisi,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 0,
                  right: 12,
                ),
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 0,
                  right: 12,
                ),
                child: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Color(0xff6E6E6E),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

String formatHari(String tanggal) {
  DateTime dateTime = DateFormat("dd/MM/yyyy").parse(tanggal);

  var day = DateFormat('EEEE').format(dateTime);
  var hari = "";
  switch (day) {
    case 'Sunday':
      {
        hari = "Minggu";
      }
      break;
    case 'Monday':
      {
        hari = "Senin";
      }
      break;
    case 'Tuesday':
      {
        hari = "Selasa";
      }
      break;
    case 'Wednesday':
      {
        hari = "Rabu";
      }
      break;
    case 'Thursday':
      {
        hari = "Kamis";
      }
      break;
    case 'Friday':
      {
        hari = "Jumat";
      }
      break;
    case 'Saturday':
      {
        hari = "Sabtu";
      }
      break;
  }
  return hari;
}

class BuildPageData {
  String suhu;
  final String emot;
  final String kondisi;
  final String tanggal;
  final String jam;

  BuildPageData({
    required this.suhu,
    required this.emot,
    required this.kondisi,
    required this.tanggal,
    required this.jam,
  });
}

final List<BuildPageData> _buildPageData = [
  BuildPageData(
    suhu: '40',
    emot: "assets/images/fever.png",
    kondisi: "You're sick, see a doctor!",
    tanggal: "23 January 2024",
    jam: "11:44 PM",
  ),
  BuildPageData(
    suhu: '0',
    emot: "assets/images/fever.png",
    kondisi: "You're sick, see a doctor!",
    tanggal: "23 January 2024",
    jam: "11:44 PM",
  ),
];
