#NoEnv
; #Warn

SendMode Input

SetWorkingDir %A_ScriptDir%

Global Mode := 0
Global Cooldowns := [ 0, 0, 0 ] ; R кулдаун, деш вперёд кулдаун, деш влево/вправо/назад кулдаун
Global LastTime := [ -1, -1, -1 ]

Global RButton := 0

Global ConfigFilePath := % A_ScriptName . ".config.ini"

Mode := GetConfigValue("settings", "mode", 0)

Global Modes := { 0: "Honored One", 1: "Ten Shadows", 2: "Restless Gambler", 3: "Vessel", 4: "Perfection" }
Global ModeMaxLength := -1

for k, v in Modes
{
	len := StrLen(v)
	if (ModeMaxLength < len)
		ModeMaxLength := len
}

Gui, Mode: -Caption +AlwaysOnTop +Owner +LastFound
WinSet, TransColor, EEAA99
Gui, Cooldown: -Caption +AlwaysOnTop +Owner +LastFound
WinSet, TransColor, EEAA99

Gui, Mode: Color, EEAA99
Gui, Cooldown: Color, EEAA99

Gui, Mode: Font, cWhite s20, Times New Roman

Gui, Mode: Add, Text, vText, % "Mode:`n" . StringRepeat("#", ModeMaxLength)
GuiControl, Mode:, Text, % "Mode:`n" . Modes[Mode]

Gui, Cooldown: Font, cWhite s20, Times New Roman
Gui, Cooldown: Add, Text, vText, R Cooldown: 00`nQW Cooldown: 00`nQASD Cooldown: 00

Global Data := Array()

{ ; Mode
	array := Array()
	
	array.X := -1
	array.Y := -1
	
	array.Hidden := 0
	
	Data.Mode := array
}
{ ; Cooldown
	array := Array()
	
	array.X := -1
	array.Y := -1
	
	array.Hidden := 0
	
	Data.Cooldown := array
}

Loop
{
	CooldownUpdate()

	IfWinActive, ahk_exe RobloxPlayerBeta.exe
		InWindow()
	else
		OutWindow()
}

InWindow() 
{
	Show()
}
OutWindow()
{
	if (Data.Mode.Hidden == 0)
	{
		Gui, Mode: Hide
		Data.Mode.Hidden := 1
	}
	if (Data.Cooldown.Hidden == 0)
	{
		Gui, Cooldown: Hide
		Data.Cooldown.Hidden := 1
	}
}

Show() 
{
	WinGetPos, x, y, w, h, ahk_exe RobloxPlayerBeta.exe
	
	{ ; Mode
		
		xPos := x + w - 60 - StrLen(Modes[Mode]) * 12
		yPos := y + h - 90
		
		array := Data.Mode
		if (array.Hidden == 1 OR array.X != xPos OR array.Y != yPos)
		{
			array.X := xPos
			array.Y := yPos
			
			array.Hidden := 0
			
			Gui, Mode: Show, NA X%xPos% Y%yPos%, ModeTitle
		}
	}
	; if (Mode == 0)
	{ ; Cooldown
		xPos := x
		yPos := y + h - 40 * Cooldowns.Count()
		
		array := Data.Cooldown
		
		if (array.Hidden == 1 OR array.X != xPos OR array.Y != yPos)
		{
			array.X := xPos
			array.Y := yPos
			
			array.Hidden := 0
			
			Gui, Cooldown: Show, NA X%xPos% Y%yPos%
		}
	}
	;else
	;{
	;	Gui, Cooldown: Hide
	;	Data.Cooldown.Hidden := 1
	;}
		
}

Global RefreshCooldown := 0

CooldownUpdate()
{
	CurrentTime := A_TickCount
	
	if (RefreshCooldown > 0)
	{
		GuiControl, Cooldown:, Text, % "R Cooldown: " . Cooldowns[1] . "`nQW Cooldown: " . Cooldowns[2] . "`nQASD Cooldown: " . Cooldowns[3]
		RefreshCooldown := 0
	}
	
	for k, v in Cooldowns
	{
		if (CurrentTime - LastTime[k] >= 1000)
		{
			if (Cooldowns[k] > 0)
			{
				Cooldowns[k] -= 1
				RefreshCooldown += 1
				LastTime[k] := CurrentTime
			}
		}
	}
}

StringRepeat(char, count)
{
	str := ""
	Loop, %count%
	{
	  str .= char
	}
	return str
}

SendSequence(count) 
{
	Loop, %count% {
		Send {g}
	}
	Send {r}
}

GetConfigValue(section, key, defaultValue = 0)
{
	IniRead, value, %ConfigFilePath%, %section%, %key%, %defaultValue%
	return value
}
SetConfigValue(section, key, value)
{
	IniWrite, %value%, %ConfigFilePath%, %section%, %key%
}

~R::
{
	if (Cooldowns[1] > 0)
		return
	switch (Mode)
	{
		Case 0:
			Cooldowns[1] := 15
		Case 1:
			Cooldowns[1] := 10
		Case 2:
			Cooldowns[1] := 12
		Case 3:
			; RButton += 1
			; Cooldowns[1] := 2
		Case 4:
			Cooldowns[1] := 1
		
		Default:
			Cooldowns[1] := 0
			return
	}
	RefreshCooldown += 1
	LastTime[1] := A_TickCount 
	return
}
~Q::
{
	
	if (GetKeyState("A") OR GetKeyState("S") OR GetKeyState("D"))
	{
		if (Cooldowns[3] <= 0)
		{
			Cooldowns[3] := 2
			LastTime[3] := A_TickCount 
		}
	}
	else if ( Cooldowns[2] <= 0 )
	{
		Cooldowns[2] := 6
		LastTime[2] := A_TickCount 
	}
	RefreshCooldown += 1
	return
}

F1::
{
	Loop 
	{
		if !GetKeyState("F1", "P")
			break
		
		Send {Space Down}
		Sleep 10
		Send {Space Up}
		Sleep 20
	}
	return
}
F2::
{
	Mode := mod(Mode + 1, Modes.Count())
	SetConfigValue("settings", "mode", Mode)
	GuiControl, Mode:, Text, % "Mode:`n" . Modes[Mode]
	
	for k, v in Cooldowns 
	{
		Cooldowns[k] := 0
	}
	
	RefreshCooldown += 1
	
	return
}
*XButton2::
{
	Switch (Mode)
	{
		Case 0:
			; if (Cooldowns[1] > 0)
			; 	return
			
			Send {2}
			Sleep 40
			Send {r}
			
			Cooldowns[1] := 15
			RefreshCooldown += 1
			
		Case 1:
			SendSequence(1)
			
		Case 3:
			Send, {3}
			Sleep 350
			Send, {3}
		
		Case 4:
			Send {r}
	}
	return
}
*XButton1::
{
	Switch (Mode)
	{
		Case 1:
			SendSequence(2)
			
		Case 3:
			Send, {1}
			Send, {3}
			Send, {2}
			Sleep 1000
			Send {r}
			
		;Case 4:
		;	Send, {3}
			
	}
	return
}

; Планировалось для махараги сделать
; *WheelDown::
; {
; 	if (Mode == 1)
; 		SendSequence(3)
; 	return
; }
; *WheelUp::
; {
; 	if (Mode == 1)
; 		SendSequence(1)
; 	return
; }

; Потом необходимо тоже доделать для махараги.
; https://en.key-test.ru

;$3::
;{
;	If (Mode == 1)
;	{
;		Send {3 down}
;		Sleep 1250
;		Send {3 up}
;		MsgBox, Otzhato
;	}
;	else
;		Send {3}
;	return
;}

