import 'package:flutter/material.dart';
import 'package:gracetech_video_player_app/provider/video_provider.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  // declaring route for navigation
  static const route = 'videoPlayer';

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  bool _isLoading = true;
  bool isVideoCompleted = false;
  VideoProvider videoProvider =
      Provider.of<VideoProvider>(Get.context!, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playVideo();
  }

// method for playing video
  void playVideo() {
    // video links consist of http instead of https so first we convet http to https
    Uri originalUri = Uri.parse(videoProvider
        .videoModel!.categories[0].videos[videoProvider.index!].sources[0]);
    Uri updatedUri = Uri.https(originalUri.authority, originalUri.path);

    // initiallize the video player controler
    _controller = VideoPlayerController.network('$updatedUri')
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          allowFullScreen: true,
          autoPlay: true,
          showControls: true,
          showOptions: true,
          additionalOptions: (context) {
            return <OptionItem>[
              OptionItem(
                  onTap: () {}, iconData: Icons.play_arrow, title: 'next'),
            ];
          },
        );
        setState(() {
          print('112233 ');
          _chewieController.enterFullScreen();
          _isLoading = false;
        });
      });

    setState(() {
      _controller.addListener(() async {
        if (!_controller.value.isPlaying &&
            _controller.value.isInitialized &&
            (_controller.value.duration == _controller.value.position)) {
          isVideoCompleted = true;
        }
      });
    });
  }

//dipose the both controllers whene screen is dispose off
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _chewieController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaW = MediaQuery.of(context).size.width;
    final mediaH = MediaQuery.of(context).size.height;

    var data =
        videoProvider.videoModel!.categories[0].videos[videoProvider.index!];
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      // checking either video is loaded or not
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                //displaying chewie for video
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Chewie(controller: _chewieController),
                    ),
                  ],
                ),
                SizedBox(
                  height: mediaH * 0.01,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    height: 35,
                    width: 60,
                    child: TextButton(
                      onPressed: () {
                        // check if the video is first video of the list then do noting
                        // if not the first video then play previous video
                        int length = videoProvider
                            .videoModel!.categories[0].videos.length;
                        if (videoProvider.index != 0) {
                          videoProvider.index = videoProvider.index! - 1;
                          _chewieController.dispose();
                          _controller.dispose();
                          _isLoading = true;

                          playVideo();
                          setState(() {});
                        }
                      },
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 5, 48, 70)),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: mediaW * 0.02,
                  ),
                  SizedBox(
                    height: 35,
                    width: 60,
                    child: TextButton(
                      onPressed: () {
                        // first we check the current video is last, if last then show toast
                        // if not the last then play the next video

                        int length = videoProvider
                            .videoModel!.categories[0].videos.length;
                        if (videoProvider.index! < length - 1) {
                          videoProvider.index = videoProvider.index! + 1;
                          _chewieController.dispose();
                          _controller.dispose();
                          _isLoading = true;
                          playVideo();
                          setState(() {});
                        } else {
                          // show toast that this is last video

                          MotionToast.warning(
                                  description: const Text(
                                      'There is no more videos in list'))
                              .show(context);
                        }
                      },
                      style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 5, 48, 70)),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                      ),
                    ),
                  )
                ]),
                SizedBox(
                  height: mediaH * 0.03,
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: mediaH * 0.02,
                      ),
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        height: mediaH * 0.03,
                      ),
                      Text(data.description,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.clip),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
