import 'package:get/get.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostController extends GetxController {
  final PostService _service = PostService();
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void fetchPosts() {
    posts.bindStream(_service.getPosts());
  }

  Future<void> addPost(PostModel post) async {
    isLoading(true);
    await _service.createPost(post);
    isLoading(false);
  }

  Future<void> updatePost(PostModel post) async {
    await _service.updatePost(post);
  }

  Future<void> deletePost(String id) async {
    await _service.deletePost(id);
  }
}
