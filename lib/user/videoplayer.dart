import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  const VideoPlayerScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isVideoPlaying = false;
  double _currentVideoPosition = 0;
  double _videoDuration = 0;
  Timer? _positionTimer;
  String _currentQuality = 'auto';
  final List<String> _qualities = ['auto', '144p', '240p', '360p', '480p', '720p', '1080p'];
  bool _showQualityMenu = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.url);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        enableJavaScript: true,
        playsInline: true,
        strictRelatedVideos: true,
           pointerEvents: PointerEvents.none,
      ),
    );

    _controller.listen((event) {
      if (event.playerState == PlayerState.playing) {
        setState(() {
          _isVideoPlaying = true;
        });
        _startPositionTimer();
      } else if (event.playerState == PlayerState.paused) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
    });

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller.listen((event) async {
      if (event.playerState == PlayerState.playing) {
        final duration = await _controller.duration;
        final quality = await _controller.videoQuality;
        setState(() {
          _videoDuration = duration.toDouble();
          if (quality != null) {
            _currentQuality = quality;
          }
        });
      }
    });
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (mounted) {
        final position = await _controller.currentTime;
        setState(() {
          _currentVideoPosition = position.toDouble();
        });
      }
    });
  }

  Future<void> _changeQuality(String quality) async {
    try {
      await _controller.setPlaybackQuality(quality);
      setState(() {
        _currentQuality = quality;
        _showQualityMenu = false;
      });
    } catch (e) {
      print('Error changing quality: $e');
    }
  }

  String _formatDuration(double seconds) {
    final Duration duration = Duration(seconds: seconds.round());
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleVideoPlayback() async {
    try {
      if (_isVideoPlaying) {
        await _controller.pauseVideo();
        _positionTimer?.cancel();
      } else {
        await _controller.playVideo();
        _startPositionTimer();
      }
      setState(() {
        _isVideoPlaying = !_isVideoPlaying;
      });
    } catch (e) {
      print('Error toggling playback: $e');
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final videoHeight = screenSize.height * 0.75;
    final videoWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _controller.close();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: videoWidth,
                  height: videoHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_formatDuration(_currentVideoPosition)),
                    Expanded(
                      child: Slider(
                        value: _currentVideoPosition.clamp(0.0, _videoDuration),
                        min: 0.0,
                        max: _videoDuration,
                        onChanged: (value) async {
                          setState(() {
                            _currentVideoPosition = value;
                          });
                          await _controller.seekTo(
                            seconds: value,
                            allowSeekAhead: true,
                          );
                        },
                      ),
                    ),
                    Text(_formatDuration(_videoDuration)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isVideoPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _toggleVideoPlayback,
                      iconSize: 48,
                    ),
                    const SizedBox(width: 20),
                    PopupMenuButton<String>(
                      initialValue: _currentQuality,
                      onSelected: _changeQuality,
                      itemBuilder: (context) => _qualities.map((quality) {
                        return PopupMenuItem<String>(
                          value: quality,
                          child: Row(
                            children: [
                              Text(quality),
                              if (quality == _currentQuality)
                                const Icon(Icons.check, size: 20),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.settings, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _currentQuality,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on YoutubePlayerController {
  get videoQuality => null;

  setPlaybackQuality(String quality) {}
}