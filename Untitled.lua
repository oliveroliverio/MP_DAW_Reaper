function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

lastDetailsOut = -1

function GetMouseCursorDetails()

  windowOut, segmentOut, detailsOut = reaper.BR_GetMouseCursorContext()
  
  if lastDetailsOut ~= detailsOut then
    msg("detailsOut: " .. detailsOut)
  end
  
  lastDetailsOut = detailsOut
  
  reaper.defer(GetMouseCursorDetails)
end

GetMouseCursorDetails()
