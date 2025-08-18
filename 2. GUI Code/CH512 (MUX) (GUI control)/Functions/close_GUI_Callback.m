function close_GUI_Callback(hObject, eventdata, handles)

global GUI vc f p1 p2 p3 sc
qdlg=questdlg('Are you sure you want to close?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch qdlg
    case 'Yes'
        vc = vc_close(vc, 1);
        delete(f)
        delete(p1.t)
        delete(p2.t)
        delete(p3.t)
        % delete(sc.t)
        clear
        disp('GUI has been closed')
    case 'No'
        return
end
end