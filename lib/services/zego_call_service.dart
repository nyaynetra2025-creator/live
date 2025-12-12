import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// ZegoCloud Call Service for voice calling between clients and lawyers
class ZegoCallService {
  // ZegoCloud credentials
  static const int appID = 983054444;
  static const String appSign = '20e74dfdd83be18c050fb9475cc6e8b0a78a0f7b9bbda31f5a1763905516f1a4';

  /// Navigate to voice call page
  static void startVoiceCall({
    required BuildContext context,
    required String callerUserId,
    required String callerUserName,
    required String calleeUserId,
    required String calleeUserName,
  }) {
    // Create a unique call ID based on both user IDs (sorted for consistency)
    final ids = [callerUserId, calleeUserId];
    ids.sort();
    final callID = 'call_${ids.join('_')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VoiceCallPage(
          callID: callID,
          userID: callerUserId,
          userName: callerUserName,
          calleeUserName: calleeUserName,
        ),
      ),
    );
  }
}

/// Voice Call Page using ZegoCloud
class _VoiceCallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final String calleeUserName;

  const _VoiceCallPage({
    required this.callID,
    required this.userID,
    required this.userName,
    required this.calleeUserName,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: ZegoCallService.appID,
      appSign: ZegoCallService.appSign,
      userID: userID,
      userName: userName,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..topMenuBar.isVisible = true
        ..topMenuBar.title = 'Calling $calleeUserName'
        ..bottomMenuBar.buttons = [
          ZegoCallMenuBarButtonName.toggleMicrophoneButton,
          ZegoCallMenuBarButtonName.hangUpButton,
          ZegoCallMenuBarButtonName.toggleSpeakerButton,
        ]
        ..audioVideoView.backgroundBuilder = (context, size, user, extraInfo) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        calleeUserName.isNotEmpty ? calleeUserName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    calleeUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        ..onHangUp = () {
          Navigator.of(context).pop();
        },
    );
  }
}
