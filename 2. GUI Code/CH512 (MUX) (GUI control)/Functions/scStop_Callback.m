function scStop_Callback(hObject, eventdata)

global GUI sc

if GUI.scRunning == 1
    GUI.scStop = 1;
%     stop(sc.t);
    scr_update('Script running abolished.');
else
    errordlg('No script running!', 'Script');
    scr_update('No script running!');
end

end