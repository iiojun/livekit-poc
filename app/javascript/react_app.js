import React, {
  useState
} from "react";

import { createRoot } from "react-dom/client";

import {
  LiveKitRoom,
  VideoConference
} from "@livekit/components-react";

function LiveKitApp() {
  const [identity, setIdentity] = useState("User");
  const [roomName, setRoomName] = useState("test-room");

  const [status, setStatus] = useState("Disconnected");
  const [connection, setConnection] = useState(null);


  const joinRoom = async () => {
    try {
      if (
        !identity.trim() ||
        !roomName.trim()
      ) {
        alert("Name and Room are required.");
        return;
      }

      setStatus("Getting token...");


      const csrfToken =
        document.querySelector(
          'meta[name="csrf-token"]'
        ).content;


      const response = await fetch("/token", {
        method: "POST",

        headers: {
          "Content-Type":
            "application/x-www-form-urlencoded",

          "X-CSRF-Token": csrfToken
        },

        body: new URLSearchParams({
          identity: identity.trim(),
          room: roomName.trim()
        })
      });


      if (!response.ok) {
        const text = await response.text();

        throw new Error(
          `Token request failed: ${response.status} ${text}`
        );
      }


      const data = await response.json();


      setStatus(
        `Connecting to "${roomName}"...`
      );


      setConnection({
        token: data.token,
        serverUrl: data.url
      });


    } catch (error) {

      console.error(error);

      setStatus(
        `Error: ${error.message}`
      );
    }
  };


  const leaveRoom = () => {
    setConnection(null);
    setStatus("Disconnected");
  };


  const handleDisconnected = () => {
    setConnection(null);
    setStatus("Disconnected");
  };


  if (connection) {
    return React.createElement(
      LiveKitRoom,
      {
        token: connection.token,
        serverUrl: connection.serverUrl,
        connect: true,
        onDisconnected: handleDisconnected,
        "data-lk-theme": "default",
        style: {
          height: "100vh"
        }
      },

      React.createElement(
        VideoConference
      )
    );
  }


  return React.createElement(
    React.Fragment,
    null,

    React.createElement(
      "h2",
      null,
      "LiveKit React"
    ),


    React.createElement(
      "div",
      null,

      React.createElement(
        "label",
        null,
        "Name: "
      ),

      React.createElement("input", {
        value: identity,

        onChange: (event) =>
          setIdentity(event.target.value)
      })
    ),


    React.createElement(
      "div",
      null,

      React.createElement(
        "label",
        null,
        "Room: "
      ),

      React.createElement("input", {
        value: roomName,

        onChange: (event) =>
          setRoomName(event.target.value)
      })
    ),


    React.createElement(
      "button",
      {
        onClick: joinRoom
      },
      "Join"
    ),

    React.createElement(
      "p",
      null,
      status
    )
  );
}

const element = document.getElementById("react-root");

if (element) {
  createRoot(element).render(
    React.createElement(LiveKitApp)
  );
}
