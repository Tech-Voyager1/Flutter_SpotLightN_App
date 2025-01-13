// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui' as ui;

// class CachedTileProvider extends TileProvider {
//   final CacheManager cacheManager = CacheManager(Config(
//     'mapTileCache',
//     stalePeriod: Duration(days: 7),
//     maxNrOfCacheObjects: 1000,
//   ));

//   @override
//   ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
//     final url = options.urlTemplate!
//         .replaceAll('{s}', options.subdomains[0])
//         .replaceAll('{z}', coordinates.z.toString())
//         .replaceAll('{x}', coordinates.x.toString())
//         .replaceAll('{y}', coordinates.y.toString());

//     return CachedNetworkImageProvider(url, cacheManager);
//   }
// }

// class CachedNetworkImageProvider
//     extends ImageProvider<CachedNetworkImageProvider> {
//   final String url;
//   final CacheManager cacheManager;

//   CachedNetworkImageProvider(this.url, this.cacheManager);

//   @override
//   Future<CachedNetworkImageProvider> obtainKey(
//       ImageConfiguration configuration) {
//     return Future.value(this); // Return the current object synchronously
//   }

//   @override
//   ImageStreamCompleter load(CachedNetworkImageProvider key) {
//     return MultiFrameImageStreamCompleter(
//       codec: _loadAsync(key), // Load image asynchronously
//       scale: 1.0,
//     );
//   }

//   Future<ui.Codec> _loadAsync(CachedNetworkImageProvider key) async {
//     final file = await cacheManager.getSingleFile(key.url);
//     final bytes = await file.readAsBytes();

//     if (bytes.isEmpty) {
//       throw Exception(
//           'CachedNetworkImageProvider is an empty file: ${key.url}');
//     }

//     // Correct method to decode image from byte data
//     return await ui.instantiateImageCodec(Uint8List.fromList(bytes));
//   }
// }
