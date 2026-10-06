import React from "react";
import { createRoot } from "react-dom/client";
import { LiveKitRoom, VideoConference } from "@livekit/components-react";

function LiveKitApp({ token, serverUrl, onClose }) {
  return React.createElement(
    "div",
    {
      style: {
        position: "fixed",
        inset: 0,
        zIndex: 9999,
        backgroundColor: "#000"
      }
    },

    React.createElement(
      LiveKitRoom,
      {
        token: token,
        serverUrl: serverUrl,
        connect: true,
        onDisconnected: onClose,
        "data-lk-theme": "default",
        style: {
          width: "100%",
          height: "100%"
        }
      },

      React.createElement(VideoConference)
    )
  );
}

const element = document.getElementById("livekit-root");

if (element) {
  const root = createRoot(element);

  window.joinLiveKit = ({
    token,
    serverUrl
  }) => {
    root.render(
      React.createElement(LiveKitApp, {
        token,
        serverUrl,
        onClose: () => { root.render(null); }
      })
    );
  };
}
