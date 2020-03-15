function main()

	getTrack()
	getEnv()

	reaper.Main_onCommandEx(40297,0,0)
	reaper.SetTrackSelected(selTrack, true)
	reapder.Main_onCommanEx(40421,0,0)

	local itemCount = reaper.CountSelectedMediaItems(0)

	for i=0, itemCount-1 do
		local selItem = reaper.GetSelectedMediaItem(0,i)
		local iPos = reaper.GetSelectedMediaItemInfo_Value(selItem, "D_POSITION")
		reaper.ShowConsoleMsg(iPos .. "\n")

	end 
end


function getTrack()
	selTrack = reaper.GetSelectedTrack(0,0)
	if not selTrack then
		reaper.ShowMessageBox("Please select a track!", "Error", 0)
	end
end

function getEnv()
	--gets envelope items
	selEnv = reaper.GetSelectedEnvelope(0)
	if not selEnv then
		reaper.ShowMessageBox("please select envelop", "Error",0) 

	end
end

main()
