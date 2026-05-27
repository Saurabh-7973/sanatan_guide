import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';

/// Fetches Bhagavad Gita verses from the public vedicscriptures.github.io API
/// (same source as [tool/seed_database.dart]) when they are not in local SQLite.
final class BhagavadGitaRemoteDataSource {
  BhagavadGitaRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                followRedirects: true,
                maxRedirects: 3,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: const {'Accept': 'application/json'},
              ),
            );

  final Dio _dio;

  static const _base = 'https://vedicscriptures.github.io/slok';

  Future<Either<Failure, Verse>> fetchVerseByCompositeId(String id) async {
    final parts = id.split('.');
    if (parts.length != 3 || parts[0].toUpperCase() != 'BG') {
      return const Left(NotFoundFailure('Invalid Gita verse id'));
    }
    final ch = int.tryParse(parts[1]);
    final v = int.tryParse(parts[2]);
    if (ch == null || v == null) {
      return const Left(NotFoundFailure('Invalid Gita verse id'));
    }
    return _fetchOne(ch, v);
  }

  Future<Either<Failure, List<Verse>>> fetchChapter(int chapterNum) async {
    if (chapterNum < 1 || chapterNum > 18) {
      return Left(
        ValidationFailure('Invalid chapter: $chapterNum'),
      );
    }
    final count = BhagavadGitaChapters.byNumber(chapterNum).verseCount;
    final verses = <Verse>[];
    for (var v = 1; v <= count; v++) {
      final r = await _fetchOne(chapterNum, v);
      switch (r) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          verses.add(value);
      }
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    return Right(verses);
  }

  Future<Either<Failure, Verse>> _fetchOne(int chapter, int verseNum) async {
    final url = '$_base/$chapter/$verseNum';
    try {
      final response = await _dio.get<dynamic>(url);
      if (response.statusCode != 200 || response.data == null) {
        return Left(
          ServerFailure(
            message: 'HTTP ${response.statusCode} for BG.$chapter.$verseNum',
            statusCode: response.statusCode,
          ),
        );
      }
      final Map<String, dynamic> data;
      final raw = response.data;
      if (raw is String) {
        data = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        data = raw;
      } else {
        return Left(
          ServerFailure(
            message: 'Unexpected JSON for BG.$chapter.$verseNum',
          ),
        );
      }
      final sanskrit = (data['slok'] as String? ?? '').trim();
      if (sanskrit.isEmpty) {
        return Left(
          ServerFailure(
            message: 'Empty Sanskrit for BG.$chapter.$verseNum',
          ),
        );
      }
      final transliteration = (data['transliteration'] as String?)?.trim();
      final hindi = _extractHindi(data);
      final english = _extractEnglish(data);
      return Right(
        Verse(
          id: 'BG.$chapter.$verseNum',
          chapterNum: chapter,
          verseNum: verseNum,
          scripture: Scripture.bhagavadGita,
          sanskrit: sanskrit,
          transliteration: transliteration,
          hindi: hindi,
          english: english,
          createdAt: DateTime.now(),
        ),
      );
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

String? _extractHindi(Map<String, dynamic> data) {
  for (final key in ['tej', 'san', 'ramsukh', 'jaya']) {
    final t = data[key];
    if (t is Map<String, dynamic>) {
      final ht = (t['ht'] as String?)?.trim();
      if (ht != null && ht.isNotEmpty) return ht;
    }
  }
  for (final entry in data.entries) {
    if (entry.value is Map<String, dynamic>) {
      final ht =
          ((entry.value as Map<String, dynamic>)['ht'] as String?)?.trim();
      if (ht != null && ht.isNotEmpty) return ht;
    }
  }
  return null;
}

String? _extractEnglish(Map<String, dynamic> data) {
  for (final key in ['siva', 'purohit', 'chinmay', 'adi', 'gambir', 'anand']) {
    final t = data[key];
    if (t is Map<String, dynamic>) {
      final et = (t['et'] as String?)?.trim();
      if (et != null && et.isNotEmpty) return et;
    }
  }
  for (final entry in data.entries) {
    if (entry.value is Map<String, dynamic>) {
      final et =
          ((entry.value as Map<String, dynamic>)['et'] as String?)?.trim();
      if (et != null && et.isNotEmpty) return et;
    }
  }
  return null;
}
