function scUpdate_Callback(~, ~)

global GUI

list = dir(GUI.scFolder);
scripts = {};
nn = length(list);
cc = 1;
cv = 1;
for ii = 1:nn
    if ~list(ii).isdir
        if strcmp(list(ii).name(end-1:end), '.m')
            scripts{cc} = list(ii).name(1:end-2);
            if strcmp(list(ii).name(1:end-2), GUI.scFName)
                cv = cc;
            end
            cc = cc + 1;
        end
    end
end
if isempty(scripts)
    scripts = {' '};
end
set(GUI.scFN, 'String', scripts);
set(GUI.scFN, 'Value', cv);
GUI.scFName = scripts{cv};