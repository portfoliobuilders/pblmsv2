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
  bool _isDragging = false;
  double _dragPosition = 0;
  bool _isReady = false;

  final List<String> _qualityOptions = ['auto', '240p', '360p', '480p', '720p', '1080p'];
  int _currentQualityIndex = 0;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayerController.convertUrlToId(widget.url);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: false,
        enableJavaScript: true,
        playsInline: true,
        strictRelatedVideos: true,
                pointerEvents: PointerEvents.none, // Disable all pointer events

        
      ),
    );

    _controller.listen((event) {
      if (event.playerState == PlayerState.playing && !_isReady) {
        _initializeVideo();
        _isReady = true;
      }
    });
  }

  Future<void> _initializeVideo() async {
    final duration = await _controller.duration;
    setState(() {
      _videoDuration = duration.toDouble();
      _isVideoPlaying = true;
    });
    _startPositionTimer();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!_isDragging && mounted) {
        final position = await _controller.currentTime;
        setState(() {
          _currentVideoPosition = position.toDouble();
        });
      }
    });
  }

  Future<void> _seekToPosition(double position) async {
    try {
      final clampedPosition = position.clamp(0.0, _videoDuration).toDouble();
      
      // Pause timer during seeking
      _positionTimer?.cancel();
      
      // Seek to the new position
      await _controller.seekTo(seconds: clampedPosition);
      
      setState(() {
        _currentVideoPosition = clampedPosition;
      });

      // Resume timer if video was playing
      if (_isVideoPlaying) {
        _startPositionTimer();
        await _controller.playVideo();
      }
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  Future<void> _seekRelative(double seconds) async {
    try {
      final currentTime = await _controller.currentTime;
      final newPosition = (currentTime + seconds).clamp(0.0, _videoDuration);
      await _seekToPosition(newPosition);
    } catch (e) {
      print('Error relative seeking: $e');
    }
  }

  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds.isInfinite) return '0:00';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller.close();
    super.dispose();
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

  void _increaseQuality() {
    setState(() {
      _currentQualityIndex = (_currentQualityIndex + 1) % _qualityOptions.length;
      _controller.setQuality(_qualityOptions[_currentQualityIndex]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quality set to: ${_qualityOptions[_currentQualityIndex]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.8,
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
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          onPressed: () => _seekRelative(-10),
                          iconSize: 36,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(_isVideoPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: _toggleVideoPlayback,
                          iconSize: 48,
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.forward_10),
                          onPressed: () => _seekRelative(10),
                          iconSize: 36,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onHorizontalDragUpdate: (details) async {
                        final box = context.findRenderObject() as RenderBox;
                        final width = box.size.width;
                        final dx = details.delta.dx;
                        final percentChange = dx / width;
                        final positionChange = percentChange * _videoDuration;
                        
                        setState(() {
                          _isDragging = true;
                          _dragPosition = (_currentVideoPosition + positionChange)
                              .clamp(0.0, _videoDuration);
                        });
                      },
                      onHorizontalDragEnd: (details) async {
                        await _seekToPosition(_dragPosition);
                        setState(() {
                          _isDragging = false;
                        });
                      },
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: Colors.blue,
                          activeTrackColor: Colors.blue,
                          inactiveTrackColor: Colors.grey[300],
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                            elevation: 4,
                          ),
                          trackHeight: 4,
                          overlayColor: Colors.blue.withOpacity(0.2),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _isDragging ? _dragPosition : _currentVideoPosition.clamp(0.0, _videoDuration),
                          min: 0.0,
                          max: _videoDuration,
                          onChangeStart: (value) async {
                            setState(() {
                              _isDragging = true;
                              _dragPosition = value;
                            });
                            await _controller.pauseVideo();
                          },
                          onChanged: (value) {
                            setState(() {
                              _dragPosition = value;
                            });
                          },
                          onChangeEnd: (value) async {
                            await _seekToPosition(value);
                            setState(() {
                              _isDragging = false;
                            });
                            if (_isVideoPlaying) {
                              await _controller.playVideo();
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_isDragging ? _dragPosition : _currentVideoPosition),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDuration(_videoDuration),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _increaseQuality,
                  icon: const Icon(Icons.high_quality),
                  label: const Text('Quality'),
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
  void setQuality(String qualityOption) {}
}
