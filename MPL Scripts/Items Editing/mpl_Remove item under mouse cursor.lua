-- @description Remove item under mouse cursor
-- @version 1.02
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @changelog
--   # update for use with REAPER 5.981+


  function main()  
    item = VF_GetItemTakeUnderMouseCursor()
    if item then reaper.DeleteTrackMediaItem( GetMediaItem_Track( item ), item) reaper.UpdateArrange() end
  end

---------------------------------------------------------------------
  function CheckFunctions(str_func) local SEfunc_path = reaper.GetResourcePath()..'/Scripts/MPL Scripts/Functions/mpl_Various_functions.lua' local f = io.open(SEfunc_path, 'r')  if f then f:close() dofile(SEfunc_path) if not _G[str_func] then  reaper.MB('Update '..SEfunc_path:gsub('%\\', '/')..' to newer version', '', 0) else return true end  else reaper.MB(SEfunc_path:gsub('%\\', '/')..' missing', '', 0) end   end

--------------------------------------------------------------------  
  local ret = CheckFunctions('VF_GetItemTakeUnderMouseCursor') 
  local ret2 = VF_CheckReaperVrs(5.95,true)    
  if ret and ret2 then 
    script_title = "Remove item under mouse cursor"
    reaper.Undo_BeginBlock() 
    main()
    reaper.Undo_EndBlock(script_title, 0)
  end    

