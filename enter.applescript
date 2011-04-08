tell application "Spotify" to activate
tell application "System Events"
  repeat 5 times
    delay 0.2
    keystroke tab
    key code 36
  end
end tell
