function pump_Callback(hObject, ~, ~)

global GUI vc p1 p2 p3

val=get(hObject,'value');
check = get(hObject, 'UserData');
if strcmp(check, 'Pump1')
    check = GUI.tot+5;
elseif strcmp(check, 'Pump2')
    check = GUI.tot+8;
elseif strcmp(check, 'Pump3')
    check = GUI.tot+11;
else
    errordlg('pump_Callback cannot recognize which pump to operate.');
    check = 0;
end

if check ~= 0
    if val==1 % button down
        set(hObject,'BackgroundColor',GUI.offcolor,... %yellow = pump running
            'string',[get(hObject, 'UserData') ' running'],'FontSize',8);
        if check == GUI.tot+5
            GUI.p1Running = 1;
            p1.ts = 0;
            p1.num = str2num(get(GUI.button(check+1),'String'));
            ps=get(GUI.button(check),'Max')-get(GUI.button(check),'value')+20;
            set(p1.t, 'Period', ps/500);
            scr_update(['Pump1 started pumping at ' num2str(ps/500) ' sec period.']);
            start(p1.t);
        elseif check == GUI.tot+8
            check = GUI.tot+8;
            GUI.p2Running = 1;
            p2.ts = 0;
            p2.num = str2num(get(GUI.button(check+1),'String'));
            ps=get(GUI.button(check),'Max')-get(GUI.button(check),'value')+20;
            set(p2.t, 'Period', ps/500);
            scr_update(['Pump2 started pumping at ' num2str(ps/500) ' sec period.']);
            start(p2.t);
        elseif check == GUI.tot+11
            GUI.p3Running = 1;
            p3.ts = 0;
            p3.num = str2num(get(GUI.button(check+1),'String'));
            ps=get(GUI.button(check),'Max')-get(GUI.button(check),'value')+20;
            set(p3.t, 'Period', ps/500);
            scr_update(['Pump3 started pumping at ' num2str(ps/500) ' sec period.']);
            start(p3.t);
        end
        
    elseif val==0
        set(hObject,'BackgroundColor',GUI.menucolor,...
            'string',[get(hObject, 'UserData') ' stopped'],'FontSize',8);
        if check == GUI.tot+5
            GUI.p1Running = 0;
            stop(p1.t);
            vc = vc_set_bits_ac(vc, p1.num, [0 0 0]);
            scr_update('Pump1 stopped pumping.');
        elseif check == GUI.tot+8
            GUI.p2Running = 0;
            stop(p2.t);
            vc = vc_set_bits_ac(vc, p2.num, [0 0 0]);
            scr_update('Pump2 stopped pumping.');
        elseif check == GUI.tot+11
            GUI.p3Running = 0;
            stop(p3.t);
            vc = vc_set_bits_ac(vc, p3.num, [0 0 0]);
            scr_update('Pump3 stopped pumping.');
        end
        
    end
end
end