function open_all_Callback(hObject, eventdata, handles)

global GUI vc

if vc.info(1).status==0 && vc.info(2).status==0
    nums = 0:GUI.tot-1;
    values = ones(1, GUI.tot);
    vc = vc_set_bits_ac(vc, nums, values);
    for valvenum=1:GUI.tot
        set(GUI.button(valvenum),'BackgroundColor',GUI.oncolor,... %blue = open
            'string',['#',get(GUI.button(valvenum),'UserData') ' opened'],'FontSize',10,'value',0)
    end
    scr_update('All valves opened.');
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
        nums = 0:GUI.tot-1;
        values = ones(1, GUI.tot);
        vc = vc_set_bits_ac(vc, nums, values);
        for valvenum=1:GUI.tot
            set(GUI.button(valvenum),'BackgroundColor',GUI.oncolor,... %blue = open
                'string',['#',get(GUI.button(valvenum),'UserData') ' opened'],'FontSize',10,'value',0)
        end
        scr_update('All valves opened.');
    end
end