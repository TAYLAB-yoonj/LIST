%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function that times the pause when a script is paused
% After the defined time length the pause is released
function scPause_Callback(msg)

global GUI

done = 0;
while ~VCdata.Scr.Stop && VCdata.Scr.Pause  && ~done
    pause(0.98);
    % pause might have been released during the 0.98sec wait
    if VCdata.Scr.Pause
        [done, tremain] = VCtimer(VCdata.Scr.PauseStart, VCdata.Scr.PauseLength);
        str = [msg 10 13 'Paused - ' num2str_pad(tremain(2), 2) ':' num2str_pad(tremain(3), 2)];
        set(VChs.Msg, 'String', str);
        if ~done && ((tremain*[3600; 60; 1]) <= 10)
            % Beep on the last 10 seconds of the pause
            beep;
        end
        if VCdata.Scr.Pause && done
            % Release pause
            ScriptRun_Callback(VChs.ScriptRun, []);
        end
    end
end