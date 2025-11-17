Persistent
#SingleInstance Ignore
#UseHook
SendMode("Input")
SetWorkingDir(A_ScriptDir)
SetTitleMatchMode(2)

s_procExeNames := ["GTA5.exe", "GTA5_Enhanced.exe"]
s_progressSaveIP := "192.81.241.171"
s_soloPublicSessionBlockPorts := "6670,6672,61455-61458"
s_suspendExe := "PsSuspend.exe"
s_toolTipTitle := "GTA 5 Online - Tools"
s_tooltipTopMargin := 600
s_tooltipLeftMargin := 10
s_tooltipPrefix := ""

ToolTipHideLevel := {
	MINIMAL: 1,
	MINIMIZED: 2,
	FULL: 3,
}

ToolFeatures := {
	AUTO_HIDE: "F4",
	ANTI_AFK: "F5",
	AUTO_CLICK: "F6",
	SOLO_PUBLIC_SESSION_PORT: "F7",
	SOLO_PUBLIC_SESSION_SUSPEND: "F8",
	NO_SAVE_MODE: "F9",
	;DISABLE_NO_SAVE_MODE: "F10",
	EXE_BLOCK_MODE: "F11",
	;DISABLE_EXE_BLOCK_MODE: "F12",
}

MultiFeatureCombinationMap := Map()

AllFeaturesAllowed := Map()
AllFeaturesAllowed[ToolFeatures.AUTO_HIDE] := true
AllFeaturesAllowed[ToolFeatures.ANTI_AFK] := true
AllFeaturesAllowed[ToolFeatures.AUTO_CLICK] := true
AllFeaturesAllowed[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := true
AllFeaturesAllowed[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := true
AllFeaturesAllowed[ToolFeatures.NO_SAVE_MODE] := true
AllFeaturesAllowed[ToolFeatures.EXE_BLOCK_MODE] := true

NoFeaturesAllowed := Map()
NoFeaturesAllowed[ToolFeatures.AUTO_HIDE] := false
NoFeaturesAllowed[ToolFeatures.ANTI_AFK] := false
NoFeaturesAllowed[ToolFeatures.AUTO_CLICK] := false
NoFeaturesAllowed[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := false
NoFeaturesAllowed[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := false
NoFeaturesAllowed[ToolFeatures.NO_SAVE_MODE] := false
NoFeaturesAllowed[ToolFeatures.EXE_BLOCK_MODE] := false

MultiFeatureCombinationMap[ToolFeatures.AUTO_HIDE] := AllFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.ANTI_AFK] := AllFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.AUTO_CLICK] := AllFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := NoFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := NoFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.NO_SAVE_MODE] := AllFeaturesAllowed
MultiFeatureCombinationMap[ToolFeatures.EXE_BLOCK_MODE] := AllFeaturesAllowed

s_activeFeatureMap := Map()
s_activeFeatureMap[ToolFeatures.AUTO_HIDE] := false
s_activeFeatureMap[ToolFeatures.ANTI_AFK] := false
s_activeFeatureMap[ToolFeatures.AUTO_CLICK] := false
s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := false
s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := false
s_activeFeatureMap[ToolFeatures.NO_SAVE_MODE] := false
s_activeFeatureMap[ToolFeatures.EXE_BLOCK_MODE] := false

s_ttAutoHideTime := 3
s_noSaveRule := "GTAO-NoSave"
s_exeBlockRule := "GTAO-Block"
s_autoClickTime := 10
s_soloPublicSuspendTime := 10
s_soloPublicSessionPortBlockRule := "GTAO-SoloPublicPortBlock"

s_procExeName := ""
s_procExePath := ""
s_isExeFound := false
s_hideToolTipActive := false
s_hideToolTipLevel := ToolTipHideLevel.MINIMAL
s_tempShowToolTip := false
s_noSaveRuleActive := false
s_exeBlockRuleActive := false
s_soloPublicSesPortBlockActive := false
s_soloPublicSesPortBlockTimer := 0
s_soloPublicSesProcSuspendActive := false
s_soloPublicSesProcSuspendTimer := 0
s_autoClickActive := false
s_autoClickStartTick := 0
s_autoClickTimer := 0
s_afkActive := false

if !A_IsAdmin {
	{
		ErrorLevel := "ERROR"
		try ErrorLevel := Run("*RunAs `"" A_ScriptFullPath "`"", , "",)
	}
	if (ErrorLevel != 0) {
		MsgBox("This script requires administrator privileges! Please run it again with the correct privileges.",
			s_toolTipTitle . " | Error!", "Iconx")
	}
	ExitApp()
}

OnExit(AppExit)

;##############################################
; Initialize

ToolTipOptions.Init()
ToolTipOptions.SetFont("s10", "Consolas")
ToolTipOptions.SetMargins(1, 1, 1, 1)
ToolTipOptions.SetColors("Red", "White")

GetExeVars()
exeVarsTimerFunc := GetExeVars.Bind(true)
SetTimer(exeVarsTimerFunc, 5000)

;##############################################

<^F4:: HK_F4()

<^F5:: HK_F5()

<^F6:: HK_F6()

<^F7:: HK_F7()

<^F8:: HK_F8()

<^F9:: HK_F9()

<^F10:: HK_F10()

<^F11:: HK_F11()

<^F12:: HK_F12()

;##############################################
; NEW: Hide ToolTip Toggle
HK_F4() {
	global s_activeFeature, s_hideToolTipActive, s_hideToolTipLevel, s_tempShowToolTip

	if (!CanInvokeThisFeature(ToolFeatures.AUTO_HIDE)) {
		return
	}

	if (s_hideToolTipActive && s_hideToolTipLevel = ToolTipHideLevel.MINIMAL) {
		s_hideToolTipLevel := ToolTipHideLevel.MINIMIZED
	} else {
		s_hideToolTipLevel := ToolTipHideLevel.MINIMAL
		s_hideToolTipActive := !s_hideToolTipActive
	}

	if (s_hideToolTipActive) {
		; If we just enabled hide mode, clear any temporary shows and hide immediately
		s_tempShowToolTip := false
		SetTimer(DisableTempShow, 0)
	}

	s_activeFeatureMap[ToolFeatures.AUTO_HIDE] = s_hideToolTipActive

	UpdateToolTip()
}

; Helper to show tooltip for 5 seconds then hide
TriggerTempShow() {
	global s_hideToolTipActive, s_tempShowToolTip
	if (s_hideToolTipActive) {
		s_tempShowToolTip := true
		UpdateToolTip()
		SetTimer(DisableTempShow, (0 - (s_ttAutoHideTime * 1000))) ; Run once after `s_ttAutoHideTime` seconds
	}
}

DisableTempShow() {
	global s_tempShowToolTip
	s_tempShowToolTip := false
	UpdateToolTip() ; This will trigger the hide logic inside UpdateToolTip
}

;##############################################
HK_F5() {
	global
	;GetExeVars()

	if (!CanInvokeThisFeature(ToolFeatures.ANTI_AFK)) {
		return
	}

	s_afkActive := !s_afkActive
	if (s_afkActive) {
		SetTimer(AntiAFK, 1000)
		UpdateToolTip()
	} else {
		SetTimer(AntiAFK, 0)
		UpdateToolTip()
	}

	s_activeFeatureMap[ToolFeatures.ANTI_AFK] = s_afkActive

	TriggerTempShow() ; Show status change for 5s
	return
}

AntiAFK() {
	if (!WinActive("Grand Theft Auto V")) {
		return
	}

	if (GetKeyState("w", "P") || GetKeyState("a", "P") || GetKeyState("s", "P") || GetKeyState("d", "P")) {
		return
	}

	s_tempShowToolTip := true

	k := Random(1, 4)
	h := Random(50, 100)
	w := Random(1000, 2000)
	key := SubStr("wasd", (k) < 1 ? (k) - 1 : (k), 1)

	Send("{" key " down}")
	Sleep(h)
	Send("{" key " up}")
	Sleep(w)
}

;##############################################
HK_F6() {
	global
	;GetExeVars()

	if (!CanInvokeThisFeature(ToolFeatures.AUTO_CLICK)) {
		return
	}

	s_autoClickActive := !s_autoClickActive
	if (s_autoClickActive) {
		AutoClickTimeoutMs := (0 - (s_autoClickTime * 1000))
		SetTimer(SpamClick, 10)
		SetTimer(AutoClickTimeout, AutoClickTimeoutMs)
		s_autoClickTimer := s_autoClickTime
		s_autoClickStartTick := A_TickCount
		AutoClickTimer()
		SetTimer(AutoClickTimer, 1000)
	} else {
		SetTimer(SpamClick, 0)
		SetTimer(AutoClickTimeout, 0)
		SetTimer(AutoClickTimer, 0)
		UpdateToolTip()
	}

	s_activeFeatureMap[ToolFeatures.AUTO_CLICK] = s_autoClickActive

	TriggerTempShow() ; Show status change for 5s
	return
}

SpamClick() {
	;if !WinActive("Grand Theft Auto V")
	;	return
	Click("down")
	Sleep(5)
	Click("up")
	Sleep(95)
}

AutoClickTimer() {
	global s_autoClickActive, s_autoClickTime, s_autoClickStartTick, s_autoClickTimer

	if (s_autoClickActive) {
		if (A_TickCount - s_autoClickStartTick >= (s_autoClickTime * 1000)) {
			SetTimer(AutoClickTimer, 0)
		} else {
			if (s_autoClickActive) {
				;ToolTip, TIMER: %s_autoClickTimer%, 10, 10
				UpdateToolTip()
				s_autoClickTimer--
			}
		}
	} else {
		SetTimer(AutoClickTimer, 0)
	}
}

AutoClickTimeout() {
	global s_autoClickActive

	if (s_autoClickActive) {
		s_autoClickActive := false
		SetTimer(SpamClick, 0)
		UpdateToolTip()
	}
}

;##############################################
HK_F7() {
	global
	;GetExeVars()

	if (!CanInvokeThisFeature(ToolFeatures.SOLO_PUBLIC_SESSION_PORT)) {
		return
	}

	doSuspend := MsgBox("Confirm Port Block to initiate a GTA 5 Solo Public Session?`n Blocking Ports: " .
		s_soloPublicSessionBlockPorts, s_toolTipTitle . " | Confirm!", "YesNo Icon!")
	if (doSuspend = "Yes") {

		; Force show tooltip during the operation
		if (s_hideToolTipActive) {
			s_tempShowToolTip := true
			SetTimer(DisableTempShow, 0) ; Cancel any existing hide timer
		}

		RunWait('netsh advfirewall firewall add rule name="' s_soloPublicSessionPortBlockRule '" dir=out protocol=udp localport="' s_soloPublicSessionBlockPorts '" action=block enable=yes', ,
			"Hide")
		s_soloPublicSesPortBlockActive := true
		s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := s_soloPublicSesPortBlockActive

		loop s_soloPublicSuspendTime {
			s_soloPublicSesPortBlockTimer := (s_soloPublicSuspendTime - A_Index) + 1
			UpdateToolTip()
			Sleep(1000)
		}

		RunWait('netsh advfirewall firewall delete rule name="' s_soloPublicSessionPortBlockRule '"', , "Hide")
		s_soloPublicSesPortBlockTimer := 0
		s_soloPublicSesPortBlockActive := false
		s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_PORT] := s_soloPublicSesPortBlockActive

		; Operation done, turn off temp show immediately
		if (s_hideToolTipActive) {
			s_tempShowToolTip := false
		}
		UpdateToolTip()
	}
	return
}

;##############################################
HK_F8() {
	global
	GetExeVars(true)

	if (!s_isExeFound) {
		MsgBox("GTA5 not running!", s_toolTipTitle . " | Error!", "Iconx")
		return
	}

	if (!CanInvokeThisFeature(ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND)) {
		return
	}

	doSuspend := MsgBox(
		"Confirm Process Suspend to initiate a GTA 5 Solo Public Session?`n Required Tool: PsSuspend.exe`n Process name: " .
		s_procExeName, s_toolTipTitle . " | Confirm!", "YesNo Icon!")
	if (doSuspend = "Yes") {

		; Force show tooltip during the operation
		if (s_hideToolTipActive) {
			s_tempShowToolTip := true
			SetTimer(DisableTempShow, 0) ; Cancel any existing hide timer
		}

		RunWait(A_ComSpec . ' /c "' . s_suspendExe . ' ' . s_procExeName . '"', , "Hide")
		s_soloPublicSesProcSuspendActive := true
		s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := s_soloPublicSesProcSuspendActive

		loop s_soloPublicSuspendTime {
			s_soloPublicSesProcSuspendTimer := (s_soloPublicSuspendTime - A_Index) + 1
			UpdateToolTip()
			Sleep(1000)
		}

		RunWait(A_ComSpec . ' /c "' . s_suspendExe . ' -r ' . s_procExeName . '"', , "Hide")
		s_soloPublicSesProcSuspendTimer := 0
		s_soloPublicSesProcSuspendActive := false
		s_activeFeatureMap[ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND] := s_soloPublicSesProcSuspendActive

		; Operation done, turn off temp show immediately
		if (s_hideToolTipActive) {
			s_tempShowToolTip := false
		}
		UpdateToolTip()
	}
	return
}

;##############################################
HK_F9() {
	global
	;GetExeVars()

	if (!CanInvokeThisFeature(ToolFeatures.NO_SAVE_MODE)) {
		return
	}

	RunWait('netsh advfirewall firewall add rule name="' s_noSaveRule '" dir=out action=block remoteip="' s_progressSaveIP '"', ,
		"Hide")
	s_noSaveRuleActive := true
	s_activeFeatureMap[ToolFeatures.NO_SAVE_MODE] := s_noSaveRuleActive

	UpdateToolTip()
	TriggerTempShow() ; Show status change for 5s
	return
}

;##############################################
HK_F10() {
	global
	;GetExeVars()
	RunWait('netsh advfirewall firewall delete rule name="' s_noSaveRule '"', , "Hide")
	s_noSaveRuleActive := false
	s_activeFeatureMap[ToolFeatures.NO_SAVE_MODE] := s_noSaveRuleActive

	UpdateToolTip()
	TriggerTempShow() ; Show status change for 5s
	return
}

;##############################################
HK_F11() {
	global
	GetExeVars(true)

	if (!CanInvokeThisFeature(ToolFeatures.EXE_BLOCK_MODE)) {
		return
	}

	if (!s_isExeFound) {
		MsgBox("GTA5 not running!", s_toolTipTitle . " | Error?", "Iconx")
		return
	}
	RunWait('netsh advfirewall firewall add rule name="' s_exeBlockRule '" dir=out program="' s_procExePath '" action=block enable=yes', ,
		"Hide")
	s_exeBlockRuleActive := true
	s_activeFeatureMap[ToolFeatures.EXE_BLOCK_MODE] := s_exeBlockRuleActive

	UpdateToolTip()
	TriggerTempShow() ; Show status change for 5s
	return
}

;##############################################
HK_F12() {
	global
	;GetExeVars()
	RunWait('netsh advfirewall firewall delete rule name="' s_exeBlockRule '"', , "Hide")
	s_exeBlockRuleActive := false
	s_activeFeatureMap[ToolFeatures.EXE_BLOCK_MODE] := s_exeBlockRuleActive

	UpdateToolTip()
	TriggerTempShow() ; Show status change for 5s
	return
}

;##############################################

GetExeVars(forceCheck := false) {
	global s_isExeFound, s_procExeName, s_procExePath

	if (!s_isExeFound || forceCheck) {
		s_isExeFound := false
		s_procExeName := ""
		s_procExePath := ""
		for Index, procExeName in s_procExeNames {
			processID := ProcessExist(procExeName)
			if (processID) {
				s_isExeFound := true
				s_procExeName := procExeName
				s_procExePath := ProcessGetPath(procExeName)
				break
			}
		}
		UpdateToolTip()
	}
}

CanInvokeThisFeature(invokedFeature) {
	global s_activeFeatureMap, MultiFeatureCombinationMap
	for featureKey, isFeatureActive in s_activeFeatureMap {
		if (isFeatureActive) {
			return MultiFeatureCombinationMap[featureKey][invokedFeature]
		}
	}
	return true
}

CanShowThisFeature(showingFeature) {
	global s_activeFeatureMap, MultiFeatureCombinationMap
	for featureKey, isFeatureActive in s_activeFeatureMap {
		if (isFeatureActive) {
			if (featureKey = showingFeature) {
				return true
			} else {
				return MultiFeatureCombinationMap[featureKey][showingFeature]
			}
		}
	}
	return true
}

UpdateToolTip() {
	global s_hideToolTipActive, s_hideToolTipLevel, s_tempShowToolTip, s_isExeFound, s_procExeName, s_toolTipTitle,
		s_tooltipPrefix, s_afkActive, s_autoClickActive, s_autoClickTimer, s_soloPublicSesPortBlockActive,
		s_soloPublicSesPortBlockTimer, s_soloPublicSuspendTimer, s_soloPublicSesProcSuspendActive,
		s_soloPublicSesProcSuspendTimer, s_noSaveRuleActive, s_exeBlockRuleActive

	ToolTip()
	toolTipText := ""
	toolTipIcon := 0

	if (!s_hideToolTipActive || s_tempShowToolTip || s_hideToolTipLevel = 2) {
		if (s_isExeFound) {
			toolTipText .= s_procExeName
			toolTipIcon := 1
		} else {
			toolTipText .= "GTA5 NOT RUNNING!"
			toolTipIcon := 2
		}
	}

	ToolTipOptions.SetTitle(s_toolTipTitle, toolTipIcon)

	; --- BODY (Conditional Visibility) ---

	; Determine if we should show the feature list
	; Show if: Not in Hide Mode OR Temp Show is active
	shouldShowDetails := (!s_hideToolTipActive || s_tempShowToolTip)

	if (shouldShowDetails) {
		toolTipText .= "`n`n=== FEATURES =========================== Active? ="

		featuresTT := []
		showDisableHkColum := false

		if (CanShowThisFeature(ToolFeatures.AUTO_HIDE)) {
			if (s_hideToolTipActive) {
				featuresTT.Push(s_tooltipPrefix . "AUTO-HIDE THIS UI             [Ctrl+F4]  - ✔️")
				;showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "AUTO-HIDE THIS UI             [Ctrl+F4]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.ANTI_AFK)) {
			if (s_afkActive) {
				featuresTT.Push(s_tooltipPrefix . "ANTI-AFK                      [Ctrl+F5]  - ✔️")
				;showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "ANTI-AFK                      [Ctrl+F5]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.AUTO_CLICK)) {
			if (s_autoClickActive) {
				featuresTT.Push(s_tooltipPrefix . "AUTO-CLICK                    [Ctrl+F6]  - ✔️    -  [TIMER: " .
					s_autoClickTimer . "s]")
				showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "AUTO-CLICK                    [Ctrl+F6]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.SOLO_PUBLIC_SESSION_PORT)) {
			if (s_soloPublicSesPortBlockActive) {
				featuresTT.Push(s_tooltipPrefix . "SOLO PUBLIC SESSION - PORT    [Ctrl+F7]  - ✔️    -  [WAIT:  " .
					s_soloPublicSesPortBlockTimer . "s]")
				showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "SOLO PUBLIC SESSION - PORT    [Ctrl+F7]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.SOLO_PUBLIC_SESSION_SUSPEND)) {
			if (s_soloPublicSesProcSuspendActive) {
				featuresTT.Push(s_tooltipPrefix . "SOLO PUBLIC SESSION - SUSPEND [Ctrl+F8]  - ✔️    -  [WAIT:  " .
					s_soloPublicSesProcSuspendTimer . "s]")
				showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "SOLO PUBLIC SESSION - SUSPEND [Ctrl+F8]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.NO_SAVE_MODE)) {
			if (s_noSaveRuleActive) {
				featuresTT.Push(s_tooltipPrefix . "NO SAVE MODE                  [Ctrl+F9]  - ✔️    -  [Ctrl+F10]")
				showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "NO SAVE MODE                  [Ctrl+F9]  - ❌")
			}
		}

		if (CanShowThisFeature(ToolFeatures.EXE_BLOCK_MODE)) {
			if (s_exeBlockRuleActive) {
				featuresTT.Push(s_tooltipPrefix . "EXE BLOCK MODE                [Ctrl+F11] - ✔️    -  [Ctrl+F12]")
				showDisableHkColum := true
			} else {
				featuresTT.Push(s_tooltipPrefix . "EXE BLOCK MODE                [Ctrl+F11] - ❌")
			}
		}

		if (showDisableHkColum) {
			toolTipText .= "= DisableHK ="
		}
		toolTipText .= "`n"

		; Build the ToolTip text
		if (featuresTT.Length > 0) {
			for index, feature in featuresTT {
				toolTipText .= feature . "`n"
			}
		} else {
			toolTipText .= "  -x- NONE -x-"
		}
	} else {
		if (s_hideToolTipLevel = 2) {
			activeFeatureFlags := [s_afkActive, s_autoClickActive, s_soloPublicSesPortBlockActive,
				s_soloPublicSesProcSuspendActive, s_noSaveRuleActive, s_exeBlockRuleActive]
			activeFeatureCount := 0
			for (activeFeatureFlag in activeFeatureFlags) {
				activeFeatureCount += activeFeatureFlag
			}

			; Minimized View
			toolTipText .= "`n---- MINIMIZED ----"
			;if (activeFeatureCount) {
			toolTipText .= "`nActive Feature: " . activeFeatureCount
			;}
			toolTipText .= "`n"
		}
		toolTipText .= "Expand: [CTRL + F4]"
	}

	if (StrLen(toolTipText) > 0) {
		ToolTip(toolTipText, s_tooltipLeftMargin, s_tooltipTopMargin)
	} else {
		ToolTip()
	}
}

AppExit(*) {
	global exeVarsTimerFunc, s_procExeName, s_suspendExe, s_noSaveRule, s_exeBlockRule,
		s_soloPublicSessionPortBlockRule

	SetTimer(SpamClick, 0)
	SetTimer(AntiAFK, 0)
	SetTimer(AutoClickTimeout, 0)
	SetTimer(AutoClickTimer, 0)
	SetTimer(GetExeVars, 0)
	SetTimer(exeVarsTimerFunc, 0)

	RunWait("netsh advfirewall firewall delete rule name=`"" s_noSaveRule "`"", , "Hide")
	RunWait("netsh advfirewall firewall delete rule name=`"" s_exeBlockRule "`"", , "Hide")
	RunWait("netsh advfirewall firewall delete rule name=`"" s_soloPublicSessionPortBlockRule "`"", , "Hide")

	RunWait(A_ComSpec . ' /c "' . s_suspendExe . ' -r ' . s_procExeName . '"', , "Hide")

	ToolTip()
}

;#################################################################################################################################
; ======================================================================================================================
; ToolTipOptions      -  additional options for ToolTips
;
; Tooltip control     -> https://learn.microsoft.com/en-us/windows/win32/controls/tooltip-control-reference
; TTM_SETMARGIN       =  1050
; TTM_SETTIPBKCOLOR   =  1043
; TTM_SETTIPTEXTCOLOR =  1044
; TTM_SETTITLEW       =  1057
; WM_SETFONT          =  0x30
; SetClassLong()      -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclasslongw
; ======================================================================================================================
class ToolTipOptions {
	; -------------------------------------------------------------------------------------------------------------------
	static HTT := DllCall("User32.dll\CreateWindowEx", "UInt", 8, "Str", "tooltips_class32", "Ptr", 0, "UInt", 3
		, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", A_ScriptHwnd, "Ptr", 0, "Ptr", 0, "Ptr", 0)
	static SWP := CallbackCreate(ObjBindMethod(ToolTipOptions, "_WNDPROC_"), , 4) ; subclass window proc
	static OWP := 0															   ; original window proc
	static ToolTips := Map()
	; -------------------------------------------------------------------------------------------------------------------
	static BkgColor := ""
	static TxtColor := ""
	static Icon := ""
	static Title := ""
	static HFONT := 0
	static Margins := ""
	; -------------------------------------------------------------------------------------------------------------------
	static Call(*) => False ; do not create instances
	; -------------------------------------------------------------------------------------------------------------------
	; Init()    -  Initialize some class variables and subclass the tooltip control.
	; -------------------------------------------------------------------------------------------------------------------
	static Init() {
		if (This.OWP = 0) {
			This.BkgColor := ""
			This.TxtColor := ""
			This.Icon := ""
			This.Title := ""
			This.Margins := ""
			if (A_PtrSize = 8)
				This.OWP := DllCall("User32.dll\SetClassLongPtr", "Ptr", This.HTT, "Int", -24, "Ptr", This.SWP, "UPtr")
			else
				This.OWP := DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.SWP, "UInt")
			OnExit(ToolTipOptions._EXIT_, -1)
			return This.OWP
		}
		else
			return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	;  Reset()    -  Close all existing tooltips, delete the font object, and remove the tooltip's subclass.
	; -------------------------------------------------------------------------------------------------------------------
	static Reset() {
		if (This.OWP != 0) {
			for HWND In This.ToolTips.Clone()
				DllCall("DestroyWindow", "Ptr", HWND)
			This.ToolTips.Clear()
			if This.HFONT
				DllCall("DeleteObject", "Ptr", This.HFONT)
			This.HFONT := 0
			if (A_PtrSize = 8)
				DllCall("User32.dll\SetClassLongPtrW", "Ptr", This.HTT, "Int", -24, "Ptr", This.OWP, "UPtr")
			else
				DllCall("User32.dll\SetClassLongW", "Ptr", This.HTT, "Int", -24, "Int", This.OWP, "UInt")
			This.OWP := 0
			return True
		}
		else
			return False
	}
	; -------------------------------------------------------------------------------------------------------------------
	; SetColors()    -  Set or remove the text and/or the background color for the tooltip.
	; Parameters:
	;	 BkgColor  -  color value like used in Gui.BackColor(...)
	;	 TxtColor  -  see above.
	; -------------------------------------------------------------------------------------------------------------------
	static SetColors(BkgColor := "", TxtColor := "") {
		This.BkgColor := BkgColor = "" ? "" : BGR(BkgColor)
		This.TxtColor := TxtColor = "" ? "" : BGR(TxtColor)
		BGR(Color, Default := "") { ; converts colors to BGR
			; HTML Colors (BGR)
			static HTML := { AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080,
				GREEN: 0x008000, LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080,
				PURPLE: 0x800080, RED: 0x0000FF, SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF,
				YELLOW: 0x00FFFF }
			if HTML.HasProp(Color)
				return HTML.%Color%
			if (Color Is String) && IsXDigit(Color) && (StrLen(Color) = 6)
				Color := Integer("0x" . Color)
			if IsInteger(Color)
				return ((Color >> 16) & 0xFF) | (Color & 0x00FF00) | ((Color & 0xFF) << 16)
			return Default
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; SetFont()    -  Set or remove the font used by the tooltip.
	; Parameters:
	;	 FntOpts  -  font options like Gui.SetFont(Options, ...)
	;	 FntName  -  font name like Gui.SetFont(..., Name)
	; -------------------------------------------------------------------------------------------------------------------
	static SetFont(FntOpts := "", FntName := "") {
		static HDEF := DllCall("GetStockObject", "Int", 17, "UPtr") ; DEFAULT_GUI_FONT
		static LOGFONTW := 0
		if (FntOpts = "") && (FntName = "") {
			if This.HFONT
				DllCall("DeleteObject", "Ptr", This.HFONT)
			This.HFONT := 0
			LOGFONTW := 0
		}
		else {
			if (LOGFONTW = 0) {
				LOGFONTW := Buffer(92, 0)
				DllCall("GetObject", "Ptr", HDEF, "Int", 92, "Ptr", LOGFONTW)
			}
			HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
			LOGPIXELSY := DllCall("GetDeviceCaps", "Ptr", HDC, "Int", 90, "Int")
			DllCall("ReleaseDC", "Ptr", HDC, "Ptr", 0)
			if (FntOpts != "") {
				for Opt In StrSplit(RegExReplace(Trim(FntOpts), "\s+", " "), " ") {
					switch StrUpper(Opt) {
						case "BOLD": NumPut("Int", 700, LOGFONTW, 16)
						case "ITALIC": NumPut("Char", 1, LOGFONTW, 20)
						case "UNDERLINE": NumPut("Char", 1, LOGFONTW, 21)
						case "STRIKE": NumPut("Char", 1, LOGFONTW, 22)
						case "NORM": NumPut("Int", 400, "Char", 0, "Char", 0, "Char", 0, LOGFONTW, 16)
						Default:
							O := StrUpper(SubStr(Opt, 1, 1))
							V := SubStr(Opt, 2)
							switch O {
								case "C":
									continue ; ignore the color option
								case "Q":
									if !IsInteger(V) || (Integer(V) < 0) || (Integer(V) > 5)
										Throw ValueError("Option Q must be an integer between 0 and 5!", -1, V)
									NumPut("Char", Integer(V), LOGFONTW, 26)
								case "S":
									if !IsNumber(V) || (Number(V) < 1) || (Integer(V) > 255)
										Throw ValueError("Option S must be a number between 1 and 255!", -1, V)
									NumPut("Int", -Round(Integer(V + 0.5) * LOGPIXELSY / 72), LOGFONTW)
								case "W":
									if !IsInteger(V) || (Integer(V) < 1) || (Integer(V) > 1000)
										Throw ValueError("Option W must be an integer between 1 and 1000!", -1, V)
									NumPut("Int", Integer(V), LOGFONTW, 16)
								Default:
									Throw ValueError("Invalid font option!", -1, Opt)
							}
					}
				}
			}
			NumPut("Char", 1, "Char", 4, "Char", 0, LOGFONTW, 23) ; DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS
			NumPut("Char", 0, LOGFONTW, 27) ; FF_DONTCARE
			if (FntName != "")
				StrPut(FntName, LOGFONTW.Ptr + 28, 32)
			if !(HFONT := DllCall("CreateFontIndirectW", "Ptr", LOGFONTW, "UPtr"))
				Throw OSError()
			if This.HFONT
				DllCall("DeleteObject", "Ptr", This.HFONT)
			This.HFONT := HFONT
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; SetMargins()    -  Set or remove the margins used by the tooltip
	; Parameters:
	;	 L, T, R, B  -  left, top, right, and bottom margin in pixels.
	; -------------------------------------------------------------------------------------------------------------------
	static SetMargins(L := 0, T := 0, R := 0, B := 0) {
		if ((L + T + R + B) = 0)
			This.Margins := 0
		else {
			This.Margins := Buffer(16, 0)
			NumPut("Int", L, "Int", T, "Int", R, "Int", B, This.Margins)
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; SetTitle()    -  Set or remove the title and/or the icon displayed on the tooltip.
	; Parameters:
	;	 Title  -  string to be used as title.
	;	 Icon   -  icon to be shown in the ToolTip.
	;	          This can be the number of a predefined icon (1 = info, 2 = warning, 3 = error
	;	          (add 3 to display large icons on Vista+) or a HICON handle.
	; -------------------------------------------------------------------------------------------------------------------
	static SetTitle(Title := "", Icon := "") {
		switch {
			case (Title = "") && (Icon != ""):
				This.Icon := Icon
				This.Title := " "
			case (Title != "") && (Icon = ""):
				This.Icon := 0
				This.Title := Title
			Default:
				This.Icon := Icon
				This.Title := Title
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	; For internal use only!
	; -------------------------------------------------------------------------------------------------------------------
	static _WNDPROC_(hWnd, uMsg, wParam, lParam) {
		; WNDPROC -> https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-wndproc
		switch uMsg {
			case 0x0411: ; TTM_TRACKACTIVATE - just handle the first message after the control has been created
				if This.ToolTips.Has(hWnd) && (This.ToolTips[hWnd] = 0) {
					if (This.BkgColor != "")
						SendMessage(1043, This.BkgColor, 0, hWnd)				; TTM_SETTIPBKCOLOR
					if (This.TxtColor != "")
						SendMessage(1044, This.TxtColor, 0, hWnd)				; TTM_SETTIPTEXTCOLOR
					if This.HFONT
						SendMessage(0x30, This.HFONT, 0, hWnd)				   ; WM_SETFONT
					if (Type(This.Margins) = "Buffer")
						SendMessage(1050, 0, This.Margins.Ptr, hWnd)			 ; TTM_SETMARGIN
					if (This.Icon != "") || (This.Title != "")
						SendMessage(1057, This.Icon, StrPtr(This.Title), hWnd)   ; TTM_SETTITLE
					This.ToolTips[hWnd] := 1
				}
			case 0x0001: ; WM_CREATE
				DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "Ptr", 0, "Ptr", StrPtr(""))
				This.ToolTips[hWnd] := 0
			case 0x0002: ; WM_DESTROY
				This.ToolTips.Delete(hWnd)
		}
		return DllCall(This.OWP, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "UInt")
	}
	; -------------------------------------------------------------------------------------------------------------------
	static _EXIT_(*) {
		if (ToolTipOptions.OWP != 0)
			ToolTipOptions.Reset()
	}
}
