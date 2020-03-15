--[[
   * ReaScript Name: Move take content under stretch markers 10ms left
   * Lua script for Cockos REAPER
   * Author: MPL
   * Author URI: http://forum.cockos.com/member.php?u=70694
   * Licence: GPL v3
   * Version: 1.0
  ]]
  
script_title = "Move take content under stretch markers 10ms left"
delta = 0.01

reaper.Undo_BeginBlock()

item = reaper.GetSelectedMediaItem(0, 0)   
if item ~= nil then
  itempos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  reaper.SetMediaItemInfo_Value(item, "D_POSITION", itempos+delta)
  take = reaper.GetActiveTake(item)
  if take ~= nil then
    str_markers_count = reaper.GetTakeNumStretchMarkers(take) 
    if str_markers_count ~= nil then
      for i = 1, str_markers_count, 1 do
       retval, pos, srcpos = reaper.GetTakeStretchMarker(take, i-1)
       reaper.SetTakeStretchMarker(take, i-1, pos-delta, srcpos-delta)
      end
    end 
  end 
  reaper.UpdateItemInProject(item)
end  
reaper.Undo_EndBlock(script_title, 0)
