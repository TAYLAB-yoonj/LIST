function scFName_Callback(hObject, event)

global GUI

if GUI.scRunning == 1
    str = ['Cannot change the script folder, while a script is running!'];
    scr_update(str);
    errordlg(str, 'Script Folder');
else
    v = get(hObject, 'Value');
    str = get(hObject, 'String');
    GUI.scFName = str{v};
    scr_update(['Current script file is set to ' GUI.scFName]);
end
end