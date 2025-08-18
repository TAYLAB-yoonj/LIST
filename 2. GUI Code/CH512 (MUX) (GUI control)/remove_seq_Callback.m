function remove_seq_Callback(hObject, eventdata, handles)
global GUI vc

if size(GUI.tab.Data,1)>1
GUI.tab.Data(end,:)=[];
end

end