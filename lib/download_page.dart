import 'package:children_library/upload_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

@immutable
class ExampleCupertinoDownloadButton extends StatefulWidget {
  final List<Map<String, dynamic>> files;
  final age_group;
  final image_path;
  const ExampleCupertinoDownloadButton({
    super.key,
    required this.files,
    required this.age_group,
    required this.image_path,
  });

  @override
  State<ExampleCupertinoDownloadButton> createState() =>
      _ExampleCupertinoDownloadButtonState();
}

class _ExampleCupertinoDownloadButtonState
    extends State<ExampleCupertinoDownloadButton> {
  late final List<DownloadController> _downloadControllers;

  @override
  void initState() {
    super.initState();
    _downloadControllers = List<DownloadController>.generate(
      widget.files.length,
      (index) {
        final fileData = widget.files[index];
        final downloadUrl = fileData['download_url'] ?? '';
        final fileName = fileData['file_name'] ?? 'file_$index.pdf';

        return RealDownloadController(url: downloadUrl, fileName: fileName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Ages" + widget.age_group),
            Image.asset("${widget.image_path}", width: 100, height: 100),
          ],
        ),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      ),
      body: ListView.separated(
        itemCount: _downloadControllers.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: _buildListItem,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadFile,
        tooltip: 'Upload a new file',
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    final downloadController = _downloadControllers[index];

    final fileData = widget.files[index];
    final fileName = fileData['file_name'] ?? 'File without a name';
    final fileType = fileData['file_type'] ?? 'Unknown';

    return ListTile(
      leading: const DemoAppIcon(),
      title: Text(
        fileName,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge,
      ),
      subtitle: Text(
        'Type of file: $fileType',
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: SizedBox(
        width: 96,
        child: AnimatedBuilder(
          animation: downloadController,
          builder: (context, child) {
            return DownloadButton(
              status: downloadController.downloadStatus,
              downloadProgress: downloadController.progress,
              onDownload: downloadController.startDownload,
              onCancel: downloadController.stopDownload,
              onOpen: downloadController.openDownload,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _downloadControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      String fileType = fileName.toLowerCase().endsWith('.pdf')
          ? 'pdf'
          : 'word';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Starting upload $fileName...')));

      try {
        await uploadFileAndSaveMetadata(
          file: file,
          fileName: fileName,
          fileType: fileType,
          ageGroup: widget.age_group,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded Successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
        }
      }
    } else {
      print('File selection canceled');
    }
  }
}

@immutable
class DemoAppIcon extends StatelessWidget {
  const DemoAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        child: SizedBox(
          width: 80,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.red, Colors.blue]),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Center(
              child: Icon(Icons.ac_unit, color: Colors.white, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

enum DownloadStatus { notDownloaded, fetchingDownload, downloading, downloaded }

abstract class DownloadController implements ChangeNotifier {
  DownloadStatus get downloadStatus;
  double get progress;

  void startDownload();
  void stopDownload();
  void openDownload();
}

class RealDownloadController extends DownloadController with ChangeNotifier {
  RealDownloadController({required this.url, required this.fileName});

  final String url;
  final String fileName;

  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String? _savePath;

  DownloadStatus _downloadStatus = DownloadStatus.notDownloaded;
  @override
  DownloadStatus get downloadStatus => _downloadStatus;

  double _progress = 0.0;
  @override
  double get progress => _progress;

  @override
  Future<void> startDownload() async {
    if (downloadStatus == DownloadStatus.notDownloaded) {
      _downloadStatus = DownloadStatus.fetchingDownload;
      notifyListeners();

      try {
        Directory dir = await getApplicationDocumentsDirectory();
        _savePath = '${dir.path}/$fileName';
        _cancelToken = CancelToken();

        _downloadStatus = DownloadStatus.downloading;
        notifyListeners();

        await _dio.download(
          url,
          _savePath,
          cancelToken: _cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              _progress = received / total;
              notifyListeners();
            }
          },
        );

        _downloadStatus = DownloadStatus.downloaded;
        notifyListeners();
      } catch (e) {
        if (CancelToken.isCancel(
          DioException.badCertificate(requestOptions: RequestOptions()),
        )) {
          print('The download was cancel by the user');
        } else {
          print('Download error: $e');
          _downloadStatus = DownloadStatus.notDownloaded;
          _progress = 0.0;
          notifyListeners();
        }
      }
    }
  }

  @override
  void stopDownload() {
    if (_downloadStatus == DownloadStatus.downloading) {
      _cancelToken?.cancel();
      _downloadStatus = DownloadStatus.notDownloaded;
      _progress = 0.0;
      notifyListeners();
    }
  }

  @override
  void openDownload() {
    if (downloadStatus == DownloadStatus.downloaded && _savePath != null) {
      OpenFilex.open(_savePath!);
    }
  }
}

@immutable
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.status,
    this.downloadProgress = 0.0,
    required this.onDownload,
    required this.onCancel,
    required this.onOpen,
    this.transitionDuration = const Duration(milliseconds: 500),
  });

  final DownloadStatus status;
  final double downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onCancel;
  final VoidCallback onOpen;
  final Duration transitionDuration;

  bool get _isDownloading => status == DownloadStatus.downloading;

  bool get _isFetching => status == DownloadStatus.fetchingDownload;

  bool get _isDownloaded => status == DownloadStatus.downloaded;

  void _onPressed() {
    switch (status) {
      case DownloadStatus.notDownloaded:
        onDownload();
        break;
      case DownloadStatus.fetchingDownload:
        break;
      case DownloadStatus.downloading:
        onCancel();
        break;
      case DownloadStatus.downloaded:
        onOpen();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: [
          ButtonShapeWidget(
            transitionDuration: transitionDuration,
            isDownloaded: _isDownloaded,
            isDownloading: _isDownloading,
            isFetching: _isFetching,
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: transitionDuration,
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.ease,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ProgressIndicatorWidget(
                    downloadProgress: downloadProgress,
                    isDownloading: _isDownloading,
                    isFetching: _isFetching,
                  ),
                  if (_isDownloading)
                    const Icon(
                      Icons.stop,
                      size: 14,
                      color: CupertinoColors.activeBlue,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class ButtonShapeWidget extends StatelessWidget {
  const ButtonShapeWidget({
    super.key,
    required this.isDownloading,
    required this.isDownloaded,
    required this.isFetching,
    required this.transitionDuration,
  });

  final bool isDownloading;
  final bool isDownloaded;
  final bool isFetching;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    final ShapeDecoration shape;
    if (isDownloading || isFetching) {
      shape = const ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.transparent,
      );
    } else {
      shape = const ShapeDecoration(
        shape: StadiumBorder(),
        color: CupertinoColors.lightBackgroundGray,
      );
    }

    return AnimatedContainer(
      duration: transitionDuration,
      curve: Curves.ease,
      width: double.infinity,
      decoration: shape,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: AnimatedOpacity(
          duration: transitionDuration,
          opacity: isDownloading || isFetching ? 0.0 : 1.0,
          curve: Curves.ease,
          child: Text(
            isDownloaded ? 'OPEN' : 'GET',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
    required this.downloadProgress,
    required this.isDownloading,
    required this.isFetching,
  });

  final double downloadProgress;
  final bool isDownloading;
  final bool isFetching;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: downloadProgress),
        duration: const Duration(milliseconds: 200),
        builder: (context, progress, child) {
          return CircularProgressIndicator(
            backgroundColor: isDownloading
                ? CupertinoColors.lightBackgroundGray
                : Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              isFetching
                  ? CupertinoColors.lightBackgroundGray
                  : CupertinoColors.activeBlue,
            ),
            strokeWidth: 2,
            value: isFetching ? null : progress,
          );
        },
      ),
    );
  }
}
