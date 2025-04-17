// zego_cloud_service.dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCloudService {
  static Future<void> init(int appID, String appSign) async {
    await ZegoUIKit().init(
      appID: appID,
      appSign: appSign,
    );
  }
}
