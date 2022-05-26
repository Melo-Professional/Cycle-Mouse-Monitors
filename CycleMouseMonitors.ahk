{
#Persistent
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance Force
;#MaxThreadsPerHotkey 5
Coordmode, Mouse, Screen

;OPTIMIZATIONS START
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
;OPTIMIZATIONS END

Appname := "CycleMouseMonitors"
Version := 1.0
global Appname
global Version
Menu, Tray, Icon, %A_ScriptDir%\CycleMouseMonitors.ico




Menu, Tray, Tip , Cycle Mouse Monitors
Menu, Tray, NoStandard
Menu, Tray, deleteall
Menu, Tray, Add, Opener, opener	
Menu, Tray, Default, 1&
;Menu, Tray, Click, 1
Menu, Tray, Rename, 1&
Menu, Tray, Add, Start on Boot, BootMenu
If (CheckStartOnBoot()){
	Menu, Tray, Check, Start on Boot
}else{
	Menu, Tray, Uncheck, Start on Boot
}
Menu, Tray, Add, Restart , Restart
Menu, Tray, Add, About, About
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1


left := 0

    SM_CMONITORS := 80
    SysGet, monCount, % SM_CMONITORS

    Loop, % monCount
	{
        SysGet, mon%A_Index%, Monitor, %A_Index%
		if ( mon%A_Index%Left <= left )
			left := mon%A_Index%Left
		if ( mon%A_Index%Right >= right )
			right := mon%A_Index%Right
	}
;	MsgBox, % right  left
    CoordMode, Mouse, Screen
    PixOffset := 2        ; how many pixels we consider an edge of the screen
    SetTimer, WatchMouse, 200

}
return






opener:
Menu, Tray, Show
return

CheckStartOnBoot()
{
RegRead, StartupReg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %Appname%
return StartupReg
}


BootMenu:
If (CheckStartOnBoot()){
	RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %Appname%
	Menu, Tray, Uncheck, Start on Boot
}else{
	RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %Appname%, %A_AhkPath%
	Menu, Tray, Check, Start on Boot
}
Return

Restart:
Reload
Return

About:
MsgBox ,,%Appname%,Cycle Mouse Monitors`nversion %Version%`n`nCycle mouse across multiple displays.`n`n`n`nBy Melo`nmelo@meloprofessional.com`n© Melo. All rights reserved.
return

Exit:
ExitApp
Return



WatchMouse:
{
    MouseGetPos, x, y ; relative to primary monitor


if (left <= x && x <= (left + PixOffset) )
	MouseMove, right-(1+PixOffset), y, ,

if ( (right - PixOffset) <= x && x <= right)
	MouseMove, left+(1+PixOffset), y, ,
}
