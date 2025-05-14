enum VoteType {
  LIKE,
  DISLIKE,
}

class VoteQueueItem {
  final String restaurantId;
  final VoteType? voteType;

  VoteQueueItem(this.restaurantId, this.voteType);

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'voteType': voteType?.name,
    };
  }
} 