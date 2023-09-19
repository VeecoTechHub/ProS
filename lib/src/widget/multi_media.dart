import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_z/src/extension/extension_index.dart';
import 'package:video_player/video_player.dart';

import '../global_enum/enum_index.dart';

class ProZMultiMedia extends StatefulWidget {
  const ProZMultiMedia({Key? key, required this.source}) : super(key: key);
  final dynamic source;

  @override
  State<ProZMultiMedia> createState() => _ProZMultiMediaState();
}

class _ProZMultiMediaState extends State<ProZMultiMedia> {
  @override
  Widget build(BuildContext context) {
    if (widget.source.runtimeType.toString() == '_File') {
      final File data = widget.source;
      if (data.mediaType() == MediaType.image) {
        return Image.file(
          data,
          fit: BoxFit.fitHeight,
        );
      }
      if (data.mediaType() == MediaType.video) {
        return VideoWidget(source: data);
      }
    }
    if (widget.source.runtimeType == String) {
      final String data = widget.source;
      if (data.isURL && data.mediaType() == MediaType.image) {
        return Image.network(
          data,
          fit: BoxFit.fitHeight,
        );
      }
      if (data.isURL && data.mediaType() == MediaType.video) {
        return VideoWidget(source: data);
      }
    }
    return const Text('error');
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({Key? key, required this.source}) : super(key: key);
  final dynamic source;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.source.runtimeType == String) {
      //'VideoPlayerController.network' is deprecated and shouldn't be used. Use VideoPlayerController.networkUrl instead.
      _controller = VideoPlayerController.network(widget.source)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _controller = VideoPlayerController.file(widget.source)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.black,
          ),
        )
      ],
    );
  }
}