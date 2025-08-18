function scRun_Callback(hObject, eventdata)

global GUI

path(GUI.scFolder, path);
scr_fname = GUI.scFName;

if GUI.scRunning == 1
    if GUI.scPause == 1
        GUI.scPause = 0;
        GUI.scPauseStart = 0;
        set(GUI.scRun, 'BackgroundColor', 'green');
        set(GUI.scRun, 'String', 'Pause');
    else
        GUI.scPause = 1;
        GUI.scPauseStart = now;
        set(GUI.scRun, 'BackgroundColor', 'yellow');
        set(GUI.scRun, 'String', 'Resume');
    end
elseif ~exist(scr_fname, 'file')
    errordlg('Cannot find the script!', 'Script');
else
    try
        GUI.scRunning = 1;
        GUI.scStop = 0;
        GUI.scPause = 0;
        GUI.scPauseStart = 0;
        set(GUI.scRun, 'BackgroundColor', 'green');
        set(GUI.scRun, 'String', 'Pause');
        set(GUI.scStopB, 'BackgroundColor', 'red');
        scr_update([scr_fname ' Script started!']);
        
        eval(scr_fname);
        
        if GUI.scStop == 1
            scr_str = ['Script ' GUI.scFName ' stopped'];
        else
            scr_str = ['Script ' GUI.scFName ' ended'];
        end
        scr_update(scr_str);
        
    catch
        scr_str = ['Error while running the script: ' GUI.scFName 10 13 lasterr];
        errordlg(scr_str, 'Script');
        scr_update(scr_str);
    end
    rmpath(GUI.scFolder);
    GUI.scRunning = 0;
    GUI.scStop = 0;
    GUI.scPause = 0;
    GUI.scPauseStart = 0;
    set(GUI.scRun, 'BackgroundColor', [212 208 200]/255);
    set(GUI.scRun, 'String', 'RUN');
    set(GUI.scStopB, 'BackgroundColor', [212 208 200]/255);
end
end