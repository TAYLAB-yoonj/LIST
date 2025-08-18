function save_seq_Callback(hObject, eventdata, handles)
global GUI vc

scr_update('Saving sequences');
datTable=GUI.tab.Data;
[filename,location,indx] = uiputfile('datTable.xlsx');

if filename
    T=array2table(datTable(:,1:5),'VariableNames',{'Seq','Delay','Memo','Run','Delete'});
    writetable(T,filename)  
end

end
