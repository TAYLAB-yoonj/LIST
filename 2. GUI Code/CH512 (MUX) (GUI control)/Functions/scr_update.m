function scr_update(scrt)

global GUI

iscrt = get(GUI.scrt, 'string');
if length(iscrt) > 50
    iscrt = iscrt(1:50,1);
end
scrt = [{ [datestr(clock, 'yyyy-mm-dd HH:MM:SS') '   ' scrt] }; iscrt ];
set(GUI.scrt, 'string', scrt);
end