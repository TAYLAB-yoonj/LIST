function valve_toggle_Callback(hObject, eventdata, handles)

global GUI vc

val=get(hObject,'value');
valnum=get(hObject,'UserData');

if val==1 % button down
    set(hObject,'BackgroundColor',GUI.offcolor,... %yellow = closed
        'string',['#',get(hObject,'UserData'),' closed'],'FontSize',10);
    if vc.info(1).status==0 && vc.info(2).status==0
        numbers = str2num(valnum);
        values=0; %open
        vc = vc_set_1bit(vc, numbers, values);
        scr_update(['Valve' valnum ' closed.']);
    else
        check=0;
        while (vc.info(1).status==1 || vc.info(2).status==1) && check<GUI.tries
            check=check+1;
            vc = vc_close(vc, 1);
            vc.info(1).status = 0;
            vc.info(2).status = 0;
            vc = vc_open_setup(vc);
        end
        if check==GUI.tries
            disp(['Status of box#1 = ' num2str(vc.info(1).status)]);
            disp(['Status of box#2 = ' num2str(vc.info(2).status)]);
            scr_update('Connecting to control box failed. Replug the Controlbox and restart the GUI');
        else
            scr_update([num2str(check) ' trie(s) to communicate to controlbox']);
            numbers = str2num(valnum);
            values=0; %open, valve light on
            vc = vc_set_1bit(vc, numbers, values);
            scr_update(['Valve' valnum ' closed.']);
        end
    end
    
elseif val==0 %button up
    set(hObject,'BackgroundColor',GUI.oncolor,... %blue = open
        'string',['#',get(hObject,'UserData') ' opened'],'FontSize',10);
    if vc.info(1).status==0 && vc.info(2).status==0
        numbers = str2num(valnum);
        values=1; %closed, valve light off
        vc = vc_set_1bit(vc, numbers, values);
        scr_update(['Valve' valnum ' opened.']);
    else
        check=0;
        while (vc.info(1).status==1 || vc.info(2).status==1) && check<GUI.tries
            check=check+1;
            vc = vc_close(vc, 1);
            vc.info(1).status = 0;
            vc.info(2).status = 0;
            vc = vc_open_setup(vc);
        end
        if check==GUI.tries
            disp(['Status of box#1 = ' num2str(vc.info(1).status)]);
            disp(['Status of box#2 = ' num2str(vc.info(2).status)]);
            scr_update('Connecting to control box failed. Replug the Controlbox and restart the GUI');
        else
            scr_update([num2str(check) ' trie(s) to communicate to controlbox']);
            numbers = str2num(valnum);
            values=1; %closed, valve light off
            vc = vc_set_1bit(vc, numbers, values);
            scr_update(['Valve' valnum ' opened.']);
        end
    end
end
end