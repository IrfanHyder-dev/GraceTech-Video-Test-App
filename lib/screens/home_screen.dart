import 'package:flutter/material.dart';
import 'package:gracetech_video_player_app/helpers/app_constants.dart';
import 'package:gracetech_video_player_app/provider/video_provider.dart';
import 'package:gracetech_video_player_app/screens/video_player_screen.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // declaring route for navigation
  static const route = 'homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VideoProvider videoProvider =
      Provider.of<VideoProvider>(Get.context!, listen: true);
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1));
    videoProvider.fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    final mediaW = MediaQuery.of(context).size.width;
    final mediaH = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 130,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          flexibleSpace: ClipPath(
            clipper: _CustomClipper(),
            child: Container(
              height: 200,
              width: mediaW,
              color: const Color(0xff000B49),
              child: const Center(
                child: Text(
                  'Explore',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25),
                ),
              ),
            ),
          ),
        ),
        body: Consumer<VideoProvider>(
          builder: (context, value, child) {
            return value.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Column(
                      children: [
                        SizedBox(
                          height: mediaH * 0.03,
                        ),
                        Container(
                          height: mediaH * 0.69,
                          width: mediaW,
                          // list for displaying videos thumnail
                          child: ListView.separated(
                            itemCount:
                                value.videoModel!.categories[0].videos.length,
                            itemBuilder: (context, index) {
                              var data = value.videoModel!.categories[0].videos;
                              return GestureDetector(
                                onTap: () {
                                  videoProvider.index = index;
                                  Navigator.pushNamed(
                                      context, VideoPlayer.route);
                                },
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Display vide thumbnail
                                      Container(
                                        height: mediaH * 0.245,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    '${AppConstants.VIDEO_BASE_URL}${data[index].thumb}'),
                                                fit: BoxFit.cover),
                                            //color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(17)),
                                      ),
                                      SizedBox(
                                        height: mediaH * 0.02,
                                      ),
                                      // Display video title
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          data[index].title,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ]),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: mediaH * 0.03,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  );
          },
        ));
  }
}

class _CustomClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    double height = size.height;
    double width = size.width;
    var path = Path();
    path.lineTo(0, height - 50);
    path.quadraticBezierTo(width / 2, height, width, height - 50);
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}
