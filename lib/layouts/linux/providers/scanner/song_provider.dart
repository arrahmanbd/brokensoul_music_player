import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:soul_player/layouts/linux/models/song_model.dart';
import 'package:soul_player/database/local_database.dart';
import 'song_state.dart';

class SongScanner extends StateNotifier<SongScanState> {
  SongScanner()
      : super(
          SongScanState(
            isloading: false,
            songs: [],
          ),
        ) {
    retriveCache();
  }

  Future<List<File>> pickSongs(String? dir) async {
    try {
      String? selectedDirectory;
      if (dir != null && dir.isNotEmpty) {
        selectedDirectory = dir;
      } else {
        //if argument not passed then open picker
        selectedDirectory = await FilePicker.platform.getDirectoryPath();
      }
      Directory downloadsDir = Directory(selectedDirectory.toString());
      var downloadsList =
          downloadsDir.list(recursive: true, followLinks: false);

      List<File> songs = [];
      await for (FileSystemEntity entity in downloadsList) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          songs.add(entity);
        }
      }
      songs.sort((a, b) => a.path.compareTo(b.path));
      return songs;
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning songs: $e');
      }
      return []; // or handle error appropriately
    }
  }

  ///check cashed song
  ///
  Future<void> retriveCache() async {
    List<AudioModel> cachedSongs =
        await SongDatabaseHelper.instance.getAllSongs();
    if (cachedSongs.isNotEmpty) {
      state = state.copyWith(songs: cachedSongs, isloading: false);
      return;
    }
  }

  Future<void> refreshSongs() async {
    final refresh = retriveCache();
  }

  Future<void> getAllSongs() async {
    try {
      state = state.copyWith(isloading: true);
      // Check database for cached songs
      retriveCache();
      // If no cached songs, scan and fetch new songs
      final List<AudioModel> allSongs = [];
      final List<File> songs = await pickSongs('');

      for (File songFile in songs) {
        try {
          // Fetch metadata for each song
          Metadata filemetadata =
              await MetadataGod.readMetadata(file: songFile.path);
          //print(filemetadata.title.toString());

          // Create SongModel using factory constructor
          AudioModel eachSong =
              AudioModel.fromMetadata(songFile.path, filemetadata);

          allSongs.add(eachSong);

          // Cache the song in the database
          await SongDatabaseHelper.instance.insertSong(eachSong);
        } catch (e) {
          // Handle individual file metadata errors
          print("Error reading metadata for ${songFile.path}: $e");
          // Skip the current file and continue with the next one
          continue;
        }
      }

      // Update the state with the list of all valid songs
      state = state.copyWith(songs: allSongs, isloading: false);
    } catch (e) {
      // Handle general errors
      print("Error getting all songs: $e");
      state = state.copyWith(isloading: false);
    }
  }
}

final scanProvider = StateNotifierProvider<SongScanner, SongScanState>((ref) {
  return SongScanner();
});