// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:metadata_god/metadata_god.dart';

class SongModel {
  final String location;
  final String title;
  final double? durationMs;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final int? trackNumber;
  final int? trackTotal;
  final int? discNumber;
  final int? discTotal;
  final int? year;
  final String? genre;
  final Picture? picture;
  final int? fileSize;
  bool isPlaying;
  String folder;

  SongModel({
    required this.location,
    required this.title,
    this.durationMs,
    this.artist,
    this.album,
    this.albumArtist,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
    this.discTotal,
    this.year,
    this.genre,
    this.picture,
    this.fileSize,
    this.isPlaying = false,
    required this.folder,
  });

  // Convert SongModel to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'title': title,
      'durationMs': durationMs,
      'artist': artist,
      'album': album,
      'albumArtist': albumArtist,
      'trackNumber': trackNumber,
      'trackTotal': trackTotal,
      'discNumber': discNumber,
      'discTotal': discTotal,
      'year': year,
      'genre': genre,
      'picture': picture?.data,
      'fileSize': fileSize,
      'isPlaying': isPlaying ? 1 : 0,
      'folder':folder,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      location: map['location'],
      title: map['title'],
      durationMs: map['durationMs'],
      artist: map['artist'],
      album: map['album'],
      albumArtist: map['albumArtist'],
      trackNumber: map['trackNumber'],
      trackTotal: map['trackTotal'],
      discNumber: map['discNumber'],
      discTotal: map['discTotal'],
      year: map['year'],
      genre: map['genre'],
      picture: map['picture'] != null
          ? Picture(data: map['picture'], mimeType: 'mp3')
          : null,
      fileSize: map['fileSize'],
      isPlaying: map['isPlaying'] == 1 ? true : false,
      folder: map['folder'],
    );
  }

  //metadata get
  factory SongModel.fromMetadata(String location, Metadata metadata,String parent) {
    return SongModel(
      location: location,
      title: metadata.title ?? 'Unknown Title',
      durationMs: metadata.durationMs ?? 0.0,
      artist: metadata.artist ?? 'Unknown Artist',
      album: metadata.album ?? 'Unknown Album',
      albumArtist: metadata.albumArtist,
      trackNumber: metadata.trackNumber,
      trackTotal: metadata.trackTotal,
      discNumber: metadata.discNumber,
      discTotal: metadata.discTotal,
      year: metadata.year,
      genre: metadata.genre,
      picture: metadata.picture,
      fileSize: metadata.fileSize,
      folder: parent,
    );
  }
}
