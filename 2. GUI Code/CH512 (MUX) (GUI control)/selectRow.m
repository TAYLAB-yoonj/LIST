function selectRow(src,evt)
global GUI 
    pushCol=evt.Indices;
    if ~isempty(evt.Indices)
        GUI.selectRow=pushCol;
    end
end
