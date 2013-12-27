-- [[the Copy pasterino 1.0]] --


--Have you ever wanted to CopyPaste something but noticed you can't ctrl+v in-game? Well those days are over, download this script with customizable keys
--Features:
--No delay on copy pasterino
--Has function to paste into all chat or just to team


function OnLoad()
	CopyPasterinoConfig = scriptConfig("Copy Pasterino 1.0","Copy Pasterino")
	CopyPasterinoConfig:addParam("sep", "--- Keys ---", SCRIPT_PARAM_INFO, "")
	CopyPasterinoConfig:addParam("tchat", "Team Chat", SCRIPT_PARAM_ONKEYDOWN, false, 103) --Default NumPad 7
	CopyPasterinoConfig:addParam("achat", "All chat", SCRIPT_PARAM_ONKEYDOWN, false, 100) --Default Numpad 4
	PrintChat("The Copy Pasterino 1.0")
	end
	
function OnWndMsg(msg, wParam)
    if CopyPasterinoConfig.tchat == true then
        pasterino = GetClipboardText()
        SendChat(pasterino)
  end
		if CopyPasterinoConfig.achat == true then
        pasterino = GetClipboardText()
        SendChat("/all " .. pasterino)
				end
end
