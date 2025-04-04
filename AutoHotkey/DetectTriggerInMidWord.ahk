#Requires AutoHotkey v2.0
#SingleInstance Force

; Hook keyboard input
#HotIf true
~x::
{
    static lastX := 0
    static lastKey := ""
    thisX := A_TickCount
    
    ; Check if this x was typed within 3000ms AND the last key was also 'x'
    if (thisX - lastX < 3000 && A_PriorKey = "x") {
        ; Two x's detected, give PhraseExpander a moment
        Sleep(1000)
        
        ; Function to check for autosuggest window
        CheckAutosuggest() {
            try {
                windows := WinGetList()
                for hwnd in windows {
                    try {
                        if (WinGetProcessName("ahk_id " hwnd) = "PhraseExpander.exe" 
                            && InStr(WinGetTitle("ahk_id " hwnd), "Autosuggest")) {
                            return true
                        }
                    }
                }
            }
            return false
        }
        
        ; First check for autosuggest
        if (!CheckAutosuggest()) {
            ; Remove the previously typed xx
            Send("{Backspace 2}")
            ; Type xx with a space and check again
            Send(" xx")
            Sleep(100)  ; Wait for autosuggest
            
            ; Second check for autosuggest
            if (!CheckAutosuggest()) {
                ; Store current window title since we'll need to restore focus
                focusedTitle := WinGetTitle("A")
                
                ; Try to ensure focus by sending Alt+Tab twice
                Send("!{Tab}")
                Sleep(50)
                Send("!{Tab}")
                Sleep(100)
                
                ; Try to activate the window by title if we have it
                if (focusedTitle)
                    WinActivate(focusedTitle)
                
                Sleep(100)  ; Give window activation a moment
                ; Remove the previously typed xx
            Send("{Backspace 2}")
                ; Type xx to trigger PhraseExpander
                Send("xx")
            }
        }
        lastX := 0  ; Reset the timer
    } else {
        lastX := thisX  ; Store the time of this x press
        lastKey := A_PriorKey  ; Store the last key pressed
    }
}
