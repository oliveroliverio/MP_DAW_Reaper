-- @description QuantizeTool_obj
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @noindex
  
  
  ---------------------------------------------------
  function OBJ_init(obj)  
    -- globals
    obj.reapervrs = tonumber(GetAppVersion():match('[%d%.]+')) 
    obj.offs = 5 
    obj.grad_sz = 200 
    
    obj.strategy_frame = 0
     
     
    -- font
    obj.GUI_font = 'Calibri'
    obj.GUI_fontsz = VF_CalibrateFont(21)
    obj.GUI_fontsz2 = VF_CalibrateFont( 19)
    obj.GUI_fontsz3 = VF_CalibrateFont( 15)
    obj.GUI_fontsz_tooltip = VF_CalibrateFont( 13)
    
    -- colors    
    obj.GUIcol = { grey =    {0.5, 0.5,  0.5 },
                   white =   {1,   1,    1   },
                   red =     {0.85,   0.35,    0.37   },
                   green =   {0.35,   0.75,    0.45   },
                   green_marker =   {0.2,   0.6,    0.2   },
                   blue =   {0.35,   0.55,    0.85   },
                   blue_marker =   {0.2,   0.5,    0.8   },
                   black =   {0,0,0 }
                   }    
    
  end
  ---------------------------------------------------
  function OBJ_Update(conf, obj, data, refresh, mouse, strategy) 
    for key in pairs(obj) do if type(obj[key]) == 'table' and obj[key].clear then obj[key] = {} end end  
    
    local min_w = 300
    local min_h = 200
    local reduced_view = gfx.h  <= min_h
    gfx.w  = math.max(min_w,gfx.w)
    gfx.h  = math.max(min_h,gfx.h)
    
    obj.menu_w = 15
    obj.tab_h = 20
    obj.tab_w = math.ceil(gfx.w/3)
    obj.slider_tab_h = math.floor(obj.tab_h*2)
    obj.slider_tabinfo_h = math.floor(obj.tab_h)
    obj.strategy_w = gfx.w * 0.85
    obj.strategy_h = gfx.h-obj.tab_h*2-obj.offs*2-obj.slider_tab_h
    obj.strategy_itemh = 14
    obj.strat_x_ind = 10
    obj.strat_y_ind = 20
    obj.knob_w = 40
    obj.knob_h = obj.slider_tab_h-1
    obj.exe_but_w = 20
    obj.grid_area = 10
    
    
    if not reduced_view then 
      obj.exec_line_y = gfx.h -obj.slider_tab_h - obj.tab_h-obj.slider_tabinfo_h
      if strategy.act_action ~= 4 then
        Obj_TabRef    (conf, obj, data, refresh, mouse, strategy)
      end
      Obj_TabSrc    (conf, obj, data, refresh, mouse, strategy)
      Obj_TabAct    (conf, obj, data, refresh, mouse, strategy)
     else
      obj.exec_line_y = 0
    end
    
    
    Obj_MenuMain  (conf, obj, data, refresh, mouse, strategy)
    Obj_TabExecute(conf, obj, data, refresh, mouse, strategy)
    
    for key in pairs(obj) do if type(obj[key]) == 'table' then 
      obj[key].context = key 
    end end    
  end
  -----------------------------------------------
  function Obj_TabRef(conf, obj, data, refresh, mouse, strategy)

                            

    obj.TabRef = { clear = true,
                        x = 0,
                        y = obj.tab_h,
                        w = obj.tab_w,
                        h = obj.tab_h,
                        col = 'white',
                        is_selected = conf.activetab == 1,
                        txt= 'Anchor points',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  conf.activetab = 1
                                  refresh.GUI = true
                                  refresh.conf = true
                                end
                        } 
    if conf.activetab ~= 1 then return end
    
    Obj_TabRef_Strategy(conf, obj, data, refresh, mouse, strategy)  
  end  
  ----------------------------------------------- 
  function Obj_TabSrc_Strategy(conf, obj, data, refresh, mouse, strategy) 
    local src_strtUI = {  
                            { name = 'Items',
                              state = strategy.src_selitems,
                              show = strategy.src_positions&1==1
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                              
                              level = 0,
                            func =  function()
                                      if strategy.src_selitems&1~=1 then
                                        strategy.src_selitems = BinaryToggle(strategy.src_selitems,0, 1)
                                        strategy.src_envpoints = BinaryToggle(strategy.src_envpoints,0, 0)
                                        strategy.src_midi = BinaryToggle(strategy.src_midi,0, 0)
                                        strategy.src_strmarkers = BinaryToggle(strategy.src_strmarkers,0, 0)
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },  
                                { name = 'Handle grouping',
                                  state = strategy.src_selitems&4==4,
                                  show = strategy.src_positions&1==1 and strategy.src_selitems&1==1
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                                   
                                  level = 1,
                                func =  function()
                                          strategy.src_selitems = BinaryToggle(strategy.src_selitems, 2)
                                          refresh.GUI = true
                                        end,                               
                                },                            
                                            
                                        
                                { name = 'Obey snap offset',
                                  state = strategy.src_selitems&2==2,
                                  show = strategy.src_positions&1==1 and strategy.src_selitems&1==1
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                                 
                                  level = 1,
                                func =  function()
                                          strategy.src_selitems = BinaryToggle(strategy.src_selitems, 1)
                                          refresh.GUI = true
                                        end,                               
                                },      
                                { name = 'Positions',
                                  state = strategy.src_selitemsflag&1==1,
                                  show = strategy.src_positions&1==1 and strategy.src_selitems&1==1
                                      and (strategy.act_action == 1),                                 
                                  level = 1,
                                func =  function()
                                          strategy.src_selitemsflag = BinaryToggle(strategy.src_selitemsflag, 0)
                                          refresh.GUI = true
                                        end,                               
                                },                                
                                { name = 'Ends',
                                  state = strategy.src_selitemsflag&2==2,
                                  show = strategy.src_positions&1==1 and strategy.src_selitems&1==1
                                      and (strategy.act_action == 1),                                 
                                  level = 1,
                                func =  function()
                                          strategy.src_selitemsflag = BinaryToggle(strategy.src_selitemsflag, 1)
                                          refresh.GUI = true
                                        end,                               
                                },  
                                { name = 'Stretch item',
                                  state = strategy.src_selitemsflag&4==4,
                                  show = strategy.src_positions&1==1 and strategy.src_selitems&1==1
                                      and strategy.act_action == 1 and strategy.src_selitemsflag&2==2,                                 
                                  level = 2,
                                func =  function()
                                          strategy.src_selitemsflag = BinaryToggle(strategy.src_selitemsflag, 2)
                                          refresh.GUI = true
                                        end,                               
                                },                                                                 
                                                        
                            { name = 'Envelope points',
                              state = strategy.src_envpoints,
                              show = strategy.src_positions&1==1 
                                      and (strategy.act_action == 1 
                                          or strategy.act_action == 2 
                                          or strategy.act_action == 3
                                          or strategy.act_action == 4),
                              level = 0,
                            func =  function()
                                      if strategy.src_envpoints&1~=1 then
                                        strategy.src_selitems = BinaryToggle(strategy.src_selitems,0, 0)
                                        strategy.src_envpoints = BinaryToggle(strategy.src_envpoints,0, 1)
                                        strategy.src_midi = BinaryToggle(strategy.src_midi,0, 0)
                                        strategy.src_strmarkers = BinaryToggle(strategy.src_strmarkers,0, 0)
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },  
                                { name = 'Selected envelope only',
                                  state = strategy.src_envpoints==1,
                                  show = strategy.src_positions&1==1 
                                      and strategy.src_envpoints&1==1
                                      and (strategy.act_action == 1 
                                            or strategy.act_action == 2 
                                            or strategy.act_action == 3
                                            or strategy.act_action == 4),                                          
                                  level = 1,
                                func =  function()
                                          strategy.src_envpoints = BinaryToggle(strategy.src_envpoints, 1, 0)
                                          refresh.GUI = true
                                        end,                               
                                }, 
                                { name = 'All envelopes with at least 1 selected point',
                                  state = strategy.src_envpoints&2==2,
                                  show = strategy.src_positions&1==1 
                                      and strategy.src_envpoints&1==1
                                      and (strategy.act_action == 1 
                                            or strategy.act_action == 2 
                                            or strategy.act_action == 3
                                            or strategy.act_action == 4),                                  
                                  level = 1,
                                func =  function()
                                          strategy.src_envpoints = 3--BinaryToggle(strategy.src_envpoints, 1, 1)
                                          refresh.GUI = true
                                        end,                               
                                },   
                                { name = 'Selected Automation Item (non looped only)',
                                  state = strategy.src_envpoints&4==4,
                                  show = strategy.src_positions&1==1 and strategy.src_envpoints&1==1,
                                  level = 1,
                                func =  function()
                                          strategy.src_envpoints = 5--BinaryToggle(strategy.ref_envpoints, 1, 2)
                                          refresh.GUI = true
                                        end,                               
                                },          
                                { name = 'Mode',
                                  show = strategy.src_envpoints&1==1 
                                          and strategy.act_action == 4,                               
                                  level = 1},        
                                  { name = 'Values / Vertical quantize',
                                    state = strategy.src_envpointsflag&2==0,
                                    show = strategy.src_envpoints&1==1 
                                          and (strategy.act_action == 4),                               
                                    level = 2,
                                    func =  function()
                                              --strategy.src_envpointsflag = BinaryToggle(strategy.src_envpointsflag, 1)                                          
                                              refresh.GUI = true
                                            end,                               
                                  },                                               
                            --------------------------------
                            { name = 'MIDI',
                              state = strategy.src_midi,
                              show = strategy.src_positions&1==1 
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                               
                              level = 0,                             
                              func =  function()
                                      if strategy.src_midi&1~=1 then
                                        strategy.src_selitems = BinaryToggle(strategy.src_selitems,0, 0)
                                        strategy.src_envpoints = BinaryToggle(strategy.src_envpoints,0, 0)
                                        strategy.src_midi = BinaryToggle(strategy.src_midi,0, 1)
                                        strategy.src_strmarkers = BinaryToggle(strategy.src_strmarkers,0, 0)
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },                             
                            { name = 'Mode',
                              show = strategy.src_midi&1==1 
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                               
                              level = 1},  
                              
                              { name = 'MIDI Editor',
                                state = strategy.src_midi&2==0,
                                show = strategy.src_midi&1==1 
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                               
                                level = 2,
                                func =  function()
                                          strategy.src_midi = BinaryToggle(strategy.src_midi, 1)                                          
                                          refresh.GUI = true
                                        end,                               
                              }, 
                              { name = 'Selected items',
                                state = strategy.src_midi&2==2,
                                show = strategy.src_midi&1==1
                                      and (strategy.act_action == 1 or strategy.act_action == 3),                                 
                                level = 2,
                                func =  function()
                                          strategy.src_midi = BinaryToggle(strategy.src_midi, 1)
                                          refresh.GUI = true
                                        end,                               
                              },    
                            { name = 'Messages',
                              show = strategy.src_positions&1==1 
                                      and strategy.src_midi&1==1 
                                      and (strategy.act_action == 1  or strategy.act_action == 3),                                     
                              level = 1},  
                                { name = 'NoteOn',
                                  state = strategy.src_midi_msgflag&1==1,
                                  show = strategy.src_positions&1==1 
                                      and strategy.src_midi&1==1 
                                      and (strategy.act_action == 1  or strategy.act_action == 3),                                     
                                  level = 2,
                                  func =  function()
                                            strategy.src_midi_msgflag = BinaryToggle(strategy.src_midi_msgflag, 0)                                          
                                            refresh.GUI = true
                                          end,                               
                                },   
                                { name = 'Preserve length',
                                  state = strategy.src_midi_msgflag&4==4,
                                  show = strategy.src_positions&1==1 
                                      and strategy.src_midi&1==1 
                                      and (strategy.act_action == 1  or strategy.act_action == 3)
                                      and strategy.src_midi_msgflag&1==1,                                     
                                  level = 3,
                                  func =  function()
                                            strategy.src_midi_msgflag = BinaryToggle(strategy.src_midi_msgflag, 2) 
                                            if  strategy.src_midi_msgflag&4==4 then strategy.src_midi_msgflag = BinaryToggle(strategy.src_midi_msgflag, 1, 0) end                                         
                                            refresh.GUI = true
                                          end,                               
                                },                                
                                { name = 'NoteOff',
                                  state = strategy.src_midi_msgflag&2==2,
                                  show = strategy.src_positions&1==1 
                                      and strategy.src_midi&1==1 
                                      and (strategy.act_action == 1  or strategy.act_action == 3),                                     
                                  level = 2,
                                  func =  function()
                                            strategy.src_midi_msgflag = BinaryToggle(strategy.src_midi_msgflag, 1) 
                                            if strategy.src_midi_msgflag&2==2 then strategy.src_midi_msgflag = BinaryToggle(strategy.src_midi_msgflag, 2, 0) end
                                            refresh.GUI = true
                                          end,                               
                                },  
                                
                                
                                             
                                
                                -------------------------      
                            { name = 'Stretch markers',
                              state = strategy.src_strmarkers,
                              show = strategy.src_positions&1==1
                                      and (strategy.act_action == 1 or strategy.act_action == 2 or strategy.act_action == 3),                               
                              level = 0,
                            func =  function()
                                      if strategy.src_strmarkers&1~=1 then
                                        strategy.src_selitems = BinaryToggle(strategy.src_selitems,0, 0)
                                        strategy.src_envpoints = BinaryToggle(strategy.src_envpoints,0, 0)
                                        strategy.src_midi = BinaryToggle(strategy.src_midi,0, 0)
                                        strategy.src_strmarkers = BinaryToggle(strategy.src_strmarkers,0, 1)
                                      end
                                      refresh.GUI = true
                                    end, 
                              },        
                                                                                    
                       
                                                                                                       
                        }
    Obj_Strategy_GenerateTable(conf, obj, data, refresh, mouse, src_strtUI, 'src_strtUI_it', 2, strategy)  
  end  

  ----------------------------------------------- 
  function Obj_TabRef_Strategy(conf, obj, data, refresh, mouse, strategy) 
    local cust_grid
    if strategy.ref_grid&2==0 then cust_grid = strategy.ref_grid_val end
    local grid_division, grid_str, is_triplet, grid_swingmode, grid_swingamt, grid_swingamt_format = VF_GetFormattedGrid(cust_grid)
    if strategy.ref_grid&2==0 and strategy.ref_grid&4 == 4 then is_triplet  = true end
    if strategy.ref_grid&2==0 and  strategy.ref_grid&8 == 8 then 
      grid_swingamt = strategy.ref_grid_sw
      grid_swingamt_format  = math.floor(strategy.ref_grid_sw *100)..'%'
    end
    
    if is_triplet then grid_str = grid_str..'T' end
    if grid_swingamt ~= 0 then grid_str = grid_str..' swing '..grid_swingamt_format end
    
    
    local ref_strtUI = {  { name = 'Positions and values',
                            state = strategy.ref_positions,
                            show = true,
                            has_blit = true,
                            level = 0,
                            func =  function()
                                      if strategy.ref_positions&1 ~= 1 then 
                                        strategy.ref_pattern = BinaryToggle(strategy.ref_pattern, 0, 0)
                                        strategy.ref_positions = BinaryToggle(strategy.ref_positions, 0, 1)
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 0, 0)          
                                      end 
                                      refresh.GUI = true
                                    end,                            
                          },
                            { name = 'Items',
                              state = strategy.ref_selitems,
                              show = strategy.ref_positions&1==1,
                              level = 1,
                            func =  function()
                                      if strategy.ref_selitems&1 ~= 1 then 
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 1)
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)     
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0, 0)   
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0) 
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0, 0)  
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0, 0) 
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)                                
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },   
                                { name = 'Obey snap offset',
                                  state = strategy.ref_selitems&2==2,
                                  show = strategy.ref_positions&1==1 and strategy.ref_selitems&1==1,
                                  level = 2,
                                func =  function()
                                          strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 1)
                                          refresh.GUI = true
                                        end,                               
                                },   
                                { name = 'Value',
                                  show = strategy.ref_positions&1==1 and strategy.ref_selitems&1==1,
                                  level = 2,                     
                                },            
                                { name = 'Item volume',
                                  state = strategy.ref_selitems_value==0,
                                  show = strategy.ref_positions&1==1 and strategy.ref_selitems&1==1,
                                  level = 3,
                                func =  function()
                                          strategy.ref_selitems_value = 0
                                          refresh.GUI = true
                                        end,                               
                                },                                 
                                { name = 'Peak',
                                  state = strategy.ref_selitems_value==1,
                                  show = strategy.ref_positions&1==1 and strategy.ref_selitems&1==1,
                                  level = 3,
                                func =  function()
                                          strategy.ref_selitems_value = 1
                                          refresh.GUI = true
                                        end,                               
                                },
                                { name = 'RMS',
                                  state = strategy.ref_selitems_value==2,
                                  show = strategy.ref_positions&1==1 and strategy.ref_selitems&1==1,
                                  level = 3,
                                func =  function()
                                          strategy.ref_selitems_value = 2
                                          refresh.GUI = true
                                        end,                               
                                },                                
                                                                               
                            { name = 'Envelope points',
                              state = strategy.ref_envpoints,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,
                            func =  function()
                                      if strategy.ref_envpoints&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 1)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0)  
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0, 0)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0)  
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0, 0)  
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0, 0)  
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)                                   
                                      end
                                      refresh.GUI = true
                                    end,                               
                            }, 
                                { name = 'Selected envelope only',
                                  state = strategy.ref_envpoints==1,
                                  show = strategy.ref_positions&1==1 and strategy.ref_envpoints&1==1,
                                  level = 2,
                                func =  function()
                                          strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 1, 0)
                                          refresh.GUI = true
                                        end,                               
                                }, 
                                { name = 'All envelopes',
                                  state = strategy.ref_envpoints&2==2,
                                  show = strategy.ref_positions&1==1 and strategy.ref_envpoints&1==1,
                                  level = 2,
                                func =  function()
                                          strategy.ref_envpoints = 3--BinaryToggle(strategy.ref_envpoints, 1, 1)
                                          refresh.GUI = true
                                        end,                               
                                }, 
                                { name = 'Selected Automation Item (non looped only)',
                                  state = strategy.ref_envpoints&4==4,
                                  show = strategy.ref_positions&1==1 and strategy.ref_envpoints&1==1,
                                  level = 2,
                                func =  function()
                                          strategy.ref_envpoints = 5--BinaryToggle(strategy.ref_envpoints, 1, 2)
                                          refresh.GUI = true
                                        end,                               
                                },                                                                                              
                            { name = 'MIDI',
                              state = strategy.ref_midi,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,                             
                              func =  function()
                                      if strategy.ref_midi&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0) 
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0, 1)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0)   
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0, 0) 
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0, 0)
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)                                      
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },  
                            
                            { name = 'Mode',
                              show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                              level = 2},  
                              
                              { name = 'MIDI Editor',
                                state = strategy.ref_midi&2==0,
                                show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                                level = 3,
                                func =  function()
                                          strategy.ref_midi = BinaryToggle(strategy.ref_midi, 1)                                          
                                          refresh.GUI = true
                                        end,                               
                              }, 
                              { name = 'Selected items',
                                state = strategy.ref_midi&2==2,
                                show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                                level = 3,
                                func =  function()
                                          strategy.ref_midi = BinaryToggle(strategy.ref_midi, 1)
                                          refresh.GUI = true
                                        end,                               
                              },   
                              
                            { name = 'Messages',
                              show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                              level = 2},  
                                { name = 'NoteOn',
                                  state = strategy.ref_midi_msgflag&1==1,
                                  show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                                  level = 3,
                                  func =  function()
                                            strategy.ref_midi_msgflag = BinaryToggle(strategy.ref_midi_msgflag, 0)                                          
                                            refresh.GUI = true
                                          end,                               
                                }, 
                                { name = 'NoteOff',
                                  state = strategy.ref_midi_msgflag&2==2,
                                  show = strategy.ref_positions&1==1 and strategy.ref_midi&1==1 ,
                                  level = 3,
                                  func =  function()
                                            strategy.ref_midi_msgflag = BinaryToggle(strategy.ref_midi_msgflag, 1)                                          
                                            refresh.GUI = true
                                          end,                               
                                },                                         
                                                                                                                                                                         
                            { name = 'Stretch markers',
                              state = strategy.ref_strmarkers,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,
                            func =  function()
                                      if strategy.ref_strmarkers&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0) 
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0,0)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 1) 
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0, 0)    
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0, 0)    
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)                                
                                      end
                                      refresh.GUI = true
                                    end,                               
                            }, 
                            { name = 'Edit Cursor',
                              state = strategy.ref_editcur,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,                            
                            func =  function()
                                      if strategy.ref_editcur&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0) 
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0,0)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0)                                         
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0, 1)
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0, 0)
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },     
                            { name = 'Project markers',
                              state = strategy.ref_marker,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,                            
                            func =  function()
                                      if strategy.ref_marker&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0) 
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0,0)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0)                                         
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0,0)
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0,1)
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,0)
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },                                   
                            { name = 'Tempo markers',
                              state = strategy.ref_timemarker,
                              show = strategy.ref_positions&1==1 ,
                              level = 1,                            
                            func =  function()
                                      if strategy.ref_timemarker&1 ~= 1 then 
                                        strategy.ref_envpoints = BinaryToggle(strategy.ref_envpoints, 0, 0)
                                        strategy.ref_selitems = BinaryToggle(strategy.ref_selitems, 0, 0) 
                                        strategy.ref_midi = BinaryToggle(strategy.ref_midi, 0,0)  
                                        strategy.ref_strmarkers  = BinaryToggle(strategy.ref_strmarkers, 0, 0)                                         
                                        strategy.ref_editcur  = BinaryToggle(strategy.ref_editcur, 0,0)
                                        strategy.ref_marker  = BinaryToggle(strategy.ref_marker, 0,0)
                                        strategy.ref_timemarker  = BinaryToggle(strategy.ref_timemarker, 0,1)
                                        
                                      end
                                      refresh.GUI = true
                                    end,                               
                            },                                  
                               
                          ------------------------------------------
                            { name = 'Grid ('..grid_str..')',
                            state = strategy.ref_grid,
                            show = strategy.act_action == 1 or strategy.act_action == 3,
                            has_blit = true,
                            level = 0,
                            func =  function()
                                      if strategy.ref_grid&1 ~= 1 then 
                                        strategy.ref_pattern = BinaryToggle(strategy.ref_pattern, 0, 0)
                                        strategy.ref_positions = BinaryToggle(strategy.ref_positions, 0, 0)
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 0, 1)          
                                      end                             
                                      refresh.GUI = true
                                    end,                            
                            },  
  
                              { name = 'Current grid',
                              state = strategy.ref_grid&2 == 2,
                              show = (strategy.act_action == 1 or strategy.act_action == 3)
                                      and strategy.ref_grid&1 == 1 ,
                              level = 1,
                              func =  function()
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 1, 1 )
                                        refresh.GUI = true
                                      end,                            
                              },    
                              { name = 'Fantom grid',
                              state = strategy.ref_grid&2 == 0,
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_grid&1 == 1,
                              level = 1,
                              func =  function()
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 1, 0 )
                                        refresh.GUI = true
                                      end,                 
                                follow_obj = {
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= '/2',
                                                show = strategy.ref_grid&2 == 0,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                        strategy.ref_grid_val = lim(strategy.ref_grid_val / 2, 1/128, 1)
                                                        if conf.app_on_strategy_change == 1 then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                                        obj.is_strategy_dirty = true
                                                        SaveStrategy(conf, strategy, 1, true)
                                                        refresh.GUI = true
                                                       end
                                                },   
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= 'x2',
                                                show = strategy.ref_grid&2 == 0,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                        strategy.ref_grid_val = lim(strategy.ref_grid_val * 2,1/128, 1)
                                                        if conf.app_on_strategy_change == 1 then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                                        obj.is_strategy_dirty = true
                                                        SaveStrategy(conf, strategy, 1, true)                                                        
                                                        refresh.GUI = true
                                                       end
                                                },                                                    
                                            }  ,                                           
                              },    
                                        
                              { name = 'Triplet',
                              state = strategy.ref_grid&4 == 4,
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_grid&1 == 1 and strategy.ref_grid&2 == 0,
                              level = 2,
                              func =  function()
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 2 )
                                        refresh.GUI = true
                                      end,
                              },   
                            { name = 'Swing',
                              state = strategy.ref_grid&8 == 8,
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_grid&1 == 1 and strategy.ref_grid&2 == 0,
                              level = 2,
                              func =  function()
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 3 )
                                        refresh.GUI = true
                                      end,
                              follow_obj = {
  
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= '-5%',
                                                show = strategy.act_action == 1 and strategy.ref_grid&2 == 0,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                        strategy.ref_grid_sw = lim(math.floor((strategy.ref_grid_sw -0.05)*100)/100, -1,1)
                                                        if conf.app_on_strategy_change == 1 then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                                        obj.is_strategy_dirty = true
                                                        SaveStrategy(conf, strategy, 1, true)                                                        
                                                        refresh.GUI = true
                                                       end
                                                },
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= '+5%',
                                                show = strategy.act_action == 1 and strategy.ref_grid&2 == 0,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                        strategy.ref_grid_sw = lim(math.floor((strategy.ref_grid_sw +0.05)*100)/100, -1,1)
                                                        if conf.app_on_strategy_change == 1 then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                                        obj.is_strategy_dirty = true
                                                        SaveStrategy(conf, strategy, 1, true)
                                                        refresh.GUI = true
                                                       end
                                                },                                                 
                                              },                                      
                                      
                              },                                                         
                              --strategy.ref_grid_val                                             
                          -------------------------------------------------------                                                 
                          { name = 'Groove',
                            state = strategy.ref_pattern,
                            show = (strategy.act_action == 1 or strategy.act_action == 3),
                            has_blit = true,
                            level = 0,
                              func =  function()
                                      if strategy.ref_pattern&1 ~= 1 then 
                                        strategy.ref_pattern = BinaryToggle(strategy.ref_pattern, 0, 1)
                                        strategy.ref_positions = BinaryToggle(strategy.ref_positions, 0, 0)
                                        strategy.ref_grid = BinaryToggle(strategy.ref_grid, 0, 0)                  
                                      end 
                                      refresh.GUI = true
                                    end                             
                          }, 
                                                        
                            { name = 'Select from list: '..strategy.ref_pattern_name,
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_pattern&1 == 1,
                              --state = strategy.ref_pattern&2 == 0,
                              level = 1,
                              func =  function()
                                        local f_table = Data_GetListedFile(GetResourcePath()..'/Grooves/', strategy.ref_pattern_name..'.rgt')
                                        local t_gr = {}
                                        for i = 1 , #f_table do 
                                          if f_table[i]:match('%.rgt') then
                                            t_gr[#t_gr+1] = {str = f_table[i],
                                                      func = function() 
                                                                local f,content = io.open(GetResourcePath()..'/Grooves/'..f_table[i], 'r')
                                                                if f then 
                                                                  content = f:read('a')
                                                                  f:close()
                                                                end
                                                                if content then
                                                                  data.ref_pat = {}
                                                                  Data_PatternParseRGT(data, strategy, content, true)
                                                                  strategy.ref_pattern_name = f_table[i]:gsub('%.rgt', '')
                                                                  strategy.ref_pattern = BinaryToggle(strategy.ref_pattern, 1,0)
                                                                  SaveStrategy(conf, strategy, 1, true)
                                                                  refresh.GUI = true
                                                                end
                                                              end}
                                          end
                                        end
                                        Menu(mouse, t_gr)       
                                        refresh.GUI = true
                                      end                                   
                            },
                            { name = '',
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_pattern&1 == 1,
                              -- prevent_app = true,
                              level = 0,              
                              follow_obj = {
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= '< prev',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          local prev_fp = Data_GetListedFile(GetResourcePath()..'/Grooves/', strategy.ref_pattern_name..'.rgt', -1)
                                                          
                                                          if prev_fp then 
                                                            local f,content = io.open(GetResourcePath()..'/Grooves/'..prev_fp, 'r')
                                                            if f then 
                                                              content = f:read('a')
                                                              f:close()
                                                            end
                                                            if content then
                                                              data.ref_pat = {}
                                                              Data_PatternParseRGT(data, strategy, content, true)
                                                              strategy.ref_pattern_name = prev_fp:gsub('%.rgt', '')
                                                              SaveStrategy(conf, strategy, 1, true)
                                                              if conf.app_on_groove_change == 1 then  
                                                                Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy)
                                                                Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy)  
                                                                Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                                              end
                                                              refresh.GUI = true
                                                            end
                                                          end
                                                       end
                                                },
                                              { clear = true,
                                                w = obj.strategy_itemh*3,
                                                col = 'white',
                                                txt= 'next >',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          local next_fp = Data_GetListedFile(GetResourcePath()..'/Grooves/', strategy.ref_pattern_name..'.rgt', 1)
                                                          
                                                          if next_fp then 
                                                            local f,content = io.open(GetResourcePath()..'/Grooves/'..next_fp, 'r')
                                                            if f then 
                                                              content = f:read('a')
                                                              f:close()
                                                            end
                                                            if content then
                                                              data.ref_pat = {}
                                                              Data_PatternParseRGT(data, strategy, content, true)
                                                              strategy.ref_pattern_name = next_fp:gsub('%.rgt', '')
                                                              SaveStrategy(conf, strategy, 1, true)
                                                              if conf.app_on_groove_change == 1 then 
                                                                Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                                              end
                                                              refresh.GUI = true
                                                            end
                                                          end
                                                       end
                                                },   
                                                
                                              { clear = true,
                                                w = obj.strategy_itemh*4,
                                                col = 'white',
                                                txt= 'rename',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          local ret, str_input = GetUserInputs(conf.mb_title, 1, 'Rename groove,extrawidth=200' , strategy.ref_pattern_name)
                                                          if ret then 
                                                            strategy.ref_pattern_name = str_input
                                                            refresh.GUI = true
                                                          end
                                                       end
                                                }, 
                                              { clear = true,
                                                w = obj.strategy_itemh*4,
                                                col = 'white',
                                                txt= 'load',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          local retval, fname = reaper.GetUserFileNameForRead('', 'Load groove', 'rgt' )
                                                          if retval and fname then 
                                                            local f,content = io.open(fname, 'r')
                                                            if f then 
                                                              content = f:read('a')
                                                              f:close()
                                                            end
                                                            if content then
                                                              data.ref_pat = {}
                                                              Data_PatternParseRGT(data, strategy, content, true)
                                                              local fname_short = GetShortSmplName(fname)
                                                              strategy.ref_pattern_name = fname_short:gsub('%.rgt', '')
                                                              --SaveStrategy(conf, strategy, 1, true)
                                                              refresh.GUI = true
                                                            end
                                                              if conf.app_on_groove_change == 1 then 
                                                                Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                                              end                                                            
                                                          end                                                          
                                                       end
                                                }, 
                                                                                                
                                              { clear = true,
                                                w = obj.strategy_itemh*4,
                                                col = 'white',
                                                txt= 'save',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          Data_ExportPattern(conf, obj, data, refresh, mouse, strategy, false)
                                                       end
                                                },  
                                                
                                              { clear = true,
                                                w = obj.strategy_itemh*4,
                                                col = 'white',
                                                txt= 'clear',
                                                show = (strategy.act_action == 1 or strategy.act_action == 3),
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          data.ref_pat = {}
                                                          refresh.GUI = true
                                                       end
                                                },                                                                                                                                                                                                           
                                            },
                            },                         
                            { name = 'Length (beats): '..strategy.ref_pattern_len,
                              prevent_app = true,
                              show = (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_pattern&1 == 1,
                              level = 1,
                              follow_obj = {
                                              { clear = true,
                                                w = obj.strategy_itemh,
                                                col = 'white',
                                                txt= '-',
                                                show = true,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          strategy.ref_pattern_len = lim(strategy.ref_pattern_len -1, 2, 16)
                                                          SaveStrategy(conf, strategy, 1, true)
                                                              if conf.app_on_groove_change == 1 then 
                                                                Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                                              end                                                          
                                                          refresh.GUI = true
                                                       end
                                                },
                                              { clear = true,
                                                w = obj.strategy_itemh,
                                                col = 'white',
                                                txt= '+',
                                                show = true,
                                                fontsz = obj.GUI_fontsz2,
                                                func = function()
                                                          strategy.ref_pattern_len = lim(strategy.ref_pattern_len +1, 2, 16)
                                                          SaveStrategy(conf, strategy, 1, true)
                                                              if conf.app_on_groove_change == 1 then 
                                                                Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                                                Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                                              end                                                          
                                                          refresh.GUI = true
                                                       end
                                                }                                                                                               
                                            },
                            },                                          
                        }
    local y_offs = Obj_Strategy_GenerateTable(conf, obj, data, refresh, mouse, ref_strtUI, 'ref_strtUI_it', 1, strategy)
    
    if (strategy.act_action == 1 or strategy.act_action == 3) and strategy.ref_pattern&1==1 then 
      obj.pat_x = obj.offs
      obj.pat_y = obj.tab_h*2 + y_offs+obj.offs*2
      obj.pat_w = gfx.w-obj.offs*2--obj.strategy_w-
      obj.pat_h =  obj.strategy_h - y_offs-obj.offs-obj.slider_tabinfo_h
      Obj_TabRef_Pattern(conf, obj, data, refresh, mouse, strategy) 
    end
    
    if strategy.act_action == 1 and strategy.ref_grid&1==1 then 
      obj.pat_x = obj.offs
      obj.pat_y = obj.tab_h + y_offs+obj.offs*2
      obj.pat_w = gfx.w-obj.offs*2--obj.strategy_w-
      obj.pat_h =  obj.strategy_h - y_offs-obj.offs
      Obj_TabRef_Pattern(conf, obj, data, refresh, mouse, strategy) 
    end
  end
  -----------------------------------------------
  function Data_GetListedFile(path, fname_check, position)
    -- get files list
    local files = {}
    local i = 0
    repeat
    local file = reaper.EnumerateFiles( path, i )
    if file then
      files[#files+1] = file
    end
    i = i+1
    until file == nil
    
    if not position then return files end
    
  -- search file list
    for i = 1, #files do
      --if files[i]:gsub('%%',''):lower():match(literalize(fname_check:lower():gsub('%%',''))) then 
      local ref_file = deliteralize(files[i]:lower())
      local test_file = deliteralize(fname_check:lower())
      if ref_file:match(test_file) then 
        if position == -1 then -- prev
          if i ==1 then return files[#files] else return files[i-1] end
         elseif position == 1 then -- next
          if i ==#files then return files[1] else return files[i+1] end
        end
      end
    end
    return files[1]
  end
  -----------------------------------------------
  function Obj_TabRef_Pattern(conf, obj, data, refresh, mouse, strategy)  
  
    obj.pat_workarea = { clear = true,
                        disable_blitback = true,
                        --alpha_back = 0.05,
                        x = obj.pat_x,
                        y = obj.pat_y,
                        w = obj.pat_w,
                        h = obj.pat_h - obj.grid_area,
                        col = 'white',
                        txt= '',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0.05,
                        func = function()
                                -- get XY
                                  local X = (mouse.x - obj.pat_workarea.x) / obj.pat_workarea.w
                                  local Y = 1-(mouse.y - obj.pat_workarea.y) / obj.pat_workarea.h
                                -- convert to pattern values
                                  local beat_pos = strategy.ref_pattern_len * X
                                  local val = Y
                                -- add to pattern table  
                                  if not data.ref_pat then data.ref_pat = {} end
                                  data.ref_pat  [#data.ref_pat + 1] = { pos = math_q_dec( beat_pos, 6),
                                                                        val = math_q_dec( val, 6) }
                                -- sort pattern table                         
                                  local t_sorted = {}
                                  for _, key in ipairs(getKeysSortedByValue(data.ref_pat, function(a, b) return a < b end, 'pos')) do t_sorted[#t_sorted+1] = data.ref_pat[key]  end
                                  data.ref_pat = t_sorted
                                  refresh.GUI_minor = true
                                  Data_ExportPattern(conf, obj, data, refresh, mouse, strategy, true)
                                end,
                        func_RD = function()
                                    local X = (mouse.x - obj.pat_workarea.x) / obj.pat_workarea.w
                                    local beat_pos = strategy.ref_pattern_len * X
                                    
                                    for i = #data.ref_pat, 1, -1 do
                                      if math.abs(data.ref_pat[i].pos - beat_pos) < 0.005*strategy.ref_pattern_len then 
                                        table.remove(data.ref_pat, i) 
                                        
                                      end
                                    end
                                    refresh.GUI_minor = true
                                    Data_ExportPattern(conf, obj, data, refresh, mouse, strategy, true)
                                end
                        }       
                      
  end  
  -----------------------------------------------   
  function Obj_Strategy_GenerateTable(conf, obj, data, refresh, mouse, ref_strtUI, name, strategytype, strategy) 
    local wstr = gfx.w - obj.offs
    obj[name..'_frame'] = { clear = true,
                      disable_blitback = true,
                        x = 0,obj.offs,
                        y = obj.tab_h*2,--+obj.offs,
                        w = wstr,
                        h = obj.strategy_h,
                        col = 'white',
                        txt= '',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = obj.strategy_frame,
                        ignoremouse = true
                        }   
    local y_offs = 0
    local x_offs = 0    
    for i = 1, #ref_strtUI do
      if obj.exec_line_y < obj.tab_h*2 + obj.offs + y_offs then return y_offs end
      if ref_strtUI[i].show then
        local disable_blitback if not ref_strtUI[i].has_blit then disable_blitback = true end
        local col_str 
        if strategytype == 1 then col_str = 'green' 
          elseif strategytype == 2 then  col_str = 'blue' 
          elseif strategytype == 3 then  col_str = 'red' 
        end
        obj[name..i] =  { clear = true,
                        x = obj.offs + ref_strtUI[i].level *obj.strat_x_ind ,
                        y = obj.tab_h*2 + obj.offs + y_offs,
                        w = wstr - obj.offs - ref_strtUI[i].level *obj.strat_x_ind ,
                        h = obj.strategy_itemh,
                        col = col_str,
                        check = ref_strtUI[i].state,
                        check_state_cnt = ref_strtUI[i].state_cnt,
                        txt= ref_strtUI[i].name,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        aligh_txt = 1,
                        disable_blitback = disable_blitback,
                        func = function() 
                                if ref_strtUI[i].func then ref_strtUI[i].func() end
                                if conf.app_on_strategy_change == 1 and strategytype == 1 and not ref_strtUI[i].prevent_app then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                if conf.app_on_strategy_change == 1 and strategytype == 2 and not ref_strtUI[i].prevent_app then Data_ApplyStrategy_source(conf, obj, data, refresh, mouse, strategy) end
                                obj.is_strategy_dirty = true
                                SaveStrategy(conf, strategy, 1, true)
                              end,
                        func_R = function()  
                                  if ref_strtUI[i].func_R then ref_strtUI[i].func_R() end
                                  if conf.app_on_strategy_change == 1 and strategytype == 1 and not ref_strtUI[i].prevent_app then Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy) end
                                  if conf.app_on_strategy_change == 1 and strategytype == 2 and not ref_strtUI[i].prevent_app then Data_ApplyStrategy_source(conf, obj, data, refresh, mouse, strategy) end
                                  obj.is_strategy_dirty = true
                                  SaveStrategy(conf, strategy, 1, true)
                                end
                        } 
        if ref_strtUI[i].follow_obj then
          local x_off_followobj_offs = obj.strategy_itemh
          local y_off_followobj_offs = 2
          local last_it_w = obj.strategy_itemh
          for i_obj =1, #ref_strtUI[i].follow_obj do
            gfx.setfont(1, obj.GUI_font, obj[name..i].fontsz )
            local str_len = gfx.measurestr(obj[name..i].txt)
            obj[name..i..'_folobj_'..i_obj] = CopyTable(ref_strtUI[i].follow_obj[i_obj])
            
            local obj_x =  ref_strtUI[i].level *obj.strat_x_ind    + str_len  + last_it_w--obj.offs +
            local obj_y = obj.tab_h*2 + obj.offs + y_offs +1
            if obj_x + obj[name..i..'_folobj_'..i_obj].w > obj.strategy_w + obj.offs then
              last_it_w = obj.strategy_itemh
              obj_x = obj.offs + ref_strtUI[i].level *obj.strat_x_ind    + str_len  + last_it_w
              obj_y = obj_y + obj.strategy_itemh
              y_offs = y_offs + obj.strategy_itemh
            end
            
            obj[name..i..'_folobj_'..i_obj].x = obj_x + x_off_followobj_offs
            obj[name..i..'_folobj_'..i_obj].y = obj_y
            obj[name..i..'_folobj_'..i_obj].h = obj.strategy_itemh - 1
            last_it_w = last_it_w + obj[name..i..'_folobj_'..i_obj].w + 1
          end
        end
        y_offs = y_offs + obj.strategy_itemh
      end 
      
    end
    y_offs = y_offs + obj.strategy_itemh
    return y_offs
  end    
  -----------------------------------------------
  function Obj_TabSrc(conf, obj, data, refresh, mouse, strategy)
    local x_tab, w_tab = obj.tab_w,obj.tab_w
    if strategy.act_action == 4 then 
      x_tab =0
      w_tab = obj.tab_w*2
    end
    obj.TabSrc = { clear = true,
                        x = x_tab,
                        y = obj.tab_h,
                        w = w_tab,
                        h = obj.tab_h,
                        col = 'white',
                        is_selected = conf.activetab == 2,
                        txt= 'Target',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function()
                                  conf.activetab = 2 
                                  refresh.conf = true
                                  refresh.GUI = true  
                                end
                        }  
    if conf.activetab ~= 2 then return end
    Obj_TabSrc_Strategy(conf, obj, data, refresh, mouse, strategy)   
  end    
  -----------------------------------------------
  function Obj_TabAct(conf, obj, data, refresh, mouse, strategy) 
            obj.TabAct = { clear = true,
                        x = obj.tab_w*2,
                        y = obj.tab_h,
                        w = obj.tab_w,
                        h = obj.tab_h,
                        col = 'white',
                        is_selected = conf.activetab == 3,
                        txt= 'Action',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  conf.activetab = 3 
                                  refresh.GUI = true 
                                  refresh.conf = true
                                end
                        } 
    if conf.activetab ~= 3 then return end 
     Obj_TabAct_Strategy(conf, obj, data, refresh, mouse, strategy)                      
  end 
  -----------------------------------------------
  function Obj_TabAct_Strategy(conf, obj, data, refresh, mouse, strategy)
    local act_strtUI = {  
                        { name = 'Type',
                            show = true,
                            has_blit = true,
                            level = 0             
                        },
                          { name = 'Position-based alignment (search closer objects)',
                            state = strategy.act_action==1,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      strategy.act_action = 1
                                      refresh.GUI = true
                                    end,             
                          } ,
                            { name = 'Link position/value knobs',
                              state = strategy.act_alignflag&1==1,
                              show = strategy.act_action==1,
                              has_blit = false,
                              level = 2,
                              func =  function()
                                        strategy.act_alignflag = BinaryToggle(strategy.act_alignflag, 0)
                                        refresh.GUI = true
                                      end,             
                            } , 
                                { name = 'Direction',
                                  show = strategy.act_action==1 and strategy.ref_pattern&1~=1 and  strategy.ref_grid&1~=1,                               
                                  level = 2},           
                              { name = 'Always previous point',
                                state = strategy.act_aligndir==0,
                                show = strategy.act_action==1 and strategy.ref_pattern&1~=1 and  strategy.ref_grid&1~=1,   
                                has_blit = false,
                                level = 2,
                                func =  function()
                                          strategy.act_aligndir = 0
                                          refresh.GUI = true
                                        end,             
                              } ,                                   
                              { name = 'Closest point',
                                state = strategy.act_aligndir==1,
                                show = strategy.act_action==1 and strategy.ref_pattern&1~=1 and  strategy.ref_grid&1~=1,   
                                has_blit = false,
                                level = 2,
                                func =  function()
                                          strategy.act_aligndir = 1
                                          refresh.GUI = true
                                        end,             
                              } , 
                              { name = 'Always next point',
                                state = strategy.act_aligndir==2,
                                show = strategy.act_action==1 and strategy.ref_pattern&1~=1 and  strategy.ref_grid&1~=1,   
                                has_blit = false,
                                level = 2,
                                func =  function()
                                          strategy.act_aligndir = 2
                                          refresh.GUI = true
                                        end,             
                              } ,                                                      
                          { name = 'Ordered alignment (align by point positions order)',
                            state = strategy.act_action==3,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      strategy.act_action = 3
                                      refresh.GUI = true
                                    end,             
                          } ,                            
                          { name = 'Create objects',
                            state = strategy.act_action==2,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      strategy.act_action = 2
                                      refresh.GUI = true
                                    end,             
                          } ,  
                          { name = 'RAW quantize',
                            state = strategy.act_action==4,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      strategy.act_action = 4
                                      refresh.GUI = true
                                    end,             
                          } ,                                                                              
                        { name = 'Options',
                            show = true,
                            has_blit = true,
                            level = 0             
                        }, 
                        { name = 'Anchor points',
                            show = true,
                            has_blit = false,
                            level = 1             
                        },        
                            { name = 'Detect on initialization',
                              state = strategy.act_initcatchref,
                              show = true,
                              has_blit = false,
                              level = 2,
                              func =  function()
                                        strategy.act_initcatchref = BinaryToggle(strategy.act_initcatchref, 0)
                                        refresh.GUI = true
                                      end,             
                            } ,   
                            { name = 'Obey time selection',
                              state = strategy.act_catchreftimesel,
                              show = true,
                              has_blit = false,
                              level = 2,
                              func =  function()
                                        strategy.act_catchreftimesel = BinaryToggle(strategy.act_catchreftimesel, 0)
                                        refresh.GUI = true
                                      end,             
                            } ,                            
                            
                        { name = 'Target',
                            show = true,
                            has_blit = false,
                            level = 1             
                        },                             
                          { name = 'Detect target on initialization',
                            state = strategy.act_initcatchsrc,
                            show = true,
                            has_blit = false,
                            level = 2,
                            func =  function()
                                      strategy.act_initcatchsrc = BinaryToggle(strategy.act_initcatchsrc, 0)
                                      refresh.GUI = true
                                    end,             
                          } ,  
                            { name = 'Obey time selection',
                              state = strategy.act_catchsrctimesel,
                              show = true,
                              has_blit = false,
                              level = 2,
                              func =  function()
                                        strategy.act_catchsrctimesel = BinaryToggle(strategy.act_catchsrctimesel, 0)
                                        refresh.GUI = true
                                      end,             
                            } ,                          
                        { name = 'Action output',
                            show = true,
                            has_blit = false,
                            level = 1             
                        },                             
                          { name = 'Calculate on initialization',
                            state = strategy.act_initact&1==1,
                            show = true,
                            has_blit = false,
                            level = 2,
                            func =  function()
                                      strategy.act_initact = BinaryToggle(strategy.act_initact, 0)
                                      refresh.GUI = true
                                    end,             
                          } ,   
                          { name = 'Apply on initialization',
                            state = strategy.act_initapp&1==1,
                            show = true,
                            has_blit = false,
                            level = 2,
                            func =  function()
                                      strategy.act_initapp = BinaryToggle(strategy.act_initapp, 0)
                                      if strategy.act_initapp&1==1 then strategy.act_initact = BinaryToggle(strategy.act_initact, 0, 1) end
                                      refresh.GUI = true
                                    end,             
                          } ,    
                          { name = 'Show QuantizeTool GUI on initialization (use with care!)',
                            state = strategy.act_initgui&1==1,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      if strategy.act_initgui&1 ==1 then
                                        local ret = MB('Checking this option will cause GUI will not appear when running the tool next. '..
                                                      '\nUse the "mpl_QuantizeTool preset - default.lua" action to restore defaults.'..
                                                      '\n\nAre you sure you want to disable opening GUI for this preset?',
                                                      'Warning', 3)
                                        if ret == 6 then
                                          strategy.act_initgui = BinaryToggle(strategy.act_initgui, 0)
                                        end
                                       else
                                        strategy.act_initgui = BinaryToggle(strategy.act_initgui, 0)
                                      end
                                      refresh.GUI = true
                                    end,             
                          } ,                            
                                                                          
                        --[[{ name = 'Options',
                            show = true,
                            has_blit = true,
                            level = 0             
                        }, ]]                          
                         --[[ { name = 'Sort positions before taking values',
                            state = strategy.ref_values&2==2,
                            show = true,
                            has_blit = false,
                            level = 1,
                            func =  function()
                                      strategy.ref_values = BinaryToggle(strategy.ref_values, 1)
                                      refresh.GUI = true
                                    end,             
                          } ,     ]]                                                                                 
                        }
    Obj_Strategy_GenerateTable(conf, obj, data, refresh, mouse, act_strtUI, 'act_strtUI_it', 3, strategy )  
  end  

  -----------------------------------------------
  function Obj_TabExecute_Controls(conf, obj, data, refresh, mouse, strategy) 
    local knob_y_shift = 7
    local knob_cnt = 5
    local but_cnt = 3 
    if strategy.act_action == 2 then 
      knob_cnt = 0
     elseif strategy.act_action == 3 then 
      knob_cnt = 3
     elseif strategy.act_action == 4 then 
      knob_cnt = 2
      but_cnt = 2
    end
    local com_exe_w = gfx.w - obj.menu_w - but_cnt * obj.exe_but_w - 1    
    local but_a = 0.7
    local h_ratio_but = 0.65
    local h_but1 = math.floor((obj.slider_tab_h+obj.slider_tabinfo_h)*h_ratio_but)
    local h_but2 = obj.slider_tab_h+obj.slider_tabinfo_h-h_but1
    
    local but_shift = 0
    local knob_shift = 2
    if strategy.act_action ~= 4 then      
      -- show/catch ref-----------------------------          
      local cnt = 0
      if data.ref then 
        cnt = #data.ref 
        if data.ref.src_cnt then cnt = data.ref.src_cnt end
      end
      obj.ref_catch =  { clear = true,
                          x = obj.menu_w + 1+but_shift,
                          y = obj.tab_h + obj.exec_line_y,
                          w = obj.exe_but_w,
                          h = h_but1,
                          txt_a =1,
                          aligh_txt = 16,
                          show = true,
                          fontsz = obj.GUI_fontsz2,
                          colfill_col = 'green',
                          colfill_a = but_a,
                          func =  function() 
                                    
                                    Data_ApplyStrategy_reference(conf, obj, data, refresh, mouse, strategy)
                                    refresh.GUI = true
                                  end,
                          func_mouseover =  function()
                                        obj.knob_txt.txt = 'Detect anchor points '..'('..cnt..')'
                                        refresh.GUI_minor = true
                                      end                                 
                          }
  
      local ref_showpos_txt =  'Show pattern'
      if data.ref and strategy.ref_pattern&1 ~=1  then ref_showpos_txt = 'Show anchor points ('..cnt..')'  end                
      obj.ref_showpos =  { clear = true,
                          x = obj.menu_w + 1,
                          y = obj.tab_h + obj.exec_line_y + h_but1 +1,
                          w = obj.exe_but_w,
                          h = h_but2,
                          txt_a =1,
                          aligh_txt = 16,
                          show = true,
                          fontsz = obj.GUI_fontsz2,
                          colfill_col = 'green',
                          colfill_a = but_a,
                          colfill_frame = true,
                          func =  function() 
                                    if (strategy.ref_pattern&1==1 or strategy.ref_grid&1==1) then
                                      Data_ShowPointsAsMarkers(conf, obj, data, refresh, mouse, strategy, data.ref_pat, 'green_marker', true) 
                                     else
                                      Data_ShowPointsAsMarkers(conf, obj, data, refresh, mouse, strategy, data.ref, 'green_marker', false) 
                                    end
                                  end,
                          onrelease_L2 = function() 
                                    Data_ClearMarkerPoints(conf, obj, data, refresh, mouse, strategy) 
                                  end,
                          func_mouseover =  function()
                                        obj.knob_txt.txt = ref_showpos_txt
                                        refresh.GUI_minor = true
                                      end                                 
                          }
      but_shift = obj.exe_but_w 
    end
                        
                        
                                                
    -- show/catch src -----------------------------                               
    local cnt = 0
    if data.src then 
      cnt = #data.src 
      if data.src.src_cnt then cnt = data.src.src_cnt end
    end   
    obj.src_catch =  { clear = true,
                        x = obj.menu_w + 1 + but_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.exe_but_w,
                        h = h_but1,
                        colfill_col = 'blue',
                        colfill_a =but_a,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        func =  function() 
                                  Data_ApplyStrategy_source(conf, obj, data, refresh, mouse, strategy)
                                  refresh.GUI = true
                                end,
                        func_mouseover =  function()
                                      obj.knob_txt.txt = 'Detect targets '..'('..cnt..')'
                                      refresh.GUI_minor = true
                                    end                                 
                        }    
                        

    obj.src_showpos =  { clear = true,
                        x = obj.menu_w + 1 + but_shift,
                        y = obj.tab_h + obj.exec_line_y + h_but1 +1,
                        w = obj.exe_but_w,                        
                        h = h_but2,
                        colfill_col = 'blue',
                        colfill_a =but_a,
                        colfill_frame = true,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        func =  function() 
                                  Data_ShowPointsAsMarkers(conf, obj, data, refresh, mouse, strategy, data.src, 'blue_marker') 
                                end,
                        onrelease_L2 = function() 
                                  Data_ClearMarkerPoints(conf, obj, data, refresh, mouse, strategy) 
                                end,
                        func_mouseover =  function()
                                      obj.knob_txt.txt = 'Show target positions ('..cnt..')'
                                      refresh.GUI_minor = true
                                    end                                 
                        } 
    but_shift = but_shift+obj.exe_but_w 

      -----------------------------                                                                                     
    if strategy.act_action == 1 or strategy.act_action ==3 or strategy.act_action ==4 then 
      obj.act_calc =  { clear = true,
                        x = obj.menu_w + 1 + but_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.exe_but_w,
                        h = h_but1,
                        colfill_col = 'red',
                        colfill_a =but_a,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        func =  function() 
                                  Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy)  
                                  refresh.GUI = true
                                end,
                        func_mouseover =  function()
                                      obj.knob_txt.txt = 'Calculate output'
                                      refresh.GUI_minor = true
                                    end                                 
                        }  
    end    
    
    local h_ex = h_but2
    local y_ex= obj.tab_h + obj.exec_line_y +h_but1 +1   
    if strategy.act_action == 2 then  
      h_ex   =h_but1+h_but2+1
      y_ex = obj.tab_h + obj.exec_line_y
    end                     
    obj.act_ex =  { clear = true,
                        x = obj.menu_w + 1 + but_shift,
                        y = y_ex,
                        w = obj.exe_but_w,
                        h = h_ex,
                        colfill_col = 'red',
                        colfill_a =but_a,
                        colfill_frame = true,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        func =  function() 
                                  Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                  refresh.GUI = true
                                end,
                        func_mouseover =  function()
                                      if strategy.act_action == 1 or strategy.act_action == 3 then
                                        obj.knob_txt.txt = 'Apply action output '..FormatPercent(strategy.exe_val1)..'/'..FormatPercent(strategy.exe_val2)
                                       elseif strategy.act_action == 2 then
                                        obj.knob_txt.txt = 'Create objects'
                                       elseif strategy.act_action == 4 then
                                        obj.knob_txt.txt = 'Apply action output'                                      
                                      end
                                      refresh.GUI_minor = true
                                    end                                 
                        }
    but_shift = but_shift+obj.exe_but_w 
    
    
          
     -----------------------------                                               
    if strategy.act_action == 1 or strategy.act_action ==3 or strategy.act_action ==4 then   
      obj.exe_val1 = { clear = true,
                        is_knob = true,
                        knob_y_shift = knob_y_shift,
                        x =   obj.menu_w + but_shift + 1+knob_shift,
                        y =  obj.tab_h + obj.exec_line_y,
                        w = obj.knob_w,
                        h = obj.knob_h,
                        col = 'white',
                        txt= '',
                        val = strategy.exe_val1,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  if conf.app_on_slider_click == 1 then Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) end
                                  mouse.context_latch_val = strategy.exe_val1
                                end,
                        func_LD2 = function()
                                      if mouse.context_latch_val then 
                                        strategy.exe_val1 = lim(mouse.context_latch_val + mouse.dx*0.001 - mouse.dy*0.01)
                                        obj.exe_val1.val = strategy.exe_val1
                                        
                                        if strategy.act_alignflag&1==1 then 
                                          obj.exe_val2.val = obj.exe_val1.val
                                          strategy.exe_val2 = strategy.exe_val1
                                        end
                                        
                                        if strategy.act_action == 1 or strategy.act_action ==3 then
                                          obj.knob_txt.txt = 'Align position '..FormatPercent(strategy.exe_val1)
                                         elseif strategy.act_action == 4 then
                                          obj.knob_txt.txt = 'Align value '..FormatPercent(strategy.exe_val1)
                                        end
                                        
                                        refresh.GUI_minor = true
                                        Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                      end
                                    end  ,
                        func_mouseover =  function()
                                            if strategy.act_action == 1 or strategy.act_action ==3 then
                                              obj.knob_txt.txt = 'Align position '..FormatPercent(strategy.exe_val1)
                                              if strategy.exe_val1 == 0 then obj.knob_txt.txt = 'Align position: disabled' end
                                             elseif strategy.act_action == 4 then
                                              obj.knob_txt.txt = 'Align value '..FormatPercent(strategy.exe_val1)
                                            end
                                            
                                            refresh.GUI_minor = true
                                          end  ,
                        onrelease_L2  = function()  
                                          UpdateArrange()
                                          SaveStrategy(conf, strategy, 1, true) 
                                        end,
                        func_L_Alt = function()
                                        strategy.exe_val1 = 0
                                        obj.exe_val1.val = 0
                                        SaveStrategy(conf, strategy, 1, true) 
                                        refresh.GUI_minor = true
                                      end   ,
                        func_R = function()
                                    local ret, str =  GetUserInputs( conf.mb_title, 1, 'Value 1', strategy.exe_val1 )
                                    if tonumber(str) then
                                      str = tonumber(str)
                                      local out_num = lim(str, 0,1)
                                      strategy.exe_val1 = out_num
                                      refresh.GUI = true
                                    end
                                  end                                      
                        }
      knob_shift = knob_shift+obj.knob_w
    end
     -----------------------------      
    if strategy.act_action == 1 or strategy.act_action ==3 or strategy.act_action ==4 then 
      obj.exe_val2 = { clear = true,
                        is_knob = true,
                        knob_y_shift = knob_y_shift,
                        x =   obj.menu_w + 1+but_shift+knob_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.knob_w,
                        h = obj.knob_h,
                        col = 'white',
                        state = fale,
                        txt= '',
                        val = strategy.exe_val2,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  if conf.app_on_slider_click == 1 then Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) end
                                  mouse.context_latch_val = strategy.exe_val2
                                end,
                        func_LD2 = function()
                                    if mouse.context_latch_val then 
                                      strategy.exe_val2 = lim(mouse.context_latch_val + mouse.dx*0.001 - mouse.dy*0.01)
                                      obj.exe_val2.val = strategy.exe_val2
                                      if strategy.act_alignflag&1==1 then 
                                        obj.exe_val1.val = obj.exe_val2.val
                                        strategy.exe_val1 = strategy.exe_val2
                                      end
                                      
                                      if strategy.act_action == 1 or strategy.act_action ==3 then
                                        obj.knob_txt.txt = 'Align value '..FormatPercent(strategy.exe_val2)
                                       elseif strategy.act_action == 4 then
                                        obj.knob_txt.txt = 'Quantization steps '..math.floor(strategy.exe_val2*127)
                                      end
                                      
                                      refresh.GUI_minor = true
                                      Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                    end
                                end ,
                        func_mouseover =  function()
                                      if strategy.act_action == 1 or strategy.act_action ==3 then
                                        obj.knob_txt.txt = 'Align value '..FormatPercent(strategy.exe_val2)
                                        if strategy.exe_val2 == 0 then obj.knob_txt.txt = 'Align value: disabled' end
                                       elseif strategy.act_action == 4 then
                                        obj.knob_txt.txt = 'Quantization steps '..math.floor(strategy.exe_val2*127)
                                      end
                                      refresh.GUI_minor = true
                                    end    ,
                        onrelease_L2  = function()  SaveStrategy(conf, strategy, 1, true) end   ,
                        func_L_Alt = function()
                                        strategy.exe_val2 = 0
                                        obj.exe_val2.val = 0
                                        SaveStrategy(conf, strategy, 1, true) 
                                        refresh.GUI_minor = true
                                      end ,
                        func_R = function()
                                    local ret, str =  GetUserInputs( conf.mb_title, 1, 'Value 2', strategy.exe_val2 )
                                    if tonumber(str) then
                                      str = tonumber(str)
                                      local out_num
                                      if strategy.act_action == 1 or strategy.act_action ==3 then
                                        out_num = lim(str, 0,1)
                                       else
                                        out_num = lim(str, 0,127)
                                      end
                                      strategy.exe_val2 = out_num
                                      refresh.GUI = true
                                    end
                                  end                                                                                                                                    
                        }
      knob_shift = knob_shift+obj.knob_w  
    end
    -----------------------------        
    if strategy.act_action == 1 or strategy.act_action == 3 then 
      obj.exe_val3 = { clear = true,
                        is_knob = true,
                        knob_y_shift = knob_y_shift,
                        x =   obj.menu_w + 1+but_shift+knob_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.knob_w,
                        h =obj.knob_h,
                        col = 'white',
                        txt= '',
                        val = strategy.exe_val3/2,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  --if conf.app_on_slider_click == 1 then Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) end
                                  mouse.context_latch_val = strategy.exe_val3
                                end,
                        func_LD2 = function()
                                    if strategy.act_action == 1 then 
                                      if mouse.context_latch_val then 
                                        strategy.exe_val3 = lim(mouse.context_latch_val + mouse.dx*0.001 - mouse.dy*0.01, 0, 2)
                                        obj.exe_val3.val = strategy.exe_val3/2
                                        obj.knob_txt.txt = 'Include within '..strategy.exe_val3..' beats'
                                        refresh.GUI_minor = true
                                      end
                                    end
                                    
                                    if strategy.act_action == 3 then
                                      if mouse.context_latch_val then 
                                        strategy.exe_val3 = lim(mouse.context_latch_val + mouse.dx*0.0005 - mouse.dy*0.005, 0, 0.5)
                                        obj.exe_val3.val = strategy.exe_val3*2
                                        obj.knob_txt.txt = 'Treat closer AP: '..strategy.exe_val3..' beats'
                                        refresh.GUI_minor = true
                                      end
                                    end
                                                                        
                                end ,
                        func_mouseover =  function()
                                      if strategy.act_action == 1 then
                                        obj.knob_txt.txt = 'Include within '..strategy.exe_val3..' beats'
                                        if strategy.exe_val3 == 0 then obj.knob_txt.txt = 'Include within: disabled' end
                                       elseif strategy.act_action == 3 then
                                        obj.knob_txt.txt = 'Treat closer AP: '..strategy.exe_val3..' beats'
                                        if strategy.exe_val3 == 0 then obj.knob_txt.txt = 'Treat closer AP: disabled' end                                       
                                      end
                                      refresh.GUI_minor = true
                                    end ,
                        onrelease_L2  = function()  
                                          if conf.app_on_slider_click == 1 then 
                                            Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                            Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                          end
                                          SaveStrategy(conf, strategy, 1, true) 
                                        end    ,
                        func_L_Alt = function()
                                        strategy.exe_val3 = 0
                                        obj.exe_val3.val = 0
                                        SaveStrategy(conf, strategy, 1, true) 
                                        refresh.GUI_minor = true
                                      end     ,
                        func_R = function()
                                    local ret, str =  GetUserInputs( conf.mb_title, 1, 'Value 3', strategy.exe_val3 )
                                    if tonumber(str) then
                                      str = tonumber(str)
                                      local out_num
                                      if strategy.act_action == 1  then
                                        out_num = lim(str, 0,2)
                                       elseif strategy.act_action ==3 then
                                        out_num = lim(str, 0,0.5)
                                      end
                                      strategy.exe_val3 = out_num
                                      refresh.GUI = true
                                    end
                                  end                                                                                                                                                 
                        }  
      knob_shift = knob_shift+obj.knob_w
    end
    -----------------------------      
    if strategy.act_action == 1 then 
      local val4 = strategy.exe_val4
      if not val4 then val4 = 0 end
      obj.exe_val4 = { clear = true,
                        is_knob = true,
                        knob_y_shift = knob_y_shift,
                        x =   obj.menu_w + 1+but_shift+knob_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.knob_w,
                        h = obj.knob_h,
                        col = 'white',
                        txt= '',
                        val = val4/2,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  if conf.app_on_slider_click == 1 then Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) end
                                  mouse.context_latch_val = strategy.exe_val4
                                end,
                        func_LD2 = function()
                                    if mouse.context_latch_val then 
                                      strategy.exe_val4 = lim(mouse.context_latch_val + mouse.dx*0.001 - mouse.dy*0.01, 0, 2)
                                      obj.exe_val4.val = strategy.exe_val4/2
                                      obj.knob_txt.txt = 'Exclude within '..strategy.exe_val4..' beats'
                                      refresh.GUI_minor = true
                                    end
                                end ,
                        func_mouseover =  function()
                                      obj.knob_txt.txt = 'Exclude within '..strategy.exe_val4..' beats'
                                      if strategy.exe_val4 == 0 then obj.knob_txt.txt = 'Exclude within: disabled' end
                                      refresh.GUI_minor = true
                                    end ,
                        onrelease_L2  = function()  
                                          if conf.app_on_slider_click == 1 then 
                                            Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                            Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                          end
                                          SaveStrategy(conf, strategy, 1, true) 
                                        end   ,
                        func_L_Alt = function()
                                        strategy.exe_val4 = 0
                                        obj.exe_val4.val = 0
                                        SaveStrategy(conf, strategy, 1, true) 
                                        refresh.GUI_minor = true
                                      end  ,
                        func_R = function()
                                    local ret, str =  GetUserInputs( conf.mb_title, 1, 'Value 4', strategy.exe_val4 )
                                    if tonumber(str) then
                                      str = tonumber(str)
                                      local out_num = lim(str, 0,2)
                                      strategy.exe_val4 = out_num
                                      refresh.GUI = true
                                    end
                                  end                                        
                                                                                                           
                        }  
        knob_shift = knob_shift+obj.knob_w
      end
    -----------------------------      
    if strategy.act_action == 1 or strategy.act_action == 3 then 
      local val5 = strategy.exe_val5
      if not val5 then val5 = 0 end
      obj.exe_val5 = { clear = true,
                        is_knob = true,
                        knob_y_shift = knob_y_shift,
                        is_centered_knob = true,
                        x =   obj.menu_w + 1+but_shift+knob_shift,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.knob_w,
                        h = obj.knob_h,
                        col = 'white',
                        txt= '',
                        val = val5,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  --[[if conf.app_on_slider_click == 1 then 
                                    Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                  end]]
                                  mouse.context_latch_val = strategy.exe_val5
                                end,
                        func_LD2 = function()
                                    if mouse.context_latch_val then 
                                      strategy.exe_val5 = lim(mouse.context_latch_val + mouse.dx*0.001 - mouse.dy*0.01, 0, 1)
                                      obj.exe_val5.val = strategy.exe_val5
                                      obj.knob_txt.txt = 'Offset '..(math.floor((strategy.exe_val5*2-1)*1000)/1000)..' beats'
                                      refresh.GUI_minor = true
                                    end
                                end ,
                        func_mouseover =  function()
                                      obj.knob_txt.txt = 'Offset '..(math.floor((strategy.exe_val5*2-1)*1000)/1000)..' beats'
                                      refresh.GUI_minor = true
                                    end ,
                        onrelease_L2  = function()  
                                          if conf.app_on_slider_click == 1 then 
                                            Data_ApplyStrategy_action(conf, obj, data, refresh, mouse, strategy) 
                                            Data_Execute(conf, obj, data, refresh, mouse, strategy)
                                          end
                                          SaveStrategy(conf, strategy, 1, true) 
                                        end   ,
                        func_L_Alt = function()
                                        strategy.exe_val5 = 0.5
                                        obj.exe_val5.val = 0.5
                                        SaveStrategy(conf, strategy, 1, true) 
                                        refresh.GUI_minor = true
                                      end  ,
                        func_R = function()
                                    local ret, str =  GetUserInputs( conf.mb_title, 1, 'Value 5', (math.floor((strategy.exe_val5*2-1)*1000)/1000) )
                                    if tonumber(str) then
                                      str = tonumber(str)
                                      local out_num = lim(str, -1,1)
                                      strategy.exe_val5 = (out_num+1)/2
                                      refresh.GUI = true
                                    end
                                  end                                                                                                                                                       
                        }  
        knob_shift = knob_shift+obj.knob_w
      end      
       -----------------------------                                                                                                                         
      obj.knob_txt = { clear = true,
                        x =   obj.menu_w + 3 + but_shift,-- + obj.knob_w*knob_cnt,
                        y = obj.tab_h + obj.exec_line_y +obj.slider_tab_h,
                        w = gfx.w-obj.menu_w- but_shift,--com_exe_w - obj.knob_w*knob_cnt,
                        h = obj.slider_tabinfo_h,
                        col = 'white',
                        txt= '',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,}   
      obj.knob_fill2 = { clear = true,
                        x =   obj.menu_w + 1+but_shift+knob_shift,
                        y = obj.tab_h + obj.exec_line_y,-- +obj.slider_tab_h+1,
                        w = gfx.w-obj.menu_w- but_shift - knob_shift,
                        h = obj.knob_h,
                        col = 'white',
                        txt= '',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,}                                            
  end
  -----------------------------------------------
  function Obj_TabExecute(conf, obj, data, refresh, mouse, strategy)
  
    local preset_w = 50
    obj.TabExe_prestitle = { clear = true,
                      --disable_blitback = true,
                      x =  0,
                      y = 0,--obj.exec_line_y,
                      w = preset_w,
                      h = obj.tab_h-2,
                      col = 'white',
                      txt= 'Preset',
                      show = true,
                      fontsz = obj.GUI_fontsz2,
                      
                      a_frame = 0,
                        func =  function() 
                                  local t = {  
                                   { str = 'Rename preset|',
                                            func = function() 
                                                      local ret, str_input = GetUserInputs(conf.mb_title, 1, 'Rename preset,extrawidth=200' , strategy.name)
                                                      if ret then 
                                                        str_input = str_input:gsub('[%/%\\%:%8%?%"%<%>%|]+','')
                                                        strategy.name = str_input
                                                        refresh.GUI = true
                                                      end
                                                    end
                                          },  
           
      { str = 'Dump current preset configuration',
        func = function() 
                local str = ''
                for key in spairs(strategy) do
                  str = str..'\n'..key..' = '..strategy[key]
                end
                ClearConsole()
                msg(str)
              end,
      },
      { str = 'Dump current preset anchor points data',
        func = function() 
                local str = ''
                for i= 1, #data.ref do  
                  str = str..'\n'..i
                  for key in spairs(data.ref[i]) do
                    if type(data.ref[i][key]) == 'number' or type(data.ref[i][key]) == 'string' then
                      str = str..'\n  '..key..' '..data.ref[i][key]
                    end
                  end
                end
                ClearConsole()
                msg(str)
              end,   
      },   
      { str = 'Dump current preset targets data',
        func = function() 
                local str = ''
                for i= 1, #data.src do  
                  str = str..'\n'..i
                  for key in spairs(data.src[i]) do
                    if type(data.src[i][key]) == 'number' or type(data.src[i][key]) == 'string' then
                      str = str..'\n  '..key..' '..data.src[i][key]
                    end
                  end
                end
                ClearConsole()
                msg(str)
              end,
      },                                          
                                  }
                                  Menu(mouse, t)
                                end
                                                                    
                      }

    obj.TabExe_presload = { clear = true,
                      --disable_blitback = true,
                      x =  preset_w,
                      y = 0,--obj.exec_line_y,
                      w = preset_w,
                      h = obj.tab_h-2,
                      col = 'white',
                      txt= 'Load',
                      show = true,
                      fontsz = obj.GUI_fontsz2,                      
                      a_frame = 0,
                        func =  function() 
                                  local t = {  
{ str = 'Load default preset',
                                            func = function() 
                                                      LoadStrategy(conf, strategy, true)
                                                      refresh.GUI = true
                                                    end
                                          },
                                          { str = 'Load preset from file',
                                            func = function() 
                                              path = GetResourcePath()..'/Scripts/MPL Scripts/Various/mpl_QuantizeTool_presets/default.qt'
                                                      local retval, qtstr_file = GetUserFileNameForRead(path, 'Load preset from file', 'qt' )
                                                      LoadStrategy_Parse(strategy, qtstr_file)
                                                      refresh.GUI = true
                                                    end
                                          } ,    
                                          { str = 'Open presets path|',
                                            func = function() 
                                                    local strat_fp = '"'..obj.script_path .. 'mpl_QuantizeTool_presets\\"'  
                                                    Open_URL(strat_fp) 
                                                  end
                                          }  ,
                                          { str = '#Presets list'}  ,                                                                                                                            
                                                                              
                                        }
                                  for i = 1, 100 do
                                    local fp = EnumerateFiles( obj.script_path .. 'mpl_QuantizeTool_presets/', i-1 )
                                    if not fp or fp == '' then break end
                                    if fp:match('%.qt') and not fp:match('default') and not fp:match('last saved')then
                                      t[#t+1] = { str = fp:gsub('.qt', ''),
                                                  func =  function() 
                                                            LoadStrategy_Parse(strategy, obj.script_path .. 'mpl_QuantizeTool_presets/'..fp)
                                                            refresh.GUI = true
                                                          end
                                                }
                                    end
                                  end      
                                  
                                  Menu(mouse, t)
                                end
                                                                    
                      }
                      
                      
    obj.TabExe_pressave = { clear = true,
                      --disable_blitback = true,
                      x =  preset_w*2,
                      y = 0,--obj.exec_line_y,
                      w = preset_w,
                      h = obj.tab_h-2,
                      col = 'white',
                      txt= 'Save',
                      show = true,
                      fontsz = obj.GUI_fontsz2,                      
                      a_frame = 0,
                        func =  function() 
                                  local t = {  
                                                                
                                          { str = 'Save preset to file',
                                            func = function() SaveStrategy(conf, strategy, 1 ) end
                                          }   ,                                        
                                          { str = 'Save preset to file and action list',
                                            func = function() SaveStrategy(conf, strategy, 3) end
                                          }  ,
                                          { str = 'Open presets path',
                                            func = function() 
                                                    local strat_fp = '"'..obj.script_path .. 'mpl_QuantizeTool_presets\\"'  
                                                    Open_URL(strat_fp) 
                                                  end
                                          }  ,                                 
                                        }
                                  
                                  Menu(mouse, t)
                                end
                                                                    
                      } 
                                                                
    Obj_TabExecute_Controls(conf, obj, data, refresh, mouse, strategy)
      local name = strategy.name
      if obj.is_strategy_dirty==true then name = name..'*' end
      obj.TabExe_stratname = { clear = true,
                        --disable_blitback = true,
                        x =  preset_w*3,
                        y = 0,--obj.exec_line_y,
                        w = gfx.w-preset_w*3,
                        h = obj.tab_h-2,
                        col = 'white',
                        txt= name,
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                            }                        
                        
                        
  end 
  -----------------------------------------------   
  function FormatPercent(val) 
    if not val then return end
    return math_q_dec(val*100, 2)..'%'
  end
  -----------------------------------------------
  function Obj_MenuMain(conf, obj, data, refresh, mouse, strategy)
            obj.menu = { clear = true,
                        x = 0,
                        y = obj.tab_h + obj.exec_line_y,
                        w = obj.menu_w,
                        h = obj.slider_tab_h+obj.slider_tabinfo_h,
                        col = 'white',
                        state = fale,
                        txt= '>',
                        show = true,
                        fontsz = obj.GUI_fontsz2,
                        a_frame = 0,
                        func =  function() 
                                  Menu(mouse,               
    {
      { str = conf.mb_title..' '..conf.vrs,
        hidden = true
      },
      { str = '|Manual',
        func = function()
                local manfp = '"'..obj.script_path .. 'mpl_QuantizeTool_presets\\mpl_QuantizeTool - Getting started.pdf"'  
                Open_URL(manfp) 
              end},
      { str = 'Cockos Forum thread|',
        func = function() Open_URL('http://forum.cockos.com/showthread.php?t=165672') end  } , 
      { str = 'Donate to MPL',
        func = function() Open_URL('http://www.paypal.me/donate2mpl') end }  ,
      { str = 'Contact: MPL VK',
        func = function() Open_URL('http://vk.com/mpl57') end  } ,     
      { str = 'Contact: MPL SoundCloud|',
        func = function() Open_URL('http://soundcloud.com/mpl57') end  } ,     
        
      { str = '#Options'},    
      { str = 'Apply preset (Get AnchorPoints/Target) on preset change',
        func = function() 
                conf.app_on_strategy_change = math.abs(1-conf.app_on_strategy_change) 
              end,
        state = conf.app_on_strategy_change == 1}, 
      { str = 'Apply preset (Calculate output and Execute) on knob touch',
        func = function() 
                conf.app_on_slider_click = math.abs(1-conf.app_on_slider_click) 
              end,
        state = conf.app_on_slider_click == 1},         
      { str = 'Apply preset (Calculate output and Execute) on groove change|',
        func = function() 
                conf.app_on_groove_change = math.abs(1-conf.app_on_groove_change) 
              end,
        state = conf.app_on_groove_change == 1},           
        
        
        
                   
      { str = 'Dock '..'MPL '..conf.mb_title..' '..conf.vrs,
        func = function() 
                  if conf.dock > 0 then conf.dock = 0 else conf.dock = 1 end
                  gfx.quit() 
                  gfx.init('MPL '..conf.mb_title..' '..conf.vrs,
                            conf.wind_w, 
                            conf.wind_h, 
                            conf.dock, conf.wind_x, conf.wind_y)
              end ,
        state = conf.dock > 0},                                                                            
    }
    )
                                  refresh.conf = true 
                                  --refresh.GUI = true
                                  --refresh.GUI_onStart = true
                                  refresh.data = true
                                end}  
  end
