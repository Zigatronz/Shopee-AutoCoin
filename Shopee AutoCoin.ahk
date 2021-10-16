; allow only one running
#SingleInstance Ignore
Persistent
SetWorkingDir(A_ScriptDir)
WinTitle := "Shopee AutoCoin"						; windows title
if (!FileExist("Data\User"))
	DirCreate "Data\User"
ConfigFile := A_ScriptDir . "\Data\User\config.ini"	; Config file path
if (FileExist("Data\Icon\shopeecoin.ico"))
	TraySetIcon("Data\Icon\shopeecoin.ico")
; Some GUI config
AccentColor := "FF8000"
FGColor := "FFFFFF"
BGColor := "191919"

; some global variables
PythonPID := 0
QRGUI_is_showing := False
MainGui_is_showing := False

; Config stuff
if (!FileExist(ConfigFile))
	FileAppend("", ConfigFile, "UTF-8-RAW")
if (!FileExist(StrReplace(IniRead_(ConfigFile, "Setting", "FirefoxPath", ""), "\\", "\"))){
	if (FileExist("C:\Program Files\Mozilla Firefox\firefox.exe")){
		IniWrite("C:\\Program Files\\Mozilla Firefox\\firefox.exe", ConfigFile, "Setting", "FirefoxPath")
	}Else{
		if (MsgBox("This software require Firefox.`n`nDo you got Firefox on your Windows?", WinTitle, "68") == "Yes"){
			FirefoxPath := FileSelect(1, "", "Please locate Firefox.exe", "*.exe")
			if (FirefoxPath){
				IniWrite(FullPathToPythonPath(FirefoxPath), ConfigFile, "Setting", "FirefoxPath")
			}Else{
				if (MsgBox("You need to have Firefox installed on your Windows to be able to use this software.`n`nDo you wish to open your browser to download Firefox?", WinTitle, "68") == "Yes"){
					Run("https://www.mozilla.org")
					ExitApp
				}Else{
					ExitApp
				}
			}
		}Else{
			if (MsgBox("You need to install Firefox on your Windows first.`n`nDo you wish to open your browser to download Firefox?", WinTitle, "68") == "Yes"){
				Run("https://www.mozilla.org")
				ExitApp
			}Else{
				ExitApp
			}
		}
	}
}
if (!FileExist(StrReplace(IniRead_(ConfigFile, "Setting", "FirefoxDriverPath", ""), "\\", "\"))){
	if (FileExist("Data\BrowserDriver\geckodriver-v0.29.0-win64\geckodriver.exe")){
		IniWrite("Data\\BrowserDriver\\geckodriver-v0.29.0-win64\\geckodriver.exe", ConfigFile, "Setting", "FirefoxDriverPath")
	}Else{
		if (MsgBox("This software require Firefox driver (a.k.a. Gecko driver).`n`nDo you have Firefox driver?", WinTitle, "68") == "Yes"){
			FirefoxDriverPath := FileSelect(1, "", "Please locate GeckoDriver.exe", "*.exe")
			if (FirefoxDriverPath){
				IniWrite(FullPathToPythonPath(FirefoxDriverPath), ConfigFile, "Setting", "FirefoxDriverPath")
			}Else{
				if (MsgBox("You need to have Firefox Driver to be able to use this software.`n`nDo you wish to open your browser to download Firefox Driver?", WinTitle, "68") == "Yes"){
					Run("https://github.com/mozilla/geckodriver/releases")
					ExitApp
				}Else{
					ExitApp
				}
			}
		}Else{
			if (MsgBox("You need to have Firefox Driver first.`n`nDo you wish to open your browser to download Firefox Driver?", WinTitle, "68") == "Yes"){
				Run("https://github.com/mozilla/geckodriver/releases")
				ExitApp
			}Else{
				ExitApp
			}
		}
	}
}
if (IniRead_(ConfigFile, "UserData", "CookiesPath") == "Error"){
	IniWrite("Data\\User\\Cookie.dat", ConfigFile, "Setting", "CookiesPath")
}
if (IniRead_(ConfigFile, "UserData", "BrowserTimeout") == "Error"){
	IniWrite("30", ConfigFile, "Setting", "BrowserTimeout")
}
if (IniRead_(ConfigFile, "UserData", "CheckInterval ") == "Error"){
	IniWrite("10m", ConfigFile, "Setting", "CheckInterval")
}
MainInterval := durationToMillisecond(IniRead_(ConfigFile, "Setting", "checkInterval", "10m"))
SetTimer(Main, MainInterval)
; remove old cache
if (FileExist("cache"))
	DirDelete "cache", 1
; Tray menu
if (A_IsCompiled)
	A_TrayMenu.delete
A_TrayMenu.Add("Open " . WinTitle, OpenMainWindow)
A_TrayMenu.Add("Exit", ExitProgram)
A_TrayMenu.Default := "Open " . WinTitle
; Check for update
if (CheckUpdateVersion() > GetCurrentVersion()){
	if (MsgBox("An update is available!`n`nDo you wish to check for an update? this will open up your browser.", WinTitle, "68 T30") == "Yes")
		Run("https://github.com/Zigatronz/Shopee-AutoCoin/releases")
	Else
		OpenMainWindow()
}Else{
	OpenMainWindow()
}

OpenMainWindow(*){
	global
	if (!MainGui_is_showing){
		if (IniRead_(ConfigFile, "UserData", "lastcheck") != "Error"){
			MainGUI_Show(
				DateToHumanReadable(IniRead_(ConfigFile, "UserData", "lastcheck")),
				(IniRead_(ConfigFile, "UserData", "lastcheck") == GetTodayDate())? True : False,
				IniRead_(ConfigFile, "UserData", "coinearned"),
				StrReplace(IniRead_(ConfigFile, "Setting", "firefoxpath"), "\\", "\"),
				StrReplace(IniRead_(ConfigFile, "Setting", "firefoxdriverpath"), "\\", "\"),
				StrReplace(IniRead_(ConfigFile, "Setting", "cookiespath"), "\\", "\")
			)
		}Else{
			MainGUI_Show(
				"Never",
				False,
				0,
				StrReplace(IniRead_(ConfigFile, "Setting", "firefoxpath"), "\\", "\"),
				StrReplace(IniRead_(ConfigFile, "Setting", "firefoxdriverpath"), "\\", "\"),
				StrReplace(IniRead_(ConfigFile, "Setting", "cookiespath"), "\\", "\")
			)
		}
	}
}

Main(){
	global
	if (IniRead_(ConfigFile, "UserData", "lastcheck") != GetTodayDate()){
		WriteLastCheck(True)
		SetTimer(Main, 0)
		AskForUserConformation()
	}
}

AskForUserConformation(){
	global
	if (IniRead_(ConfigFile, "UserData", "lastcheck") == "Error"){
		ReminderGUI_Show("Never", 0)
	}Else{
		ReminderGUI_Show(DateToHumanReadable(IniRead_(ConfigFile, "UserData", "lastcheck")), IniRead_(ConfigFile, "UserData", "coinearned"))
	}
}

RunCollectCoin(){
	global
	if (!FileExist("Data\Lib\CollectCoin Firefox via QR.exe")){
		if (MsgBox("Seems like one of the most important file is missing:`n" . A_ScriptDir . "\Data\Lib\CollectCoin Firefox via QR.exe`nIf this is unexpected error, this might comes from your antivirus detecting false positive virus. Please exclude this file and reinstall this software.`n`nDo you wish to download the installer? This will open up your browser.", WinTitle, "20") == "Yes"){
			Run("https://github.com/Zigatronz/Shopee-AutoCoin/releases")
			ExitApp
		}Else{
			ExitApp
		}
	}
	if(A_IsCompiled){
		Run("Data\Lib\CollectCoin Firefox via QR.exe", A_ScriptDir, "Hide", &PythonPID)
	}Else{
		; For debugging
		Run("Data\Lib\CollectCoin Firefox via QR.py", A_ScriptDir, "", &PythonPID)
	}
	ProgressGUI_Show()
	SetTimer(PythonWatcher, 500)
}

PythonWatcher(){
	global
	local PythonProgressName:="", PythonProgressPercentage:=0
	static QRTime:=""
	
	; Update Progress GUI
	GetPythonProgress(&PythonProgressName, &PythonProgressPercentage)
	ProgressGUI_Text.Text := PythonProgressName
	ProgressGUI_Progress.Value := PythonProgressPercentage

	; Destroy GUI when python is dead
	if (!ProcessExist(PythonPID)){
		Sleep(250)
		SetTimer(PythonWatcher, 0)
		ProgressGUI.Destroy()
		; remove python cache
		if (FileExist("cache"))
			DirDelete "cache", 1
	}

	; Show QR code when it's available
	if (FileExist("cache\QRCode.png")){
		if (FileGetTime("cache\QRCode.png", "M") != QRTime){
			if (QRGUI_is_showing){
				QRGUI.Destroy()
				QRGUI_is_showing := false
			}
			FileCopy("cache\QRCode.png", "cache\QRCodeCache.png", 1)
			QRGUI_Show()
			QRTime := FileGetTime("cache\QRCode.png", "M")
		}
	}Else{
		if (QRGUI_is_showing){
			QRGUI.Destroy()
			if (FileExist("cache\QRCodeCache.png"))
				FileDelete("cache\QRCodeCache.png")
			QRGUI_is_showing := false
		}
	}
}

MainGui_Relocate_Firefox(GuiCtrlObj, Info){
	global
	local filePath
	filePath := FileSelect(1, "", "Locate Firefox.exe", "*.exe")
	if (filePath){
		IniWrite(FullPathToPythonPath(filePath), ConfigFile, "Setting", "FirefoxPath")
		MainGui_FirefoxPath.text := "Firefox path: " . StrReplace(FullPathToPythonPath(filePath), "\\", "\")
	}
}

MainGui_Relocate_Driver(GuiCtrlObj, Info){
	global
	local filePath
	filePath := FileSelect(1, "", "Locate Geckodriver.exe", "*.exe")
	if (filePath){
		IniWrite(FullPathToPythonPath(filePath), ConfigFile, "Setting", "FirefoxDriverPath")
		MainGui_DriverPath.text := "Firefox driver path: " . StrReplace(FullPathToPythonPath(filePath), "\\", "\")
	}
}

MainGui_Relocate_Cookie(GuiCtrlObj, Info){
	global
	local filePath
	filePath := FileSelect("S2", "", "Please locate Cookie.dat", "*.dat")
	if (filePath){
		IniWrite(FullPathToPythonPath(filePath), ConfigFile, "Setting", "CookiesPath")
		MainGui_CookiePath.text := "Cookie path: " . StrReplace(FullPathToPythonPath(filePath), "\\", "\")
	}
}

MainGui_Submit_CheckNow(GuiCtrlObj, Info){
	global
	MainGui_is_showing := False
	RunCollectCoin()
	SetTimer(Main, MainInterval)
}

ReminderGUI_Submit_CheckNow(GuiCtrlObj, Info){
	global
	ReminderGui.Destroy()
	RunCollectCoin()
	SetTimer(Main, MainInterval)
}

ReminderGUI_Submit_Later(GuiCtrlObj, Info){
	global
	ReminderGui.Destroy()
	SetTimer(AskForUserConformation, 3600 * -1000)	; run this timer once
}

ReminderGUI_Submit_NotToday(GuiCtrlObj, Info){
	global
	ReminderGui.Destroy()
	WriteLastCheck()
	SetTimer(Main, MainInterval)
	
}

ExitProgram(*){
	global
	Loop
	{
		if (ProcessExist(PythonPID)){
			Sleep(2500)
		}Else{
			Break
		}
	}
	ExitApp
}

#Include Data\Lib\Func.ahk
#Include Data\Lib\GUI.ahk
