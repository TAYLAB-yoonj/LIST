function pause_seq_Callback(hObject, eventdata, handles)
global GUI

    if GUI.seqPause==0
        GUI.seqPause=1;
    else
        GUI.seqPause=0;
    end
end