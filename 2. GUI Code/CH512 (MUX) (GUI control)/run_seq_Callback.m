function run_seq_Callback(hObject, eventdata, handles)
global GUI vc

GUI.seqStop=0;
GUI.seqPause=0;
GUI.button(GUI.tot+6).Enable='off';
dataSeq=GUI.tab.Data;
dataSeqValve=dataSeq(:,1);
dataSeqDelay=dataSeq(:,2);
dataSeqRun=dataSeq(:,4);

nc=size(dataSeq,1);

seq=0;

scr_update('Start running the sequence');
while GUI.seqStop==0 && seq<nc
    if GUI.seqPause==0
        seq=seq+1;
        GUI.button(GUI.tot+7).BackgroundColor='y';
        GUI.button(GUI.tot+8).BackgroundColor='r';
        if dataSeqRun{seq}==1
            if ~isempty(dataSeqValve{seq}) && ~isempty(dataSeqDelay{seq})
            try
                scr_update(['Running sequence ' num2str(seq)]);
                aa=cell2mat(textscan(dataSeqValve{seq}, '%f'))';
                delay=str2double(dataSeqDelay{seq});
                vc = vc_set_bits_ac(vc, aa, ones(1,numel(aa)));
                disp(delay)
                pause(delay)
                vc = vc_set_bits_ac(vc, aa, zeros(1,numel(aa)));
            catch e
                errordlg('Error while running the sequence!');
                fprintf(1,'\nThe identifier was: %s',e.identifier);
                fprintf(1,'\nThere was an error: %s',e.message);
            end
            elseif isempty(dataSeqValve{seq}) || isempty(dataSeqDelay{seq})
                GUI.seqStop=1;
                GUI.button(GUI.tot+7).BackgroundColor=[.7 .7 .7];
                GUI.button(GUI.tot+8).BackgroundColor=[.7 .7 .7];
                GUI.button(GUI.tot+6).Enable='on';
                errordlg(['You need to indicate the Valves and Time you are controlling in seq ' num2str(seq)])
                scr_update(['You need to indicate the Valves and Time you are controlling in seq ' num2str(seq)]);
            end
        end
    else
        scr_update('The sequence has been paused!!!');
        pause(10)
    end
end

    GUI.button(GUI.tot+7).BackgroundColor=[.7 .7 .7];
    GUI.button(GUI.tot+8).BackgroundColor=[.7 .7 .7];
    GUI.button(GUI.tot+6).Enable='on';

    ll=[dataSeq{:,4}];
    iseq=find(ll==1,1);
    if ~isempty(dataSeqValve{iseq}) 
            try
                scr_update(['Returning to initial condition']);
                aa=cell2mat(textscan(dataSeqValve{1}, '%f'))';
                vc = vc_set_bits_ac(vc, aa, ones(1,numel(aa)));
            catch e
                errordlg('Error while running the sequence!');
                fprintf(1,'\nThe identifier was: %s',e.identifier);
                fprintf(1,'\nThere was an error: %s',e.message);
            end
    end
    
    valvenum=0;
    inv=[];
    inc=[];
    for nrow=1:10
    for ncol=1:8
        valvenum=valvenum+1;
        inc=[inc abs(GUI.button(valvenum).Value-1)];
        inv=[inv valvenum-1];
    end
    end
    
    vc = vc_set_bits_ac(vc, inv, inc);
