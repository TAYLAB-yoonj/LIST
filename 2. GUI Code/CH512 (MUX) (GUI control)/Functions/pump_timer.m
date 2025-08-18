function pump_timer(obj, event, check, values, vleng)

global GUI vc p1ts

p1ts = p1ts +1;
if p1ts > vleng
    p1ts = 1;
end

ps=get(GUI.button(check),'Max')...
    -get(GUI.button(check),'value')+20;
set(obj, 'Period', ps/500);

numbers = str2num(get(GUI.button(check+1),'String'));
vc = vc_set_bits_ac(vc, numbers, values(p1ts,:));

end