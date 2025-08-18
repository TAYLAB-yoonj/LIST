function pump1_timer(~, ~, values, vleng)

global vc p1

p1.ts = p1.ts +1;
if p1.ts > vleng
    p1.ts = 1;
end

vc = vc_set_bits_ac(vc, p1.num, values(p1.ts,:));

end