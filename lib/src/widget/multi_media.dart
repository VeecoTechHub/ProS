import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pro_z/src/extension/extension_index.dart';
import 'package:video_player/video_player.dart';

import '../global_enum/enum_index.dart';

class ProZMultiMedia extends StatefulWidget {
  const ProZMultiMedia({
    Key? key,
    required this.source,
    this.fit = BoxFit.fitHeight,
    this.padding,
    this.margin,
    this.height,
    this.width,
  }) : super(key: key);
  final dynamic source;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding, margin;
  final double? height, width;

  @override
  State<ProZMultiMedia> createState() => _ProZMultiMediaState();
}

class _ProZMultiMediaState extends State<ProZMultiMedia> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      height: widget.height,
      width: widget.width,
      child: content(),
    );
  }

  Widget content() {
    if (widget.source.runtimeType.toString() == '_File') {
      final File data = widget.source;
      if (widget.source.toString().toLowerCase().contains("pdf")) {
        return Image.asset(
          "assets/PDF_file_icon.png",
          fit: widget.fit,
        );
      } else if (data.mediaType() == MediaType.video) {
        return VideoWidget(source: data);
      } else if (data.mediaType() == MediaType.image) {
        return Image.file(
          data,
          fit: widget.fit,
        );
      }
    }
    if (widget.source.runtimeType == String) {
      final String data = widget.source;
      if (data.mediaType() == MediaType.image) {
        if (data.isURL) {
          return Image.network(
            data,
            fit: widget.fit,
          );
        } else {
          return Image.asset(
            data,
            fit: widget.fit,
          );
        }
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
