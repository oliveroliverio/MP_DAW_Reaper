-- @description Bypass all UAD FX on all tracks
-- @version 1.11
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @changelog
--    # ReaPack header, name  
  
  script_title = "Bypass all UAD FX on all tracks"
  reaper.Undo_BeginBlock()
  
  plug_name = "UAD"
  enable = true
  
  trackcount = reaper.CountTracks(0)
  if trackcount ~= nil then
    for i = 1, trackcount do
      track = reaper.GetTrack(0,i-1)
      fx_count = reaper.TrackFX_GetCount(track)
      if fx_count ~= nil then
        for j = 1, fx_count do
          retval, fx_name = reaper.TrackFX_GetFXName(track, j-1, "")
          if string.find(fx_name, plug_name) ~= nil then
            reaper.TrackFX_SetEnabled(track, j-1, enable)
          end
        end
      end  
    end
  end 
  
  track = reaper.GetMasterTrack(0)
    fx_count = reaper.TrackFX_GetCount(track)
    if fx_count ~= nil then
      for j = 1, fx_count do
        retval, fx_name = reaper.TrackFX_GetFXName(track, j-1, "")
        if string.find(fx_name, plug_name) ~= nil then
          reaper.TrackFX_SetEnabled(track, j-1, enable)
        end
      end
    end  
  reaper.Undo_EndBlock(script_title, 0)