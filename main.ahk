#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

global isRunning
isRunning := False

/*
############
The Main GUI
############
*/
; Always on top, No icon in taskbar, No minimize / maximize / close buttons
Gui, +AlwaysOnTop +Owner -SysMenu

; "Start" and "?" buttons
Gui, Add, Button, x10 y10 w80 gToggle vMain Default, Start
Gui, Add, Button, x90 y10 w20 gLoopInfo, ?

; "Hide" and "Exit" buttons
Gui, Add, Button, x10 y40 w50 gHide, Hide
Gui, Add, Button, x60 y40 w50 gExit, Exit

; Copyright info
Gui, Add, Text, x10 y70 cGray, © 2023 Qizhen Yang.

; Show the GUI
Gui, Show, x100 y100, ClassIn Freedom, Topmost

/*
#############
The tray menu
#############
*/
Menu, Tray, NoStandard
Menu, Tray, Add, Show Main GUI, ShowGui
Menu, Tray, Add, Exit, Exit

return

ShowGui:
	Gui, Show,, ClassIn Window Patcher, Topmost
return

Hide:
	TrayTip, ClassIn Freedom, The ClassIn Freedom program is minimized to system tray and can be shown by clicking the tray icon.,, 1
	Gui, Hide

; Toggle the state of the main detection loop (execute when start / stop clicked)
Toggle:
	if (isRunning)
	{
		isRunning := False
		GuiControl,, Main, Start
	}
	else
	{
		isRunning := True
		GuiControl,, Main, Stop
		SetTimer, Detection, 0	; Start detection label without interfering the current subrouting
	}
return

; Main detection loop
Detection:
	while (isRunning)
	{
		WinWait, ahk_exe ClassIn.exe

		WinGet, id, List, ahk_exe ClassIn.exe

		Loop, %id%
		{
			WinGet, exStyle, ExStyle, ahk_id %id%
			if (exStyle & 0x00000020)						; "topmost"
			{												;
				WinSet, ExStyle, -0x00000020, ahk_id %id%	; Remove "topmost"
				WinSet, Style, +0x00000001, ahk_id %id%		; Add "normal"
			}
		}
	}
return

Exit:
Gui, Destroy
ExitApp

; Execute when "?" button clicked
LoopInfo:
	ToolTip, The detection start / stop button starts or stops the detection loop, which applies the changes to the ClassIn window whenever ClassIn is opened or re-opened
	SetTimer, RemToolTip, -5000
return
RemToolTip:
	ToolTip
return
