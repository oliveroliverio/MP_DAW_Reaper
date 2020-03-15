function main()

  getTrack()

  reaper.Main_OnCommandEx(40297,0,0)
  reaper.SetTrackSelected(selTrack, true)
  reaper.Main_OnCommandEx(40421,0,0)

  local itemCount = reaper.CountSelectedMediaItems(0)

  -- loop through selected media items
  for i=0, itemCount-1 do
    local selItem = reaper.GetSelectedMediaItem(0,i)
    local iPos = reaper.GetMediaItemInfo_Value(selItem, "D_POSITION")
    reaper.ShowConsoleMsg(iPos .. "\n")

  end 
end


function getTrack()
  selTrack = reaper.GetSelectedTrack(0,0)
  -- if track not selected, throw error
  if not selTrack then
    reaper.ShowMessageBox("Please select a track!", "Error", 0)
  end
end

main()
