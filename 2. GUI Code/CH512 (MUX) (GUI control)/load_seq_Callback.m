function load_seq_Callback(hObject, eventdata, handles)
global GUI vc

scr_update('Loading sequences');

if GUI.scRunning == 1
    str = ['Cannot change the script folder, while a script is running!'];
    scr_update(str);
    errordlg(str, 'Script Folder');
else
    [file,location,indx] = uigetfile('*.xlsx');
    if file
%         opts = detectImportOptions(file,'ReadVariableNames',true,'VariableNamingRule','preserve');
%         opts.SelectedVariableNames = ['Seq','Delay','Memo'];
%         opts = detectImportOptions(file);
%         opts.VariableNames = ['Seq','Delay','Memo'];
        TT = readtable(file);
        TT=TT(:,{'Seq','Delay','Memo'});
        TT.Delay=num2str(TT.Delay);
        nn=size(TT,1);
        TT.Run=true(nn,1);
        TT.Delete=false(nn,1);
%         TT=addvars(TT,true(nn,1),'NewVariableNames','Run');
%         TT=addvars(TT,false(nn,1),'NewVariableNames','Delete');
        GUI.tab.Data=table2cell(TT);
        scr_update(['Loading file ' file]);
        scUpdate_Callback;
    end
end

    GUI.button(GUI.tot+10).BackgroundColor=[.7 .7 .7];
    
end