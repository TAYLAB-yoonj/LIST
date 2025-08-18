function scEdit_Callback(hObject, eventdata)

global GUI

if GUI.scRunning == 1
    errordlg('Cannot edit while the script is running.', 'Script');
else
    fname = [GUI.scFolder GUI.scFName];
    if ~isempty(GUI.scFName) && ~isempty(GUI.scFolder) && exist([fname '.m'], 'file')
        open([fname '.m']);
    else
        errordlg('Cannot find the script!', 'Script');
    end
end
