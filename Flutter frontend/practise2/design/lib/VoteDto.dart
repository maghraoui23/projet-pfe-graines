class VoteDto {
  String voteType; // "UPVOTE" or "DOWNVOTE"
  int postId;

  VoteDto({
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
