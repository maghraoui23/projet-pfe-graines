class Vote {
  String voteType; // "UPVOTE" or "DOWNVOTE"
  int postId;

  Vote({
    required this.voteType,
    required this.postId,
  });

  Map<String, dynamic> toJson() {
    return {
      'voteType': voteType,
      'postId': postId,
    };
  }
}
