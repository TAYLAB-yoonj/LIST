function set_mux_CCC4(mux, chnum)
    global vc
    % 0 means close, 1 means open
    stat = [0 0 0 0 0 0 0 0 0 0];
    
    if chnum >= 1 && chnum <= 16
        stat(2) = 1;
    elseif chnum >= 17 && chnum <= 32
        stat(1) = 1;
    elseif chnum == 98
        stat = ones(1,length(stat));
    elseif chnum == 99
        stat = zeros(1,length(stat));
    else
        errordlg('Ch number not recognized.','chnum Error');
        return
    end
    
    if (chnum >= 1 && chnum <= 8) || (chnum >= 25 && chnum <= 32)
        stat(4) = 1;
    else
        stat(3) = 1;
    end 
    
    if (chnum >= 1 && chnum <= 4) || (chnum >= 9 && chnum <= 12) || (chnum >= 21 && chnum <= 24) || (chnum >= 29 && chnum <= 32)
        stat(6) = 1;
    else
        stat(5) = 1;
    end 
    
    z = find([1 2 5 6 9 10 13 14 19 20 23 24 27 28 31 32] == chnum, 1);
    if ~isempty(z)
        stat(8) = 1;
    else
        stat(7) = 1;
    end 

    z = find([1:2:15,18:2:32] == chnum, 1);
    if ~isempty(z)
        stat(10) = 1;
    else
        stat(9) = 1;
    end 
    
    if chnum == 98
        stat = ones(1,length(stat));
    elseif chnum == 99
        stat = zeros(1,length(stat));
    end
    
    vc = vc_set_bits_ac(vc, mux, stat);
end