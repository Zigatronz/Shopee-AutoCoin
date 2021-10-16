
GetCurrentVersion(){
	local VerText:=""
	try VerText := FileRead("Data\Version.txt")
	Catch
	{
		Return 0
	}Else{
		Return Float(SubStr(VerText, InStr(VerText, Chr(34)) + 1, (InStr(VerText, Chr(34), False, InStr(VerText, Chr(34)) + 1)) - (InStr(VerText, Chr(34)) + 1)))
	}
}

CheckUpdateVersion(){
	local ReceivedHTML, TextPosition:=0, TextStart:=0, TextEnd:=0
	RunWait(A_ComSpec . " /c curl https://github.com/Zigatronz/Shopee-AutoCoin/blob/master/Data/Version.txt > " . Chr(34) . "Data\updatecache.dat" . Chr(34), A_ScriptDir, "Hide")
	ReceivedHTML := FileRead("Data\updatecache.dat")
	FileDelete "Data\updatecache.dat"
	TextPosition := InStr(ReceivedHTML, "SoftwareVersion=", False)
	if (TextPosition != 0){
		TextStart := InStr(ReceivedHTML, "&quot;", False, TextPosition) + 6
		TextEnd := InStr(ReceivedHTML, "&quot;", False, TextStart)
		Return Float(SubStr(ReceivedHTML, TextStart, TextEnd - TextStart))
	}
	Return 0
}

GetPythonProgress(&ProgressName, &Percentage){
	local PythonRespond:=[]
	if (!ProgressName)
		ProgressName := "Waiting for data..."
	if (!Percentage)
		Percentage := 0
	PythonRespond := [
		"Initializing...",
		"Loading cookies...",
		"Loading webpage...",
		"Processing login",
		"Loading QRCode...",
		"QRCode Loaded",
		"Reloading QRCode...",
		"Login Complete",
		"Collecting coin...",
		"Coin collected",
		"Settled"
	]
	for i,c in PythonRespond
	{
		if (FileExist("cache\progress\" . c)){
			ProgressName := c
			Percentage := Round( ( i / PythonRespond.Length ) * 100 )
		}
	}
}

WinGetPos_(WinTitle){
	local TaskBarX:=0, TaskBarY:=0, TaskBarW:=0, TaskBarH:=0
	try WinGetPos(&TaskBarX, &TaskBarY, &TaskBarW, &TaskBarH, WinTitle)
	Catch
	{
		Return [0, 0, 0, 0]
	}
	Else
	{
		Return [TaskBarX, TaskBarY, TaskBarW, TaskBarH]
	}
}

WriteLastCheck(WriteEmpty:=False){
	global
	if (WriteEmpty){
		if (!FileExist(ConfigFile))
			IniWrite("", ConfigFile, "UserData", "LastCheck")
	}Else{
		IniWrite(GetTodayDate(), ConfigFile, "UserData", "LastCheck")
	}
}

DateToHumanReadable(date){
	global
	if (StrLen(date) != 8){
		MsgBox("Function Error! Please report to the developer if this occur.`n`nFunction: 'DateToHumanReadable()'`nInput: '" . date . "'`nLen: '" . StrLen(date) . "'`nError Code:FU15", WinTitle, 48)
		Return "ERROR"
	}
	Return SubStr(date, 7, 2) . "/" . SubStr(date, 5, 2) . "/" . SubStr(date, 1, 4)
}

GetTodayDate(){
	Return SubStr(A_Now, 1, 8)
}

IniRead_(Filename, Section, Key, Default:=""){
	local out
	if (FileExist(Filename)){
		if (Default)
			out := IniRead(Filename, Section, Key, Default)
		Else
			out := IniRead(Filename, Section, Key, "Error")
	}Else{
		out := "Error"
	}
	return out
}

durationToMillisecond(timestr:=""){
	if (StrLower(SubStr(timestr, -1)) == "h"){
		Return SubStr(timestr, 1, StrLen(timestr) - 1) * 60 * 60 * 1000
	}
	if (StrLower(SubStr(timestr, -1)) == "m"){
		Return SubStr(timestr, 1, StrLen(timestr) - 1) * 60 * 1000
	}
	if (StrLower(SubStr(timestr, -1)) == "s"){
		Return SubStr(timestr, 1, StrLen(timestr) - 1) * 1000
	}
	Return 0
}

LinearInterpolation(t, a, b){
	return a + (t * (b - a))
}

StayInRange(x, min, max){
	if (min > max){
		h := min
		min := max
		max := h
	}
	if (x < min){
		Return min
	}
	if (x > max){
		Return max
	}
	Return x
}

; thanks jNizM
int2hex(int, HEX_INT:=2){
	h := ""
    while (HEX_INT--)
    {
        n := (int >> (HEX_INT * 4)) & 0xf
        h .= n > 9 ? chr(0x37 + n) : n
    }
    return h
}

FullPathToPythonPath(path){
	path := StrReplace(path, A_WorkingDir . "\", "")
	path := StrReplace(path, "\", "\\")
	Return path
}
