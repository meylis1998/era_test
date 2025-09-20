import 'package:flutter_test/flutter_test.dart';
import 'package:era_test/features/posts/domain/entities/post.dart';

void main() {
  group('Post Entity', () {
    const tPost = Post(
      userId: 1,
      id: 1,
      title: 'Test Title',
      body: 'Test Body',
    );

    test('should be a subclass of Equatable', () {
      // Assert
      expect(tPost, isA<Object>());
    });

    test('should return correct props for equality comparison', () {
      // Act
      final props = tPost.props;

      // Assert
      expect(props, [1, 1, 'Test Title', 'Test Body']);
    });

    test('should support equality comparison', () {
      // Arrange
      const tPost1 = Post(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      const tPost2 = Post(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(tPost1, equals(tPost2));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      const tPost1 = Post(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      const tPost2 = Post(
        userId: 2,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(tPost1, isNot(equals(tPost2)));
    });

    test('should have consistent hashCode for equal objects', () {
      // Arrange
      const tPost1 = Post(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      const tPost2 = Post(
        userId: 1,
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
      );

      // Assert
      expect(tPost1.hashCode, equals(tPost2.hashCode));
    });

    test('should create instance with all required properties', () {
      // Act & Assert
      expect(tPost.userId, 1);
      expect(tPost.id, 1);
      expect(tPost.title, 'Test Title');
      expect(tPost.body, 'Test Body');
    });
  });
}