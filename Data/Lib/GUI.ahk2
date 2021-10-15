
ProgressGUI_Show(){
	global
	ProgressGUI := Gui("-Caption -Resize", WinTitle)
    ProgressGUI.BackColor := BGColor

	ProgressGUI.SetFont("s13 c" . AccentColor, "Arial Black")
	ProgressGUI.Add("Text", "x15 y5 w304 h25 -Wrap", WinTitle)
	ProgressGUI.SetFont("s12 c" . FGColor, "Arial")

	ProgressGUI_Text := ProgressGUI.Add("Text", "x30 y40 w288 h20 Center", "Waiting for data...")
	ProgressGUI_Progress := ProgressGUI.Add("Progress", "x10 y65 w328 h20 Range0-100 c" . AccentColor, 0)

	GuiShow_BottomRight(ProgressGUI, [348, 95])
}

QRGUI_Show(){
	global
	QRGUI := Gui("-Caption -Resize +ToolWindow +AlwaysOnTop", WinTitle)
    QRGUI.BackColor := BGColor

	QRGUI.SetFont("s14 c" . AccentColor, "Arial Black")
	QRGUI.Add("Text", "x15 y12 w304 h25 -Wrap", WinTitle)
	QRGUI.SetFont("s14 c" . FGColor, "Arial")

	if(FileExist("cache\QRCode.png")){
		Loop{
			if (FileGetSize("cache\QRCode.png") > 500){
				Break
			}Else{
				Sleep(500)
			}
		}
		FileCopy("cache\QRCode.png", "cache\QRCodeCache.png", 1)
		if (FileExist("cache\QRCodeCache.png"))
			QRGUI.Add("Picture", "x77 y60 w180 h180", "cache\QRCodeCache.png")
	}

	QRGUI.Add("Text", "x30 y275 w274 h100", "Please scan this QR code via Shopee App.")
	
	GuiShow_BottomRight(QRGUI, [334, 453])
    QRGUI_is_showing := true
}

MainGUI_Show(LastCheck, Today, CoinEarned, FirefoxPath, DriverPath, CookiePath){
	global
	local ActiveWindow:=""
	MainGui := Gui("-Caption -Resize +ToolWindow +AlwaysOnTop", WinTitle)
    MainGui.BackColor := BGColor

	MainGui.SetFont("s13 c" . AccentColor, "Arial Black")
	MainGui.Add("Text", "x15 y7 w382 h25 -Wrap", WinTitle)
	MainGui.SetFont("s11 c" . FGColor, "Arial")

	MainGui.Add("GroupBox", "x15 y30 w380 h80", "Info")
	MainGui.Add("Text", "x30 y45 w155 h18", "Last check: " LastCheck)
	MainGui.Add("Text", "x185 y45 w195 h18 c00FF00", (Today)?"( Today )":"")
	MainGui.Add("Text", "x30 y61 w350 h18", "Shopee coin earned:")
	MainGui.Add("Text", "x170 y61 w195 h18 c" . int2hex(Round(StayInRange(LinearInterpolation(CoinEarned/1000, 255, 0),0,255))) . "FF00", CoinEarned)
	MainGui.SetFont("s11 c" . FGColor, "Arial Black")
	MainGui.Add("Button", "x30 y80 w205 h20", "Check Now").OnEvent("Click", MainGui_Submit_CheckNow)
	MainGui.SetFont("s11 c" . FGColor, "Arial")

	MainGui.Add("GroupBox", "x15 y120 w380 h190", "Settings")
	MainGui_FirefoxPath := MainGui.Add("Text", "x30 y137 w350 h35", "Firefox path: " . FirefoxPath)
	MainGui.SetFont("s11 c" . FGColor, "Arial Black")
	MainGui.Add("Button", "x30 y170 w205 h20", "Relocate Firefox").OnEvent("Click", MainGui_Relocate_Firefox)
	MainGui.SetFont("s11 c" . FGColor, "Arial")
	MainGui_DriverPath := MainGui.Add("Text", "x30 y192 w350 h35", "Firefox driver path: " . DriverPath)
	MainGui.SetFont("s11 c" . FGColor, "Arial Black")
	MainGui.Add("Button", "x30 y225 w205 h20", "Relocate Firefox Driver").OnEvent("Click", MainGui_Relocate_Driver)
	MainGui.SetFont("s11 c" . FGColor, "Arial")
	MainGui_CookiePath := MainGui.Add("Text", "x30 y247 w350 h35", "Cookie path: " . CookiePath)
	MainGui.SetFont("s11 c" . FGColor, "Arial Black")
	MainGui.Add("Button", "x30 y280 w205 h20", "Relocate Cookie").OnEvent("Click", MainGui_Relocate_Cookie)
	MainGui.SetFont("s11 c" . FGColor, "Arial")

	GuiShow_BottomRight(MainGui, [412, 323])
	MainGui_is_showing := true
	Loop
	{
		Sleep(250)
		Try ActiveWindow := WinGetTitle("A")
		catch {
			Sleep(100)
		}
		if (ActiveWindow != WinTitle) or (!MainGui_is_showing){
			Break
		}
	}
	MainGui_is_showing := False
	MainGui.Destroy()
}

ReminderGUI_Show(LastCheck, CoinEarned){
	global
	ReminderGui := Gui("-Caption -Resize", WinTitle)
    ReminderGui.BackColor := BGColor

	ReminderGui.SetFont("s13 c" . AccentColor, "Arial Black")
	ReminderGui.Add("Text", "x15 y7 w382 h25 -Wrap", WinTitle)
	ReminderGui.SetFont("s11 c" . FGColor, "Arial")

	ReminderGui.Add("GroupBox", "x15 y30 w380 h58", "Info")
	ReminderGui.Add("Text", "x30 y45 w155 h18", "Last check: " LastCheck)
	ReminderGui.Add("Text", "x30 y61 w350 h18", "Shopee coin earned:")
	ReminderGui.Add("Text", "x170 y61 w195 h18 c" . int2hex(Round(StayInRange(LinearInterpolation(CoinEarned/1000, 255, 0),0,255))) . "FF00", CoinEarned)
	ReminderGui.SetFont("s11 c" . FGColor, "Arial Black")
	ReminderGui.Add("Button", "x20 y97 w370 h25", "Check Now").OnEvent("Click", ReminderGUI_Submit_CheckNow)
	ReminderGui.Add("Button", "x20 y130 w180 h25", "Remind me later").OnEvent("Click", ReminderGUI_Submit_Later)
	ReminderGui.Add("Button", "x210 y130 w180 h25", "Not today").OnEvent("Click", ReminderGUI_Submit_NotToday)

	GuiShow_BottomRight(ReminderGui, [412, 170])
}

GuiShow_BottomRight(Gui, GuiSize){
	local TaskBarPos:=WinGetPos_("ahk_class Shell_TrayWnd")
	if (TaskBarPos[1] < A_ScreenWidth / 2) && (TaskBarPos[2] > A_ScreenHeight / 2) && (TaskBarPos[3] > A_ScreenWidth / 2){ ; bottom
		Gui.Show("x" . A_ScreenWidth - GuiSize[1] . " y" . A_ScreenHeight - GuiSize[2] - TaskBarPos[4] . "w" . GuiSize[1] . " h" . GuiSize[2])
	}
	if (TaskBarPos[1] < A_ScreenWidth / 2) && (TaskBarPos[2] < A_ScreenHeight / 2) && (TaskBarPos[3] > A_ScreenWidth / 2){ ; top
		Gui.Show("x" . A_ScreenWidth - GuiSize[1] . " y" . A_ScreenHeight - GuiSize[2] . "w" . GuiSize[1] . " h" . GuiSize[2])
	}
	if (TaskBarPos[1] < A_ScreenWidth / 2) && (TaskBarPos[2] < A_ScreenHeight / 2) && (TaskBarPos[3] < A_ScreenWidth / 2){ ; left
		Gui.Show("x" . A_ScreenWidth - GuiSize[1] . " y" . A_ScreenHeight - GuiSize[2] . "w" . GuiSize[1] . " h" . GuiSize[2])
	}
	if (TaskBarPos[1] > A_ScreenWidth / 2) && (TaskBarPos[2] < A_ScreenHeight / 2) && (TaskBarPos[3] < A_ScreenWidth / 2){ ; right
		Gui.Show("x" . A_ScreenWidth - GuiSize[1] - TaskBarPos[3] . " y" . A_ScreenHeight - GuiSize[2] . "w" . GuiSize[1] . " h" . GuiSize[2])
	}
}
