-- @description Toggle float instrument on track under mouse cursor
-- @version 1.01
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @changelog
--    # ReaPack header


  script_title = "Toggle float instrument on track under mouse cursor"
reaper.Undo_BeginBlock()

window, segment, details = reaper.BR_GetMouseCursorContext()
if segment == "track" then
  track = reaper.BR_GetMouseCursorContext_Track()
  if track ~= nil then
    vsti_id = reaper.TrackFX_GetInstrument(track)
    if vsti_id ~= -1 then    
      is_float = reaper.TrackFX_GetOpen(track, vsti_id)
      if is_float == false then
         reaper.TrackFX_Show(track, vsti_id, 3)
       else
         reaper.TrackFX_Show(track, vsti_id, 2)
      end
     else
      reaper.Main_OnCommandEx(40271, 0, 0) -- show fx browser
    end   
  end
end

reaper.UpdateArrange()
reaper.Undo_EndBlock(script_title, 0)