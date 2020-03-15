-- @description Various_functions
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @about Functions for using with some MPL scripts. It is strongly recommended to have it installed for future updates.
-- @version 1.26
-- @changelog
--    + VF_GetTrackUnderMouseCursor
--    + VF_GetItemTakeUnderMouseCursor
--    + VF_GetPositionUnderMouseCursor -- SWS заглушка
--    + VF_GetEnvelopeUnderMouseCursor -- SWS заглушка

  for key in pairs(reaper) do _G[key]=reaper[key]  end 
  function msg(s) 
    if not s then return end 
    if type(s) == 'boolean' then
      if s then s = 'true' else  s = 'false' end
    end
    ShowConsoleMsg(s..'\n') 
  end 
  ---------------------------------------------------
  function VF_GetTrackByGUID(giv_guid)
    for i = 1, CountTracks(0) do
      local tr = GetTrack(0,i-1)
      local GUID = reaper.GetTrackGUID( tr )
      if GUID == giv_guid then return tr end
    end
  end
  ---------------------------------------------------
  function VF_GetFXByGUID(GUID, tr)
    if not tr then
      for trid = 1, CountTracks(0) do
        local tr = GetTrack(0,trid-1)
        for fx_id =1, TrackFX_GetCount( tr ) do
          if TrackFX_GetFXGUID( tr, fx_id-1) == GUID then return true, tr, fx_id-1 end
        end
      end  
     else
      for fx_id =1, TrackFX_GetCount( tr ) do
        if TrackFX_GetFXGUID( tr, fx_id-1) == GUID then return true, tr, fx_id-1 end
      end
    end    
  end
  ---------------------------------------------------
  function VF_CalibrateFont(sz) -- https://forum.cockos.com/showpost.php?p=2066576&postcount=17
   local t = { [13]=80,
                [15]=90,
                [19]=110,
                [21]=150} -- windows measured
    gfx.setfont(1, 'Calibri', sz)    
    local str_width, str_height = gfx.measurestr("MMMMMMMMMM")
    local font_factor = t[sz]/str_width
    return math.floor(sz*font_factor)
  end 
  ---------------------------------------------------
  function VF_CheckReaperVrs(rvrs, showmsg) 
    local vrs_num =  GetAppVersion()
    vrs_num = tonumber(vrs_num:match('[%d%.]+'))
    if rvrs > vrs_num then 
      if showmsg then reaper.MB('Update REAPER to newer version '..'('..rvrs..' or newer)', '', 0) end
      return
     else
      return true
    end
  end
  ---------------------------------------------------
  function VF_GetFormattedGrid(grid_div)
    local grid_flags, grid_division, grid_swingmode, grid_swingamt 
    if not grid_div then 
      grid_flags, grid_division, grid_swingmode, grid_swingamt  = GetSetProjectGrid( 0, false )
     else 
      grid_flags, grid_division, grid_swingmode, grid_swingamt = 0,grid_div,0,0
    end
    local is_triplet
    local denom = 1/grid_division
    local grid_str
    if denom >=2 then 
      is_triplet = (1/grid_division) % 3 == 0 
      grid_str = '1/'..math.floor(denom)
      if is_triplet then grid_str = '1/'..math.floor(denom*2/3) end
     else 
      grid_str = 1
      is_triplet = math.abs(grid_division - 0.6666) < 0.001
    end
    local grid_swingamt_format = math.floor(grid_swingamt * 100)..'%'
    return grid_division, grid_str, is_triplet, grid_swingmode, grid_swingamt, grid_swingamt_format
  end     
  
  ------------------------------------------------------------------------------------------------------
  function getKeysSortedByValue(tbl, sortFunction, param) -- https://stackoverflow.com/questions/2038418/associatively-sorting-a-table-by-value-in-lua
    local keys = {}
    for key in pairs(tbl) do table.insert(keys, key) end  
    table.sort(keys, function(a, b) return sortFunction(tbl[a][param], tbl[b][param])  end)  
    return keys
  end  

  ------------------------------------------------------------------------------------------------------
  function eugen27771_GetObjStateChunk(obj)
    
    local vrs_num =  GetAppVersion()
    vrs_num = tonumber(vrs_num:match('[%d%.]+'))
    if vrs_num >= 5.93 then 
      if  ValidatePtr2( 0, obj, 'MediaTrack*' ) then
        local retval, chunk = GetTrackStateChunk( obj, '', false )
        return chunk
      end
     else
      if not obj then return end
      local fast_str, chunk
      fast_str = SNM_CreateFastString("")
      if SNM_GetSetObjectState(obj, fast_str, false, false) then chunk = SNM_GetFastString(fast_str) end
      SNM_DeleteFastString(fast_str)  
      return chunk    
    end
    
  end 
  ------------------------------------------------------------------------------------------------------
  function literalize(str) -- http://stackoverflow.com/questions/1745448/lua-plain-string-gsub
     if str then  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end) end
  end  
  ------------------------------------------------------------------------------------------------------
  function deliteralize(str) 
     if str then  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", '') end
  end  
  ------------------------------------------------------------------------------------------------------
  function lim(val, min,max) --local min,max 
    if not min or not max then min, max = 0,1 end 
    return math.max(min,  math.min(val, max) ) 
  end
  ---------------------------------------------------
  function CopyTable(orig)--http://lua-users.org/wiki/CopyTable
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in next, orig, nil do
              copy[CopyTable(orig_key)] = CopyTable(orig_value)
          end
          setmetatable(copy, CopyTable(getmetatable(orig)))
      else -- number, string, boolean, etc
          copy = orig
      end
      return copy
  end 
-----------------------------------------------------------------------    
 function Open_URL(url) if GetOS():match("OSX") then os.execute('open "" '.. url) else os.execute('start "" '.. url)  end  end  
  ------------------------------------------------------------------------------------------------------
  function WDL_DB2VAL(x) return math.exp((x)*0.11512925464970228420089957273422) end  --https://github.com/majek/wdl/blob/master/WDL/db2val.h
  --function dBFromVal(val) if val < 0.5 then return 20*math.log(val*2, 10) else return (val*12-6) end end
  ------------------------------------------------------------------------------------------------------
  function WDL_VAL2DB(x, reduce)   --https://github.com/majek/wdl/blob/master/WDL/db2val.h
    if not x or x < 0.0000000298023223876953125 then return -150.0 end
    local v=math.log(x)*8.6858896380650365530225783783321
    if v<-150.0 then return -150.0 else 
      if reduce then 
        return string.format('%.2f', v)
       else 
        return v 
      end
    end
  end
  ------------------------------------------------------------------------------------------------------
  function GetSpectralData(item)
    --[[
    {table}
      {takeID}
        {edits}
          {editID = 
            param = value}
    ]]
    if not item then return end
    local chunk = ({GetItemStateChunk( item, '', false )})[2]
    -- parse chunk
    local tk_cnt = 0
    local SE ={}
    for line in chunk:gmatch('[^\r\n]+') do 
    
      if line:match('<SOURCE') then 
        tk_cnt =  tk_cnt +1 
        SE[tk_cnt]= {}
      end 
        
      if line:match('SPECTRAL_CONFIG') then
        local sz = line:match('SPECTRAL_CONFIG ([%d]+)')
        if sz then sz = tonumber(sz) end
        SE[tk_cnt].FFT_sz = sz
      end
            
      if line:match('SPECTRAL_EDIT') then  
        if not SE[tk_cnt].edits then SE[tk_cnt].edits = {} end
        local tnum = {} 
        for num in line:gmatch('[^%s]+') do if tonumber(num) then tnum[#tnum+1] = tonumber(num) end end
        
        local take = GetMediaItemTake( item, tk_cnt-1 )
        local s_offs = GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS'  )
        local rate = GetMediaItemTakeInfo_Value( take, 'D_PLAYRATE'  ) 
        

            
        SE[tk_cnt].edits [#SE[tk_cnt].edits+1] =       {pos = (tnum[1] - s_offs)/rate,
                       len = tnum[2]/rate,
                       gain = tnum[3],
                       fadeinout_horiz = tnum[4], -- knobleft/2 + knobright/2
                       fadeinout_vert = tnum[5], -- knoblower/2 + knobupper/2
                       freq_low = tnum[6],
                       freq_high = tnum[7],
                       chan = tnum[8], -- -1 all 0 L 1 R
                       bypass = tnum[9], -- bypass&1 solo&2
                       gate_threshold = tnum[10],
                       gate_floor = tnum[11],
                       compress_threshold = tnum[12],
                       compress_ratio = tnum[13],
                       unknown1 = tnum[14],
                       unknown2 = tnum[15],
                       fadeinout_horiz2 = tnum[16],  -- knobright - knobleft
                       fadeinout_vert2 = tnum[17],
                       chunk_str = line} -- knobupper - knoblower
      end
                       
    end
    return true, SE
  end
  ------------------------------------------------------------------------------------------------------
  function SetSpectralData(item, data, apply_chunk)
    --[[
    {table}
      {takeID}
        {edits}
          {editID = 
            param = value}
    ]]  
    if not item then return end
    local chunk = ({GetItemStateChunk( item, '', false )})[2]
    chunk = chunk:gsub('SPECTRAL_CONFIG.-\n', '')
    chunk = chunk:gsub('SPECTRAL_EDIT.-\n', '')
    local open
    local t = {} 
    for line in chunk:gmatch('[^\r\n]+') do t[#t+1] = line end
    local tk_cnt = 0 
    for i = 1, #t do
      if t[i]:match('<SOURCE') then 
        tk_cnt = tk_cnt + 1 
        open = true 
      end
      if open and t[i]:match('>') then
      
        local add_str = ''
        local take  =GetTake( item, tk_cnt-1 )
        if data[tk_cnt] 
          and data[tk_cnt].edits 
          and take
          and not TakeIsMIDI(take)
          then
          for edit_id in pairs(data[tk_cnt].edits) do
            if not data[tk_cnt].FFT_sz then data[tk_cnt].FFT_sz = 1024 end
            local s_offs = GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS'  )
            local rate = GetMediaItemTakeInfo_Value( take, 'D_PLAYRATE'  ) 
            if not apply_chunk then
              add_str = add_str..'SPECTRAL_EDIT '
                ..data[tk_cnt].edits[edit_id].pos*rate + s_offs..' '
                ..data[tk_cnt].edits[edit_id].len*rate..' '
                ..data[tk_cnt].edits[edit_id].gain..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_horiz..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_vert..' '
                ..data[tk_cnt].edits[edit_id].freq_low..' '
                ..data[tk_cnt].edits[edit_id].freq_high..' '
                ..data[tk_cnt].edits[edit_id].chan..' '
                ..data[tk_cnt].edits[edit_id].bypass..' '
                ..data[tk_cnt].edits[edit_id].gate_threshold..' '
                ..data[tk_cnt].edits[edit_id].gate_floor..' '
                ..data[tk_cnt].edits[edit_id].compress_threshold..' '
                ..data[tk_cnt].edits[edit_id].compress_ratio..' '
                ..data[tk_cnt].edits[edit_id].unknown1..' '
                ..data[tk_cnt].edits[edit_id].unknown2..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_horiz2..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_vert2..' '
                ..'\n'
              add_str = add_str..'SPECTRAL_CONFIG '..data[tk_cnt].FFT_sz ..'\n'
             else
              add_str = apply_chunk..'\nSPECTRAL_CONFIG '..data[tk_cnt].FFT_sz ..'\n'
            end
          end        
        end
        
        t[i] = t[i]..'\n'..add_str
        open = false
      end
    end   
    
    local out_chunk = table.concat(t, '\n')
    --ClearConsole()
    --msg(out_chunk)
    SetItemStateChunk( item, out_chunk, false )
    UpdateItemInProject( item )
  end
  ---------------------------------------------------
  function spairs(t, order) --http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then table.sort(keys, function(a,b) return order(t, a, b) end)  else  table.sort(keys) end
    local i = 0
    return function()
              i = i + 1
              if keys[i] then return keys[i], t[keys[i]] end
           end
  end
  ---------------------------------------------------
  function ExtState_Load(conf)
    local def = ExtState_Def()
    for key in pairs(def) do 
      local es_str = GetExtState(def.ES_key, key)
      if es_str == '' then conf[key] = def[key] else conf[key] = tonumber(es_str) or es_str end
    end    
  end  
  ---------------------------------------------------
  function ExtState_Save(conf)
    conf.dock , conf.wind_x, conf.wind_y, conf.wind_w, conf.wind_h= gfx.dock(-1, 0,0,0,0)
    for key in pairs(conf) do SetExtState(conf.ES_key, key, conf[key], true)  end
    --for k,v in spairs(conf, function(t,a,b) return b:lower() > a:lower() end) do SetExtState(conf.ES_key, k, conf[k], true) end  
  end
  ---------------------------------------------------------------------------------------------------------------------
  function NormalizeT(t, key)
    local m = 0 
    for i = 1, #t do 
      if not key then 
        m = math.max(math.abs(t[i]),m) 
       else
        m = math.max(math.abs(t[i][key]),m) 
      end
    end
    for i = 1, #t do 
      if not key then
        t[i] = t[i] / m 
       else 
        t[i][key] = t[i][key] / m 
      end
    end
  end 
  ---------------------------------------------------------------------------------------------------------------------
  function ScaleT(t, scaling)
    for i =1, #t do t[i]= t[i]^scaling end
  end   
  ---------------------------------------------------------------------------------------------------------------------
  function SmoothT(t, smooth)
    for i = 2, #t do t[i]= t[i] - (t[i] - t[i-1])*smooth   end
  end  
  ---------------------------------------------------------------------------------------------------------------------
  function GetParentFolder(dir) return dir:match('(.*)[%\\/]') end
  ---------------------------------------------------------------------------------------------------------------------
  function GetShortSmplName(path) 
    local fn = path
    fn = fn:gsub('%\\','/')
    if fn then fn = fn:reverse():match('(.-)/') end
    if fn then fn = fn:reverse() end
    return fn
  end  
  ---------------------------------------------------------------------------------------------------------------------   
    function GetNoteStr(conf, val, mode)  -- conf.key_names
      local oct_shift = -1
      if conf.oct_shift then oct_shift = conf.oct_shift end
      local int_mode
      if mode then int_mode = mode else int_mode = conf.key_names end
      if int_mode == 0 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end
       elseif int_mode == 1 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'D♭', 'D', 'E♭', 'E', 'F', 'G♭', 'G', 'A♭', 'A', 'B♭', 'B',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end  
       elseif int_mode == 2 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end      
       elseif int_mode == 3 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'Do', 'Re♭', 'Re', 'Mi♭', 'Mi', 'Fa', 'Sol♭', 'Sol', 'La♭', 'La', 'Si♭', 'Si',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end       
       elseif int_mode == 4 -- midi pitch
        then return val, 'MIDI pitch'
       elseif int_mode == 5 -- freq
        then return math.floor(440 * 2 ^ ( (val - 69) / 12))..'Hz'
       elseif int_mode == 6 -- empty
        then return '', 'Nothing'
       elseif int_mode == 7 then -- ru
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'До', 'До#', 'Ре', 'Ре#', 'Ми', 'Фа', 'Фа#', 'Соль', 'Соль#', 'Ля', 'Ля#', 'Си'}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift,
                                                          'keys (RU) + octave' end  
       elseif int_mode == 8 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',}
        if note and oct and key_names[note+1] then 
          return key_names[note+1]..oct+oct_shift..'\n'..val,
                  'keys + octave + MIDI pitch'
        end              
      end
    end
  ---------------------------------------------------------------------------------------------------------------------
    function math_q(num)  if math.abs(num - math.floor(num)) < math.abs(num - math.ceil(num)) then return math.floor(num) else return math.ceil(num) end end
  ---------------------------------------------------------------------------------------------------------------------
    function math_q_dec(num, pow) return math.floor(num * 10^pow) / 10^pow end
  -------------------------------------------------------------------------------   
  function ExportSelItemsToRs5k_FormMIDItake_data()
    local MIDI = {}
    -- check for same track/get items info
      local item = reaper.GetSelectedMediaItem(0,0)
      if not item then return end
      MIDI.it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
      MIDI.it_end_pos = MIDI.it_pos + 0.1
      local proceed_MIDI = true
      local it_tr0 = reaper.GetMediaItemTrack( item )
      for i = 1, reaper.CountSelectedMediaItems(0) do
        local item = reaper.GetSelectedMediaItem(0,i-1)
        local it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
        local it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
        MIDI[#MIDI+1] = {pos=it_pos, end_pos = it_pos+it_len}
        MIDI.it_end_pos = it_pos + it_len
        local it_tr = reaper.GetMediaItemTrack( item )
        if it_tr ~= it_tr0 then proceed_MIDI = false break end
      end
      
    return proceed_MIDI, MIDI
  end
  -------------------------------------------------------------------------------    
  function ExportSelItemsToRs5k_AddMIDI(track, MIDI, base_pitch)    
    if not MIDI then return end
      local new_it = reaper.CreateNewMIDIItemInProj( track, MIDI.it_pos, MIDI.it_end_pos )
      local new_tk = reaper.GetActiveTake( new_it )
      for i = 1, #MIDI do
        local startppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].pos )
        local endppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].end_pos )
        local ret = reaper.MIDI_InsertNote( new_tk, 
            false, --selected, 
            false, --muted, 
            startppqpos, 
            endppqpos, 
            0, 
            base_pitch+i-1, 
            100, 
            true)--noSortInOptional )
          --if ret then reaper.ShowConsoleMsg('done') end
      end
      reaper.MIDI_Sort( new_tk )
      reaper.GetSetMediaItemTakeInfo_String( new_tk, 'P_NAME', 'sliced loop', 1 )
      reaper.UpdateArrange()    
  end
  -------------------------------------------------------------------------------     
  function FloatInstrument(track)
    local vsti_id = TrackFX_GetInstrument(track)
    if vsti_id and vsti_id >= 0 then 
      TrackFX_Show(track, vsti_id, 3) -- float
      return true
    end
  end
  ---------------------------------------------------------------------
    function ApplyFunctionToTrackInTree(track, func) -- function return true stop search
      -- search tree
        local parent_track, ret2, ret3
        local track2 = track
        repeat
          parent_track = reaper.GetParentTrack(track2)
          if parent_track ~= nil then
            ret2 = func(parent_track )
            if ret2 then return end
            track2 = parent_track
          end
        until parent_track == nil    
        
      -- search sends
        local cnt_sends = GetTrackNumSends( track, 0)
        for sendidx = 1,  cnt_sends do
          dest_tr = BR_GetMediaTrackSendInfo_Track( track, 0, sendidx-1, 1 )
          ret3 = func(dest_tr )
          if ret3 then return  end
        end
    end
    ----------------------------------------------------------------------- 
    function GetInput( conf, captions_csv, retvals_csv,floor, linew, is_string)
      if linew and tonumber(linew) then captions_csv = captions_csv..',extrawidth='..math.floor(linew) end
      local ret, str =  GetUserInputs( conf.scr_title, 1, captions_csv, retvals_csv )
      if not ret then return end
      
      if not is_string then 
        if not tonumber(str) then return end
        local out = tonumber(str)
        if floor then out = math.floor(out) end
        return out
       else
        return str
      end
      
    end
    -----------------------------------------------------------
    function BinaryCheck(value, byte_id, bool_int)
      local byte_num = 1<<byte_id
      
      if value&byte_num == byte_num then 
        if not bool_int or (bool_int and bool_int == 1) then value = value - byte_num end
       else 
        if not bool_int or (bool_int and bool_int == 0) then value = value + byte_num end
      end
      return value
    end  
    -----------------------------------------------------------
    function BinaryToggle(value, byte_id, bool_int)
      local byte_num = 1<<byte_id
      
      if value&byte_num == byte_num then 
        if not bool_int or (bool_int and bool_int == 0) then value = value - byte_num end
       else 
        if not bool_int or (bool_int and bool_int == 1) then value = value + byte_num end
      end
      return value
    end  
    -----------------------------------------------------------
    function gfx_ColHex(hex_str) -- https://gist.github.com/jasonbradley/4357406
        local hex = hex_str:gsub("#","")
        local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
        if GetOS():match('Win') then gfx.set(r/255,g/255,b/255) else gfx.set(b/255,g/255,r/255)     end        
    end
  -----------------------------------------------------------------------
  function SetFXName(track, fx, new_name)
    if not new_name then return end
    local edited_line,edited_line_id, segm
    -- get ref guid
      if not track or not tonumber(fx) then return end
      local FX_GUID = reaper.TrackFX_GetFXGUID( track, fx )
      if not FX_GUID then return else FX_GUID = FX_GUID:gsub('-',''):sub(2,-2) end
      local plug_type = reaper.TrackFX_GetIOSize( track, fx )
    -- get chunk t
      local chunk = eugen27771_GetObjStateChunk( track)
      local t = {} for line in chunk:gmatch("[^\r\n]+") do t[#t+1] = line end
    -- find edit line
      local search
      for i = #t, 1, -1 do
        local t_check = t[i]:gsub('-','')
        if t_check:find(FX_GUID) then search = true  end
        if t[i]:find('<') and search and not t[i]:find('JS_SER') then
          edited_line = t[i]:sub(2)
          edited_line_id = i
          break
        end
      end
    -- parse line
      if not edited_line then return end
      local t1 = {}
      for word in edited_line:gmatch('[%S]+') do t1[#t1+1] = word end
      local t2 = {}
      for i = 1, #t1 do
        segm = t1[i]
        if not q then t2[#t2+1] = segm else t2[#t2] = t2[#t2]..' '..segm end
        if segm:find('"') and not segm:find('""') then if not q then q = true else q = nil end end
      end
  
      if plug_type == 2 then t2[3] = '"'..new_name..'"' end -- if JS
      if plug_type == 3 then t2[5] = '"'..new_name..'"' end -- if VST
  
      local out_line = table.concat(t2,' ')
      t[edited_line_id] = '<'..out_line
      local out_chunk = table.concat(t,'\n')
      --msg(out_chunk)
      reaper.SetTrackStateChunk( track, out_chunk, false )
  end 
  ----------------------------------------------------------------------
  function HasWindXYWHChanged(obj)  
    local  dock, wx,wy,ww,wh = gfx.dock(-1, 0,0,0,0)
    local retval=0
    if not obj.last_gfxx 
        or not obj.last_gfxy 
        or not obj.last_gfxw 
        or not obj.last_gfxh 
        or not obj.last_dock then 
        obj.last_gfxx, obj.last_gfxy, obj.last_gfxw, obj.last_gfxh, obj.last_dock = wx,wy,ww,wh, dock
        return -1 
    end
    if wx ~= obj.last_gfxx or wy ~= obj.last_gfxy then retval= 2 end --- minor
    if ww ~= obj.last_gfxw or wh ~= obj.last_gfxh or dock ~= obj.last_dock then retval= 1 end --- major
    obj.last_gfxx, obj.last_gfxy, obj.last_gfxw, obj.last_gfxh, obj.last_dock = wx,wy,ww,wh,dock
    return retval
  end
  ---------------------------------------------------
  function Menu(mouse, t)
    local str, check ,hidden= '', '',''
    for i = 1, #t do
      if t[i].state then check = '!' else check ='' end
      if t[i].hidden then hidden = '#' else hidden ='' end
      local add_str = hidden..check..t[i].str 
      str = str..add_str
      str = str..'|'
    end
    gfx.x = mouse.x
    gfx.y = mouse.y
    local ret = gfx.showmenu(str)
    local incr = 0
    if ret > 0 then 
      for i = 1, ret do 
        if t[i+incr].menu_decr == true then incr = incr - 1 end
        if t[i+incr].str:match('>') then incr = incr + 1 end
        if t[i+incr].menu_inc then incr = incr + 1 end
      end
      if t[ret+incr] and t[ret+incr].func then t[ret+incr].func() end 
     --- msg(t[ret+incr].str)
    end
  end  
  ---------------------------------------------------
  function MPL_ReduceFXname(s)
    local s_out = s:match('[%:%/%s]+(.*)')
    if not s_out then return s end
    s_out = s_out:gsub('%(.-%)','') 
    --if s_out:match('%/(.*)') then s_out = s_out:match('%/(.*)') end
    local pat_js = '.*[%/](.*)'
    if s_out:match(pat_js) then s_out = s_out:match(pat_js) end  
    if not s_out then return s else 
      if s_out ~= '' then return s_out else return s end
    end
  end
  ---------------------------------------------------
  function Action(s) Main_OnCommand(NamedCommandLookup(s), 0) end
  ---------------------------------------------------
  function VF_GetTrackUnderMouseCursor()
    local screen_x, screen_y = GetMousePosition()
    local retval, info = reaper.GetTrackFromPoint( screen_x, screen_y )
    return retval
  end
  ---------------------------------------------------
  function VF_GetItemTakeUnderMouseCursor()
    local screen_x, screen_y = GetMousePosition()
    local item , take = reaper.GetItemFromPoint( screen_x, screen_y, true )
    return item , take
  end
  --------------------------------------------------
  function VF_GetPositionUnderMouseCursor()
    BR_GetMouseCursorContext()
    return  BR_GetMouseCursorContext_Position()
  end
  --------------------------------------------------
  function VF_GetEnvelopeUnderMouseCursor()
    reaper.BR_GetMouseCursorContext()
    return  BR_GetMouseCursorContext_Envelope()
  end  
