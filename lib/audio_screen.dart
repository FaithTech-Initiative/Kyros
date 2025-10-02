import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioScreen extends StatefulWidget {
  final String userId;

  const AudioScreen({super.key, required this.userId});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _audioPath;
  bool _isRecording = false;

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recording.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      await _audioPlayer.setFilePath(_audioPath!);
      _audioPlayer.play();
    }
  }

  Future<void> _saveRecording() async {
    if (_audioPath != null) {
      // Here you would typically save the audio file to a permanent location
      // and/or upload it to a cloud storage service like Firebase Storage.
      // For this example, we'll just show a confirmation dialog.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Recording Saved'),
          content: Text('Audio saved at: $_audioPath'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording)
              const Text('Recording in progress...', style: TextStyle(fontSize: 20))
            else
              Text(_audioPath == null ? 'Press the button to start recording' : 'Recording complete', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRecording)
                  ElevatedButton(
                    onPressed: _startRecording,
                    child: const Icon(Icons.mic, size: 50),
                  )
                else
                  ElevatedButton(
                    onPressed: _stopRecording,
                    child: const Icon(Icons.stop, size: 50),
                  ),
                const SizedBox(width: 20),
                if (_audioPath != null)
                  ElevatedButton(
                    onPressed: _playRecording,
                    child: const Icon(Icons.play_arrow, size: 50),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            if (_audioPath != null)
              ElevatedButton(
                onPressed: _saveRecording,
                child: const Text('Save Recording'),
              ),
          ],
        ),
      ),
    );
  }
}
