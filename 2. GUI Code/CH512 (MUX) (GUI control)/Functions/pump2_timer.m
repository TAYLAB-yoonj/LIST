function pump2_timer(~, ~, values, vleng)

global vc p2

p2.ts = p2.ts +1;
if p2.ts > vleng
    p2.ts = 1;
end

vc = vc_set_bits_ac(vc, p2.num, values(p2.ts,:));

end