import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final _db = FirebaseFirestore.instance.collection("Posts");

  /// Create new post
  Future<void> createPost(PostModel post) async {
    await _db.add(post.toMap());
  }

  /// Get all posts as stream
  Stream<List<PostModel>> getPosts() {
    return _db.snapshots().map(
          (snapshot) =>
          snapshot.docs.map((doc) => PostModel.fromDoc(doc)).toList(),
    );
  }

  /// Update post
  Future<void> updatePost(PostModel post) async {
    await _db.doc(post.id).update(post.toMap());
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await _db.doc(postId).delete();
  }
}
