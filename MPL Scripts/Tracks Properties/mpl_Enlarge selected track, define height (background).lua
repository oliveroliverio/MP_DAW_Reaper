-- @description Enlarge selected track, define height
-- @version 1.0
-- @author MPL
-- @changelog
--    + init / recode from cubic13 idea
-- @website http://forum.cockos.com/member.php?u=70694

  
  height = 250  -- pixels


--  original cubic13 idea http://forum.cockos.com/showthread.php?t=145949  
  function EnlargeSelTrack()
    track = reaper.GetSelectedTrack(0, 0)
    if track then  
      track_guid = reaper.GetTrackGUID( track )
      if h_last and last_track_guid and last_track_guid ~= track_guid then 
        h_cur_last = reaper.GetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE")
        reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", height)--h_last) 
        if h_cur_last and last_track_guid then
          last_tr = reaper.BR_GetMediaTrackByGUID( 0, last_track_guid )
          if last_tr then reaper.SetMediaTrackInfo_Value(last_tr, "I_HEIGHTOVERRIDE", h_cur_last) end
        end
        reaper.TrackList_AdjustWindows( false )
        reaper.UpdateArrange()
      end
      h_cur = reaper.GetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE")
      h_last = h_cur
      last_track_guid = track_guid
    end
    reaper.runloop(EnlargeSelTrack)
  end
  
  EnlargeSelTrack()
