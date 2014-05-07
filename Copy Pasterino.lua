-- [[the Copy pasterino 1.1]] --


--Have you ever wanted to CopyPaste something but noticed you can't ctrl+v in-game? Well those days are over, download this script with customizable keys
--Features:
--No delay on copy pasterino
--Has function to paste into all chat or just to team

--Changelog 1.1
--Fixed bug where if clipboard was empty game would crash
--1.2
-- Code was fucking ugly(yeah how is that possible in 20 lines?)



function OnLoad()
	Menu = scriptConfig("Copy Pasterino 1.2","Copy Pasterino")
	Menu:addParam("sep", "--- Keys ---", SCRIPT_PARAM_INFO, "")
	Menu:addParam("tchat", "Team Chat", SCRIPT_PARAM_ONKEYDOWN, false, 103) --Default Numpad 7
	Menu:addParam("achat", "All chat", SCRIPT_PARAM_ONKEYDOWN, false, 100) --Default Numpad 4
	PrintChat("The Copy Pasterino 1.2 has been loaded")
end

function OnWndMsg(msg, wParam)
	if Menu.tchat == true then
		pasterino = GetClipboardText()
		if pasterino ~= nil then      
			SendChat(pasterino) 
		else 
			PrintChat('Please Copy something into clipboard')
		end
	elseif Menu.achat == true then
		pasterino = GetClipboardText()
		if pasterino ~= nil then
			SendChat('/all '..pasterino)
		else 
			PrintChat('Please Copy something into the Clipboard')
		end
	end
end
