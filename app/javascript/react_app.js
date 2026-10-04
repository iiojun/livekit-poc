import React, { useState, useRef } from "react";
import { createRoot } from "react-dom/client";
import {
  Room,
  RoomEvent
} from "https://cdn.jsdelivr.net/npm/livekit-client@2.15.3/+esm";

function LiveKitApp() {
  const [identity, setIdentity] = useState("User");
  const [roomName, setRoomName] = useState("test-room");
  const [status, setStatus] = useState("Disconnected");
  const [connected, setConnected] = useState(false);

  const roomRef = useRef(null);

  const joinRoom = async () => {
    try {
      if (!identity.trim() || !roomName.trim()) {
        alert("Name and Room are required.");
        return;
      }

      setStatus("Getting token...");

      const csrfToken =
        document.querySelector('meta[name="csrf-token"]').content;

      const response = await fetch("/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": csrfToken
        },
        body: new URLSearchParams({
          identity: identity.trim(),
          room: roomName.trim()
        })
      });

      if (!response.ok) {
        const text = await response.text();
        throw new Error(`Token request failed: ${response.status} ${text}`);
      }

      const data = await response.json();

      setStatus("Connecting to LiveKit...");

      const room = new Room();

      room.on(RoomEvent.ParticipantConnected, (participant) => {
        console.log("Participant connected:", participant.identity);
      });

      room.on(RoomEvent.ParticipantDisconnected, (participant) => {
        console.log("Participant disconnected:", participant.identity);
      });

      room.on(RoomEvent.Disconnected, () => {
        setStatus("Disconnected");
        setConnected(false);
        roomRef.current = null;
      });

      await room.connect(data.url, data.token);

      await room.localParticipant.enableCameraAndMicrophone();

      roomRef.current = room;

      setStatus(`Connected to "${roomName}"`);
      setConnected(true);

    } catch (error) {
      console.error(error);
      setStatus(`Error: ${error.message}`);
    }
  };

  const leaveRoom = async () => {
    if (roomRef.current) {
      await roomRef.current.disconnect();
      roomRef.current = null;
    }

    setStatus("Disconnected");
    setConnected(false);
  };

  return React.createElement(
    React.Fragment,
    null,

    React.createElement("h2", null, "LiveKit React"),

    React.createElement(
      "div",
      null,
      React.createElement("label", null, "Name: "),
      React.createElement("input", {
        value: identity,
        onChange: (event) => setIdentity(event.target.value),
        disabled: connected
      })
    ),

    React.createElement(
      "div",
      null,
      React.createElement("label", null, "Room: "),
      React.createElement("input", {
        value: roomName,
        onChange: (event) => setRoomName(event.target.value),
        disabled: connected
      })
    ),

    React.createElement(
      "button",
      {
        onClick: joinRoom,
        disabled: connected
      },
      "Join"
    ),

    React.createElement(
      "button",
      {
        onClick: leaveRoom,
        disabled: !connected
      },
      "Leave"
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
