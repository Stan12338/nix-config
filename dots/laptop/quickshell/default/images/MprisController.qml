pragma Singleton
pragma ComponentBehavior: Bound

// From https://git.outfoxxed.me/outfoxxed/nixnew
// It does not have a license, but the author is okay with redistribution.

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

/**
 * A service that provides easy access to the active Mpris player.
 */
Singleton {
	id: root;

	// Helper function to filter real players
	function isRealPlayer(player) {
		// Filter out invalid or non-real players if needed
		// For now, accept all players
		return player != null;
	}

	property list<MprisPlayer> players: Mpris.players.values.filter(player => isRealPlayer(player));
	property MprisPlayer trackedPlayer: null;
	property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null;
	signal trackChanged(reverse: bool);

	property bool __reverse: false;

	property var activeTrack;

	property bool hasPlasmaIntegration: false
    Process {
        id: plasmaIntegrationAvailabilityCheckProc
        running: true
        command: ["bash", "-c", "command -v plasma-browser-integration-host"]
        onExited: (exitCode, exitStatus) => {
            root.hasPlasmaIntegration = (exitCode === 0);
        }
    }

	Instantiator {
		model: Mpris.players;

		Connections {
			required property MprisPlayer modelData;
			target: modelData;

			Component.onCompleted: {
				if (root.trackedPlayer == null || modelData.isPlaying) {
					root.trackedPlayer = modelData;
				}
			}

			Component.onDestruction: {
				if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
					for (const player of Mpris.players.values) {
						if (player.playbackState.isPlaying) {
							root.trackedPlayer = player;
							break;
						}
					}

					if (trackedPlayer == null && Mpris.players.values.length != 0) {
						trackedPlayer = Mpris.players.values[0];
					}
				}
			}

			function onPlaybackStateChanged() {
				if (root.trackedPlayer !== modelData) root.trackedPlayer = modelData;
			}
		}
	}

	Connections {
		target: activePlayer

		function onPostTrackChanged() {
			root.updateTrack();
		}

		function onTrackArtUrlChanged() {
			if (root.activePlayer && root.activeTrack &&
			    root.activePlayer.uniqueId == root.activeTrack.uniqueId &&
			    root.activePlayer.trackArtUrl != root.activeTrack.artUrl) {
				const r = root.__reverse;
				root.updateTrack();
				root.__reverse = r;
			}
		}
	}

	onActivePlayerChanged: {
		this.updateTrack();
	}

	Component.onCompleted: {
		// Initialize track on startup
		this.updateTrack();
	}

	function updateTrack() {
		this.activeTrack = {
			uniqueId: this.activePlayer?.uniqueId ?? 0,
			artUrl: this.activePlayer?.trackArtUrl ?? "",
			title: this.activePlayer?.trackTitle || "Unknown Title",
			artist: this.activePlayer?.trackArtist || "Unknown Artist",
			album: this.activePlayer?.trackAlbum || "Unknown Album",
		};

		this.trackChanged(__reverse);
		this.__reverse = false;
	}

	property bool isPlaying: this.activePlayer && this.activePlayer.isPlaying;
	property bool canTogglePlaying: this.activePlayer?.canTogglePlaying ?? false;
	function togglePlaying() {
		if (this.canTogglePlaying) this.activePlayer.togglePlaying();
	}

	property bool canGoPrevious: this.activePlayer?.canGoPrevious ?? false;
	function previous() {
		if (this.canGoPrevious) {
			this.__reverse = true;
			this.activePlayer.previous();
		}
	}

	property bool canGoNext: this.activePlayer?.canGoNext ?? false;
	function next() {
		if (this.canGoNext) {
			this.__reverse = false;
			this.activePlayer.next();
		}
	}

	property bool canChangeVolume: this.activePlayer && this.activePlayer.volumeSupported && this.activePlayer.canControl;

	property bool loopSupported: this.activePlayer && this.activePlayer.loopSupported && this.activePlayer.canControl;
	property var loopState: this.activePlayer?.loopState ?? MprisLoopState.None;
	function setLoopState(loopState: var) {
		if (this.loopSupported) {
			this.activePlayer.loopState = loopState;
		}
	}

	property bool shuffleSupported: this.activePlayer && this.activePlayer.shuffleSupported && this.activePlayer.canControl;
	property bool hasShuffle: this.activePlayer?.shuffle ?? false;
	function setShuffle(shuffle: bool) {
		if (this.shuffleSupported) {
			this.activePlayer.shuffle = shuffle;
		}
	}

	property real position: 0
	property real length: this.activePlayer?.length ?? 0
	property bool canSeek: this.activePlayer?.canSeek ?? false

	Timer {
		id: positionUpdateTimer
		interval: 500
		running: root.isPlaying && root.activePlayer
		repeat: true
		onTriggered: {
			if (root.activePlayer) {
				const newPos = root.activePlayer.position;
				root.position = newPos;
			}
		}
	}

	Connections {
		target: activePlayer

		function onPositionChanged() {
			if (root.activePlayer) {
				const newPos = root.activePlayer.position;
				root.position = newPos;
			}
		}

		function onLengthChanged() {
			if (root.activePlayer) {
				const newPos = root.activePlayer.position;
				const newLen = root.activePlayer.length;
				root.position = newPos;
			}
		}
	}


	function formatTime(seconds: real): string {
		const totalSeconds = Math.floor(seconds);
		const hours = Math.floor(totalSeconds / 3600);
		const minutes = Math.floor((totalSeconds % 3600) / 60);
		const secs = totalSeconds % 60;

		const pad = (num) => num.toString().padStart(2, '0');

		if (hours > 0) {
			return `${hours}:${pad(minutes)}:${pad(secs)}`;
		} else {
			return `${minutes}:${pad(secs)}`;
		}
	}

	property string positionString: formatTime(position)

	property string lengthString: formatTime(length)

	property real progress: length > 0 ? Math.min(1.0, Math.max(0.0, position / length)) : 0.0

	function seek(positionSeconds: real) {
		if (this.canSeek && this.activePlayer) {
			this.activePlayer.position = positionSeconds;
		}
	}

	function seekBy(offsetSeconds: real) {
		if (this.canSeek && this.activePlayer) {
			const newPosition = Math.max(0, Math.min(this.length, this.position + offsetSeconds));
			this.activePlayer.position = newPosition;
		}
	}

	function seekForward5() {
		this.seekBy(5);
	}

	function seekBackward5() {
		this.seekBy(-5);
	}

	function seekForward10() {
		this.seekBy(10);
	}

	function seekBackward10() {
		this.seekBy(-10);
	}

	function seekToPercent(percent: real) {
		if (this.canSeek && this.length > 0) {
			const targetPosition = this.length * Math.max(0.0, Math.min(1.0, percent));
			this.seek(targetPosition);
		}
	}

	function setActivePlayer(player: MprisPlayer) {
		const targetPlayer = player ?? Mpris.players[0];

		if (targetPlayer && this.activePlayer) {
			this.__reverse = Mpris.players.indexOf(targetPlayer) < Mpris.players.indexOf(this.activePlayer);
		} else {
			this.__reverse = false;
		}

		this.trackedPlayer = targetPlayer;
	}

	IpcHandler {
		target: "mpris"

		function pauseAll(): void {
			for (const player of Mpris.players.values) {
				if (player.canPause) player.pause();
			}
		}

		function playPause(): void { root.togglePlaying(); }
		function previous(): void { root.previous(); }
		function next(): void { root.next(); }
		function seekForward(): void { root.seekForward5(); }
		function seekBackward(): void { root.seekBackward5(); }
	}
}
