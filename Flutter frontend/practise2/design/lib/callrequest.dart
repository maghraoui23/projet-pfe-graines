class CallRequest {
  final String callID;
  final String callerID;
  final String receiverID;
  final bool isVideo;

  CallRequest({
    required this.callID,
    required this.callerID,
    required this.receiverID,
    required this.isVideo,
  });
}

// ⚠️ Variable partagée en mémoire pour simuler un backend
List<CallRequest> _pendingCalls = [];
