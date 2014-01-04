-- [[the Copy pasterino 1.1]] --


--Have you ever wanted to CopyPaste something but noticed you can't ctrl+v in-game? Well those days are over, download this script with customizable keys
--Features:
--No delay on copy pasterino
--Has function to paste into all chat or just to team

--Changelog 1.1
--Fixed bug where if clipboard was empty game would crash



function OnLoad()
    CopyPasterinoConfig = scriptConfig("Copy Pasterino 1.1","Copy Pasterino")
	CopyPasterinoConfig:addParam("sep", "--- Keys ---", SCRIPT_PARAM_INFO, "")
	CopyPasterinoConfig:addParam("tchat", "Team Chat", SCRIPT_PARAM_ONKEYDOWN, false, 103) --Default Numpad 7
	CopyPasterinoConfig:addParam("achat", "All chat", SCRIPT_PARAM_ONKEYDOWN, false, 100) --Default Numpad 4
	PrintChat("The Copy Pasterino 1.1 has been loaded")
	end
	
function OnWndMsg(msg, wParam)
    if CopyPasterinoConfig.tchat == true then
        pasterino = GetClipboardText()
            if pasterino ~= "" then      
        SendChat(pasterino) 
					else PrintChat("Please Copy something into clipboard")
  end
	end
		if CopyPasterinoConfig.achat == true then
        pasterino = GetClipboardText()
						if pasterino ~= "" then
        SendChat("/all " .. pasterino)
							else PrintChat("Please Copy something into the Clipboard")
				end
				end
end
