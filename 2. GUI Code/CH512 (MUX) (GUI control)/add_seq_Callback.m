function add_seq_Callback(hObject, eventdata, handles)
global GUI vc

if isempty(GUI.selectRow)
    GUI.tab.Data=[GUI.tab.Data; { '' '' '' true false }];
else
    rr=GUI.selectRow;
    disp(rr)
    if rr(1)==size(GUI.tab.Data,1) || rr(1)>size(GUI.tab.Data,1)
        GUI.tab.Data=[GUI.tab.Data; { '' '' '' true false };];
    else
        GUI.tab.Data=[GUI.tab.Data(1:rr(1),:);  ...
        { '' '' '' true false }; GUI.tab.Data(rr(1)+1:end,:)];
    end
end
    
end