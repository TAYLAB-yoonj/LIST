function pump3_timer(~, ~, values, vleng)

global vc p3

p3.ts = p3.ts +1;
if p3.ts > vleng
    p3.ts = 1;
end

vc = vc_set_bits_ac(vc, p3.num, values(p3.ts,:));

end