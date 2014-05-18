--[[
Removed ASCI art work temp
This script must be used along side with "Fast Strategic Start.exe"
http://botoflegends.com/forum/topic/19526-fssfast-strategic-start/]]


local version = "1.02"
local CheckForUpdates = true
local UPDATE_HOST = 'bitbucket.org'
local UPDATE_PATH = '/andreluis034/andrerepo/raw/master/FastStrategyStart.lua?rand='..math.random(1,10000) -- 'Disable' caching to prevent older versions from being retrieved
local UPDATE_FILE_PATH = SCRIPT_PATH..'FastStrategyStart.lua'
local UPDATE_URL = 'https://'..UPDATE_HOST..UPDATE_PATH
local ServerData
local FSS = {}
local PATH = os.getenv('APPDATA')..'\\Bol\\FSS.txt'
local BoughtAtLeast1item = false
local team
local DelayLimit = 0
local Boughtitem = true
local itexists = true
local warned = false
local fileExists = false
local mapindex = GetGame().map.index
	if tostring(myHero.team) == "100" then
		team = "blue"
	else
		team = "red"
	end
if FileExist(PATH) then 
	fileExists = true
	FSS = dofile(PATH)
	--print(FSS)
	if FSS.team ~= team and not FSS.team == "river" then
		PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>Would move into enemy territory, not moving.")
		os.remove(PATH)
		return 
	end
	if FSS.mapindex ~= mapindex then
		PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>Wrong map selected.")
		os.remove(PATH)
		return 
	end
else
	PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>Script must run along side with \"Fast Strategic Start.exe\"")
	return
end

function OnLoad()
	CheckUpdates()
	FSS = dofile(PATH)
	--print(FSS)
	print(#FSS)
	print(#FSS.Items)
	os.remove(PATH)
	BuyDelay = tonumber(FSS.Delay)
	Script()
end

function Script()

	if FSS.Spell == (_Q or _W or _E or _R) then
		LevelSpell(FSS.Spell)
	else
		PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>No skill leveled up")
	end

	DelayAction(
function()
	if BoughtAtLeast1item then
		if FSS.team == team or FSS.team == "river" then
			myHero:MoveTo(FSS.X, FSS.Z)
		else
			PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'> Would move into enemy territory, not moving.")
		end
	else
		PrintChat("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'> No items bought, not moving.")
	end
end, BuyDelay*5)

end
function OnTick()
	if os.clock() - DelayLimit > BuyDelay then
		DelayLimit = os.clock()
		math.randomseed(os.time())
		--print(BuyDelay)
		BuyDelay = math.random(tonumber(FSS.Delay)-0.05, tonumber(FSS.Delay)+0.05)
		
		Boughtitem = false
		BuyItems()
	end
end

function BuyItems()
	for i, item in pairs(FSS.Items) do	
		if item ~= nil then
			if not Boughtitem then
				if myHero.charName == "Rengar" then
					if item == 3340 then
						BuyItem(3166)
						FSS.Items[i] = nil
					elseif item == 3341 then 
						BuyItem(3405)
						FSS.Items[i] = nil
					elseif item == 3342 then
						BuyItem(3411)
						FSS.Items[i] = nil
					else
						BuyItem(item)
						FSS.Items[i] = nil
					end
				else
					--print(item)
					BuyItem(item)
					FSS.Items[i] = nil
				end
				Boughtitem = true
				BoughtAtLeast1item = true
			end
		end
	end
end



function CheckUpdates()
	if CheckForUpdates then
		GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH, function(d) ServerData = d end)
		DelayAction(DelayedUpdate, 3)
	end
end

function DelayedUpdate()
	if ServerData ~= nil then
		local ServerVersion
		local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
		if sstart then
			send, tmp = string.find(ServerData, "\"", sstart+1)
		end
		if send then
			ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
		end
		if ServerVersion and ServerVersion > tonumber(version) then
			DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () print("<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\"#F8F8F8\"> Successfully updated. Please reload script(double F9). ("..version.." => "..ServerVersion..")<font color=\'#FF0000\'><b> Please download new program manually.</font></b>") end)     
		elseif ServerVersion then
			print('<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>You have got the latest version: <b>'..version..'</b></font>')
		else
			print('<font color=\'#00DD00\'><b>Fast Strategic Start: </b><font color=\'#F8F8F8\'>Check for updates failed. Please check thread.</b></font>')
		end		
		ServerData = nil
	end
end
