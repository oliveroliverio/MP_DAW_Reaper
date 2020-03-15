-- @version 1.0
-- @author MPL
-- @description Float s(M)exoscope on master channel
-- @website http://forum.cockos.com/member.php?u=70694
-- @changelog
--   + init

function main()
  id =  reaper.TrackFX_GetByName( reaper.GetMasterTrack(), 's(M)exoscope', true )
  if id >= 0 then reaper.TrackFX_Show( reaper.GetMasterTrack(), id, 3 ) end
end

reaper.defer(main)