# Simli Client for Flutter

**Simli Client** is a Flutter package designed for seamless integration with the Simli API, offering real-time, low-latency streaming avatars. It leverages advanced **WebRTC** technology to manage video rendering, peer connections, and data channels, making it an ideal solution for applications like virtual assistants, customer service bots, and more.

---

## 🚀 Features

Simli Client provides a range of powerful features to simplify integration and improve performance:

- **Customizable Configurations:** Fine-tune session settings, timeouts, retry logic, and more using `SimliClientConfig`.
- **Real-Time Audio and Video:** Supports synchronized audio streaming and live avatar rendering.
- **Robust Connection Management:** Handles WebSocket timeouts, ICE gathering, and connection retries.
- **Advanced Audio Handling:** Includes silence detection and customizable thresholds for action triggers.
- **Effortless Integration:** Provides a simple API for session initialization and data streaming.

---

## 🔄 Compatibility  

The `SimliClient` Flutter package is fully compatible with **Simli Client version 1.2.1** from [npmjs.com](https://www.npmjs.com/package/simli-client). Ensure you are using version 1.2.1 or later for seamless integration and functionality.  

---  
## 📦 Parameters

### `SimliClient` Parameters

| **Parameter**  | **Type**            | **Description**                                  |
| -------------- | ------------------- | ------------------------------------------------ |
| `clientConfig` | `SimliClientConfig` | Configuration object for the client session.     |
| `log`          | `Logger`            | Logger instance for debugging and event logging. |

### `SimliClientConfig` Parameters

| **Parameter**           | **Type**   | **Description**                                                   |
| ----------------------- | ---------- | ----------------------------------------------------------------- |
| `apiKey`                | `String`   | The API key used for authenticating API requests.                 |
| `faceId`                | `String`   | Identifies the face avatar to use for the session.                |
| `handleSilence`         | `bool`     | Enables or disables silence detection.                            |
| `maxSessionLength`      | `int`      | The maximum allowable session length (in seconds).                |
| `maxIdleTime`           | `int`      | The maximum idle time allowed before termination (in seconds).    |
| `syncAudio`             | `bool`     | Enables audio synchronization.                                    |
| `retryDelay`            | `Duration` | Specifies the delay before retrying failed operations.            |
| `connectionTimeoutTime` | `Duration` | The maximum time allowed for establishing a connection.           |
| `requestTimeout`        | `Duration` | The maximum time allowed for a request to complete.               |
| `audioCheckInterval`    | `Duration` | The interval at which the audio status is checked.                |
| `silenceThreshold`      | `Duration` | The duration of silence considered significant for action.        |
| `iceGatheringTimeout`   | `Duration` | The maximum time allowed for ICE gathering.                       |
| `maxRetryAttempts`      | `int`      | The maximum number of retry attempts for API requests.            |
| `webSocketTimeout`      | `Duration` | The maximum time allowed for WebSocket operations before timeout. |
| `answerTimeoutTime`     | `Duration` | The maximum time to wait for an answer before timing out.         |
| `videoReferenceUrl`     | `String`   | The video reference URL used during the session.                  |
| `isJPG`                 | `bool`     | Indicates whether the file format for assets is JPG.              |



### `SimliClient` Members  

The `SimliClient` class includes various properties and callbacks to manage the client's state, connection events, and audio-visual rendering effectively. Below is a list of available members:  

| **Member**                | **Type**                     | **Description**                                                                                   |
| -------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------- |
| `videoRenderer`           | `RTCVideoRenderer?`          | The video renderer used for displaying video streams.                                            |
| `stateNotifier`           | `ValueNotifier<SimliState>`  | Notifies listeners of changes to the client's state.                                             |
| `isSpeakingNotifier`      | `ValueNotifier<bool>`        | Notifies listeners of changes in whether the user is speaking.                                   |
| `onConnection`            | `VoidCallback?`              | A callback for handling connection events.                                                       |
| `onFailed`                | `void Function(SimliError)`  | A callback for handling connection failed events.                                                |
| `onDisconnected`          | `VoidCallback?`              | A callback for handling disconnection events.                                                    |
| `isSpeaking`              | `bool`                      | Gets whether the user is currently speaking.                                                     |
| `isSpeaking` *(setter)*   | `bool`                      | Sets whether the user is currently speaking.                                                     |
| `state`                   | `SimliState`                | Gets the current state of the client.                                                            |
| `isConnected`             | `bool`                      | Utility method to check connection status.                                                       |
| `audioLevelNotifier`      | `ValueNotifier<double>`      | Notifies listeners with the audio level of the avatar.                                           |  

---

## 🛠️ Getting Started

### Installation

1. Add the dependency to your `pubspec.yaml`:

   ```yaml
   dependencies:
     simli_client: <latest-version>
   ```

   Get the latest version from the [**Installing** tab on pub.dev](https://pub.dev/packages/simli_client/install).

2. Fetch the package using:

   ```bash
   flutter pub get
   ```

3. Import the library into your project:

   ```dart
   import 'package:simli_client/simli_client.dart';
   ```

---

## 🖥️ Implementation Guide

1. **Configure the client:**

   Create an instance of `SimliClientConfig` with the required parameters:

   ```dart
   final config = SimliClientConfig(
     apiKey: '<YOUR_API_KEY>',
     faceId: '<YOUR_FACE_ID>',
     handleSilence: true,
     maxSessionLength: 3600,
     maxIdleTime: 300,
     syncAudio: true,
   );
   ```

2. **Initialize the Simli Client:**

   Pass the configuration and a logger to the `SimliClient` constructor:

   ```dart
   final SimliClient simliClient = SimliClient(
     clientConfig: config,
     log: Logger(),
   );
   ```

3. **Start the client connection:**

   Use the `start` method to establish the connection:

   ```dart
   simliClient.start();
   ```

4. **Render the live avatar:**

   Use `RTCVideoView` to render the live avatar:

   ```dart
   RTCVideoView(
     simliClient.videoRenderer!,
     mirror: false,
     placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
   );
   ```

5. **Send audio data:**

   Stream custom PCM16 audio in `Uint8List` format to trigger the avatar's response:

   ```dart
   simliClient.sendAudioData(data);
   ```

---

## 🔧 Advanced Configuration

The `SimliClientConfig` provides flexible options for fine-tuning your session:

- **Timeouts and Delays:** Customize connection, request, retry, and WebSocket timeouts.
- **Silence Handling:** Configure silence thresholds to define actionable durations.
- **Video Reference:** Specify a video reference URL for preloading or fallback scenarios.
- **Retry Logic:** Define retry intervals and the maximum number of attempts.

---

## 🎨 Preview

Check out the Simli Client in action:

<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/jemisgoti/simli-flutter-client/master/preview/1.png" height="399" width="756" alt="Avatar Preview"/><br>
      <b>Avatar Example</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/jemisgoti/simli-flutter-client/master/preview/2.png" height="500" alt="Conversation Preview"/><br>
      <b>Interactive Conversation</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/jemisgoti/simli-flutter-client/master/preview/1.gif" height="500" alt="Demo Preview"/><br>
      <b>Live Demo</b>
    </td>
  </tr>
</table>

---

## 🤝 Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/jemisgoti">
        <img src="https://avatars.githubusercontent.com/u/46031164" width="100px;" height="100px;" alt="Jemis Goti"/>
        <br>
        <b>Jemis Goti</b>
      </a>
    </td>
  </tr>
</table>

---

## 🏆 Acknowledgements

Thank you for choosing Simli Client! Your support empowers the open-source community to keep innovating. If you find this package helpful, consider starring the repository or contributing to its development.
