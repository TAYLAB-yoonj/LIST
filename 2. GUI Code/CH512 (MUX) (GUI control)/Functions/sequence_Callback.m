function sequence_Callback(src,event)

global GUI vc p1 p2 p3
    val=get(src,'value');
    check = get(src, 'UserData');
    GUI.button(check+1);
end