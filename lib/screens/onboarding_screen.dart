import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingScreen({super.key, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Color themeColor = const Color(0xFFD35400);

  final List<Map<String, String>> _slides = [
    {
      "image": "https://images.unsplash.com/photo-1485965120184-e220f721d03e?q=80&w=600",
      "title": "Temukan Sepeda Impian Anda",
      "desc": "Jelajahi berbagai jenis sepeda pilihan mulai dari Mountain Bike, Road Bike, hingga BMX berkualitas tinggi dengan harga terbaik."
    },
    {
      "image": "https://images.unsplash.com/photo-1544192240-4a34feb0104a?q=80&w=600",
      "title": "Kualitas Terbaik & Terpercaya",
      "desc": "Semua produk sepeda dan perlengkapan aksesoris kami dijamin original dengan standar kualitas teruji untuk performa maksimal."
    },
    {
      "image": "https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?q=80&w=600",
      "title": "Mulai Petualangan Gowes Anda",
      "desc": "Nikmati kemudahan transaksi belanja, pelacakan pesanan real-time, dan pelayanan premium di GowesStore. Let's Ride!"
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Slides PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Column(
                children: [
                  // Image Section
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(slide["image"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Dark overlay gradient for readable contrast
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                              stops: const [0.0, 0.4, 0.9, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Text Content Section
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            slide["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Header Bar (Lewati Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: _currentPage < _slides.length - 1
                ? TextButton(
                    onPressed: widget.onFinished,
                    child: Text(
                      "LEWATI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
          ),

          // Bottom Bar (Dots & Action Button)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 28,
            right: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? themeColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                // Action Button (Next or Get Started)
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onFinished();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == _slides.length - 1 ? themeColor : const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage == _slides.length - 1 ? "MULAI SEKARANG" : "LANJUT",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
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
