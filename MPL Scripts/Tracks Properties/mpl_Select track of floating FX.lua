-- @description Select track of floating FX
-- @version 1.01
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
-- @changelog
--   # proper parse track ID


  function main()
    retval, tracknumberOut = reaper.GetFocusedFX()
    if retval < 1 then return end
    local tr = reaper.GetTrack( 0, tracknumberOut-1 )
    if tracknumberOut == 0 then tr =  reaper.GetMasterTrack( 0 ) end
    if tr then reaper.SetOnlyTrackSelected( tr  ) end
  end
  
  main()