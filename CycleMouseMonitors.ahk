;@region Setup
;@region Description
/************************************************************************
 * @description Cycle mouse across multiple displays.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/09/03
 * @releasedate 2022/03/14
 * @version 2.0.1.0
 ***********************************************************************/

AppName := "Cycle Mouse Monitors"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "2.0.1.0"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "Cycle mouse across multiple displays."
;@endregion

;_bkpMode := "AppVersionAndMinutes"
;_bkpMinutesThreshold := 1

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
A_MenuMaskKey := "vkFF"
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Backup>
;#Include *i <_SaveSettings>
#Include *i <_Config&Vars>
#Include *i <_HelperFuncs>
;#Include *i <_MessageManager>
;#Include *i <_TrayIconHandler>
#Include *i <_Theme>
#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
#Include *i <_GuiTracker>
;#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
;#Include *i <_HotkeysRecorder>
;#Include *i <_ODColors>
;#Include *i <_OSDCustom>
#Include *i <_AutoUpdater>
#Include *i <_SplashScreen>
;#Include *i <_SplashOSD>
#Include *i <_About>
;#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
;@endregion


;@region Startup
if !A_Args.Length {
	if IsSet(SplashScreen) {
	    SplashScreen()
	} else if isSet(SplashScreenOSD) {
		SplashScreenOSD()
	}
}

IsSet(StartMenu) ? StartMenu() : 0
IsSet(Menu_Custom) ? Menu_Custom() : 0
IsSet(StartAutoUpdater) ? StartAutoUpdater() : 0
;@endregion
;@endregion

;@region Main
; Track boundaries
global leftBoundary := 0
global rightBoundary := 0
global destRightX := 0
global destLeftX := 0
global jumpIncrease := 2
global hHook := 0

InitMonitors()


; Ensure hook is uninstalled gracefully on script exit/reload
OnExit(Cleanup)

Cleanup(ExitReason, ExitCode) {
    global hHook
    if (hHook)
    {
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
        hHook := 0
    }
}

InitMonitors() {
    global leftBoundary, rightBoundary, destRightX, destLeftX
    
    monCount := MonitorGetCount()
;    if (monCount < 1)
;        return

    minL := 999999
    maxR := -999999
    
    Loop monCount
    {
        MonitorGet(A_Index, &mL, &mT, &mR, &mB)
        if (mL < minL) {
            minL := mL
        }
        if (mR > maxR) {
            maxR := mR
        }
    }
    
    leftBoundary := minL
    rightBoundary := maxR - 1
    
    destRightX := rightBoundary - jumpIncrease
    destLeftX := leftBoundary + jumpIncrease

	; Register Low-Level Mouse Hook (WH_MOUSE_LL = 14)
	hHook := DllCall("SetWindowsHookEx", "Int", 14, "Ptr", CallbackCreate(LowLevelMouseProc), "Ptr", DllCall("GetModuleHandle", "Ptr", 0, "Ptr"), "UInt", 0, "Ptr")
}

LowLevelMouseProc(nCode, wParam, lParam) {
    if (nCode >= 0 && wParam == 0x0200) ; WM_MOUSEMOVE
    {
        static isTeleporting := false
        if isTeleporting
            return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")

        x := NumGet(lParam, 0, "Int")
        y := NumGet(lParam, 4, "Int")

        if (x <= leftBoundary)
        {
            isTeleporting := true
            DllCall("SetCursorPos", "Int", destRightX, "Int", y)
            SetTimer(() => (isTeleporting := false), -100)
            return 1
        }
        else if (x >= rightBoundary)
        {
            isTeleporting := true
            DllCall("SetCursorPos", "Int", destLeftX, "Int", y)
            SetTimer(() => (isTeleporting := false), -100)
            return 1
        }
    }
    
    return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

;@region Hotkeys
;@endregion



;@endregion
IsSet(CheckReloadArgs) ? CheckReloadArgs() : 0

;throw Error('Message', A_ThisFunc, )
;a := "test"
;OutputDebug(a) ; debug tab

