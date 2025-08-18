function scFolder_Callback(hObject, eventdata)

global GUI

if GUI.scRunning == 1
    str = ['Cannot change the script folder, while a script is running!'];
    scr_update(str);
    errordlg(str, 'Script Folder');
else
    folder = uigetdir(GUI.scFolder, 'Please the select a folder where scripts are stored');
    if folder
        if folder(end) ~= '\'
            folder = [folder '\'];
        end
        GUI.scFolder = folder;
        set(GUI.scF, 'String', folder);
        scr_update(['Script folder is set to ' folder]);
        scUpdate_Callback;
    end
end

end