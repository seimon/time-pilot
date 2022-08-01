pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include time_pilot.lua
__gfx__
00000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050050000000
0000cccf5aaa0000000000000c5000000000000000c000000000000000000000000000000000000000000000000000000000ff0000000000000055fff0000000
000000ff5500000000003330ff5aa00000000033000c00000000000000000000000000000000000000000000000000000035ff0000000000000055fff0000000
03333333333333300003333335500a000000033333ff5000000000330000c000000000000000000000ff0000033000000033ff00000000000000055f50000000
3333333333333333000333333333000000000333333ffa000000033333000c0000000000033333c005fff0003333000000535ff0000000000000005ff5000000
3333333333333333000533333333330000000533333350a000000333333ffc000ff00000000032c00fffffff3333300000005fff005330000000005fffff0000
f3333333333333350000553333333330000000533333300000000f333333fff00fff00000fff3fc00555fff233333000000055fff53333000000005f22f33330
0ff5fff22555f5500000005533333330000000f233333300ff00f223333335a0055ffff0fff3ff5000055ff33333300c000005ff233333000000055533333330
000000fff5000000000000f2f533333000000ffff3333330fffffff33333350a3335fffffff3f5a0000055533333ffc00000055f333330000005f33333333330
0000005ff500000000000fff555333500000ffff5533333053355555f333500a0055fff5553555a0000000533333ffc000000053333330000053333333333330
0000005f550000000000fff5500555000fffff55505333500555555f555550000000555fff3f50a00000000f33335500000005333333f0c00533333333333000
000000ff5500000000055f55000000000fff555000055500055000000555000000000055555550000000000555350a0000005333333ffc0005333333333f0000
00000fff5f50000000f55f550000000000f333000000000000000000000000000000000000000000000000005550a00000005333335f50000033333335ff0c00
0000ffff5ff500000000fff5000000000033f0000000000000000000000000000000000000000000000000000000a00000005333300a000000033330555cc000
000000f00f000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000053300a0000000000000aa000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000000900000000000000000000000000
0000000000000000000000000000000000000000000f20000000f8000000f80009078f0009000000009000000067000000967000000000000000000000000000
00000fffffff0000fb00000000000000a000000000082000000082000007820000762200006789000067000009d67000000d6700000000000000000000000000
c00fff7fffffff0093b0000000000c00a00000000007d00000076d000976d000006d000000dd220000d68f00000d8f0000008f00000000000000000000000000
c0f77ffffffffff0933b000000033c3fa00000000006d0000096d000006d00000090000009000000090d22000000220000002800000000000000000000000000
cf7fffffffffffffbbb3bbffbbbbfcbbbffb00000090090000000900000900000000000000000000000000000000000000000000000000000000000000000000
5fffffffffffffff55533ee333339993ee3770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aefefefefefefefe0533ee3535354a3ee333efb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0efefefefefefe00052e35555553aee333ee33b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a00eeeeeeeeeee000000555555535a23532e53550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000eeeeeee00000000000555552255522555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007a7a000000000000000000000000000000000000aaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
07a7a7a000a7a00000a7a00000000000000000000aa9a9990000000000000000000007a7a7000000000000000000000000000000000000000000000000000000
7a7a7a7a0a7a7a000a7a7a00007a7a0000000000aa9a99999000000000000000000a7a7a7a7a0000000000000000000000000000000000000000000000000000
a7a7a7a6a7a7a790a7a7979007a7a79000a7a700a9a99999900000000000000000a7a7a7a7a7a000000000000000000000000000000000000000000000000000
7a7a7a697a7a79707a7a79600a7a79600a7a7970a00090009000000000000000007a7a7a7a7a7a00000000000000000000000000000000000000000000000000
97a6a6a6979797909797960006a7979006a7979007007007070070070000000007a7a7a7a7a7a790000000000000000000000000000000000000000000000000
096a6a60097979000969600000696900006969000070707007070070000000000a7a7a7a7a7a7a70000000000000000000000000000000000000000000000000
009696000096900000000000000000000000000000077700007777000000000007a7a7a7a7a7a790000000000000000000000000000000000000000000000000
00000000000b0000005555000077770000f000000ffff0000999000000000000097a7a7a7a6a7960000000000000000000000000000000000000000000000000
0000000000b0b00005ffff500777777033333000ffffff00999990000000000007a7a6a7a7a79790000000000000000000000000000000000000000000000000
0b000000000000005f5ff5f57777777733333000ffffff00606060000000000009797a7a79797960000000000000000000000000000000000000000000000000
b0000000000000005ffffff57777777700f000000ffff00006660000000000000097979797979600000000000000000000000000000000000000000000000000
0b000000000000005ffffff577777777033300000022000000200000000000000009797979796900000000000000000000000000000000000000000000000000
00000000000000005f5ff5f577777777000000000000000000000000000000000000069696969000000000000000000000000000000000000000000000000000
000000000000000005ffff5007777770000000000000000000000000000000000000000969600000000000000000000000000000000000000000000000000000
00000000000000000055550000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000007aaaaaaa9937aaa37a33333333337a37aaaaaaaaa33337aaaaaaaa337aaa37aaa333333337aaaaaaa337aaaaaaaaa333
000007a7a70000000000000000000000f9999999994f9994f9a333333337994f9999999994333f9999999993f9994f999433333379999999993f999999999433
000a7a7a7a7a00000000007a7a00000099999999994f9994f99a33333379994f9999999994433f9999999994f9994f9994433333f99999999949999999999443
00a7a7a7a7a7a000000007a7a7a700003ccf999ccc4f9994f999a3333799994f999cccccc4433f999ccf9994f9994f9994433333f999ccf99944ccf999ccc443
007a7a7a7a7a7a0000007a7a7a7a700033cf9994cccf9994f9999a33a999994f999aaacccc433f999aa99994f9994f9994433333f9994cf999443cf9994ccc40
07a7a7a7a7a7a7900007a7a7a7a7a000333f9994400f9994f99999aa9999994f9999994000000f9999999994f9994f9994400333f99944f9994403f999440000
0a7a7a7a7a7a7a70000a7a7a7a7a7a00333f9994400f9994f999999999f9994f9999994400000f99999999d4f9994f9994400333f99944f9994400f999440000
07a7a7a7a7a7a79000a7a7a7a7a7a600333f9994400f9994f99949999cf9994f999ccc4400000f999cccccddf9994f9994400333f99944f9994400f999440000
097a7a7a7a6a7960007a7a7a7a797900333f9994400f9994f9994499ccf9994f999aaaaa93333f9994cccccdf9994f9999999993f999aa99994400f999440033
07a7a6a7a7a797900097a7a7a7a79600333f9994400f9994f999440cccf9994f9999999994003f9994400000f9994f999999999499999999994400f999440033
09797a7a79797960006a7a7a79797900333999944009999499994400cc9999499999999994403999944000009999499999999994499999999dd4009999440033
00979797979796000006a797979690003333ccc44003ccc44ccc4400000ccc44ccccccccc44033ccc44000000ccc44ccccccccc443cccccccddd003ccc440033
0009797979796900000069797960000033333ccc40033ccc40ccc4003000ccc40ccccccccc43333ccc40033333ccc40ccccccccc433cccccccd00033ccc40033
00000696969690000000069690000000333333300003333000030000330003000030000000000333300003333333000030000000000300000000003333000033
00000009696000000000000000000000333333300003333000030000333333000030000000000333300003333333000030000000000300000000003333000033
00000000000000000000000000000000333333300003333000030000333333000030000000000333300003333333000030000000000330000000033333000033
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000800000000000800000000000800000000000800000000028000000
00000000000000000000000000000000000000000000000000000000000000880000000008800000000008820000000008820000000000800000000028866000
00000000000000000000000000000000000000000000000000000000000008820000000088800000000088820000000008820000000000880000000002886600
00000000000000000000000000000000000000000000000000880000000888200000000088800000000088220000000088820000000000880000000002888888
28000000000000000000000000000000008888800000000088820000777888000000000888200000000888220000000088820000000000880000000006886622
28800000000008800000000000000007788882200000777888220022277882000000077788200000000888200000000078820000000002788000000000000000
28888770000008888277888888088877888220002222772882202222872820000000227728200000000782200000000078200000000002788000000000000000
88228777888002888877788820888882222200008888222820002288822220000002227222200000072722200000007877220000007002778000000000000000
02888288888888828828882200882888220000088888882220007888888200000022282282200000222722200000078872222700007022778200000000000000
02288822222200288882200000028888277000008828822000000082882070000022888888270002228228200000088822882700007282788880000000000000
07288277700000288827700000002882200000000288827000000022882700000028882888200002288888200000888282888700002882882880000000000000
00022000000000728820000000070820000000000028270000000000282000000070888888200007888288220000222882888200028888882228000000000000
00000000000000002200000000000000000000000008200000000000020000000000008882200000088888820000700822882200022002882002000000000000
00000000000000000000000000000000000000000072000000000000700000000000000222000000000228820000000022000200007000800000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000700000000000007200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000070000000000007000000070008000700000000000000000000000000
00000000000000000000000000000000000000000088220000000000087200000000028822000007000882200000220088220220000000000000000000000000
00000000000000280000000000002882000000000288220000000000882220000072228822200000222882220000882288288820000000000000000000000000
28800000000000288200000000002882200000000288227000000022282220000028828822200008882882220000088888228200000000000000000000000000
28888000000000888800000000002887770000002888772700000288888727000088888272870008888877270000078887228700000000000000000000000000
08888770000000888877000000022282777000028888772000000888887770700088888277270002888877270000070277722700000000000000000000000000
08288777880007222877780000788888227800028888277800000888882770000022228277200000228877200000070077720700000000000000000000000000
02888228888802888822888000228888888800022222828880000222222278000000702887800000722227800000000087220000000000000000000000000000
72888828888880288882888880022282288880000700288880000000702888000000070288800000070288800000000087220000000000000000000000000000
02888220222200022228228888000007022888000070028880000000072888800000000288800000070288800000000088200000000000000000000000000000
00222770000000000070002220000000000288800000000288000000000288800000000028880000000028800000000088200000000000000000000000000000
00000000000000000007000000000000000022000000000028000000000028800000000002880000000028800000000088200000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000002800000000000280000000028800000000008000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000080000000002800000000008000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000
0000000000000000005555055555055555055b550555500055550555550555550555550555500005000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
000000000000000005555505555505555bbbbbbbbb55550555550555550555550555550555550005550000000000000000000000000000000000000000000000
000000000000000000000000000000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000005555505555505555b0555550b05550555550555550555550555550555550005550005550000000000000000000000000000000000000000
000000000000000005555505555505555b0555550b05550555550555550555550555550555550000050000050000000000000000000000000000000000000000
00000000000000000b55b50b55b50b55bb0555550bb55b05b55b05b55b05b55b05b55b05b55b0005550005550000000000000000000000000000000000000000
000000000000000005055005055005055b0555550b00550550550550550550550550550550550005000005000000000000000000000000000000000000000000
000000000000000005555505555505555b0555550b05550555550555550555550555550555550005550005550000000000000000000000000000000000000000
000000000000000000000000000000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000005555505555505555bbbbbbbbb05550555550555550555550555550555550005000500050005000000000000000000000000000000000000
0000000000000000055555055555055555000b000005550555550555550555550555550555550005000500050005000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005000500050005000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000500050005000000000000000000000000000000000000
0000000000000000005555055555055555055b550555500055550555550555550555550555500005000500050005000000000000000000000000000000000000
00000000000000004000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000
00000000000000000055550555550555550555550555500055550555550555550555550555500005000500000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000555000500000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000005000500000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005000555000500000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000500000500000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000555000500000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005000500000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005050000000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005055500000000000000000000000000000000000000000000
0000000000000000055555055555055555055b550555550555550555550555550555550555550005050500000000000000000000000000000000000000000000
00000000000000000555550555550555550555050555550555550555550555550555550555550005050500000000000000000000000000000000000000000000
00000000000000000555550555550555550555550555550555550555550555550555550555550005050500000000000000000000000000000000000000000000
0000000000000000005555055555055555055b550555500055550555550555550555550555500005055500000000000000000000000000000000000000000000
00000000000000004000000000000000000000000000004000000000000000000000000000004000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005000050000050500055500055500055500055500050500050000005000000000000000000000000000000000000000000000000000000
00000000000000000005000050000050500000500000500000500000500050500050000005000000000000000000000000000000000000000000000000000000
00000000000000000005000055500055500005500005500005500005500055500055500005000000000000000000000000000000000000000000000000000000
00000000000000000005000050500000500000500000500000500000500000500050500005000000000000000000000000000000000000000000000000000000
00000000000000000005000055500000500055500055500055500055500000500055500005000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055500055500005000005000005000005000055500055500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000500000500005000005000005000005000000500000500000000000000000000000000000000000000000000000000000000000
00000000000000000000000055500005500005000005000005000005000005500055500000000000000000000000000000000000000000000000000000000000
00000000000000000000000050000000500005000005000005000005000000500050000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055500055500005000005000005000005000055500055500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055500055500055500055500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000500000500000500000500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055500055500055500055500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000050000050000050000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055500055500055500055500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555550000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555500000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444400666000006660666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444000606006006060006000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000606000006060666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444000606006006060600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444400666000006660666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
000000000000000000003f3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
c80800001c6711a671186711566112661106510e6410b631096210761105611036110060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
000100002852325543225531f5531c551195511654113541105310c53109521065210351100511005010050100501005010050100501005010050102500025000150003500025000150001500025000250001500
c804000001451054410d4311a4212d411014010240102401014010040100401004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401
c80800000567106671066610565103641036310262102611016110061100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
a20200041b6401b6301b6401b63035600206002060020600206002160020600206002060020600206002060020600206002060020600206002060020600206002060020600206002060020600206002060020600
a20100040864008620086400862035600206002060020600206002160020600206002060020600206002060020600206002060020600206002060020600206002060020600206002060020600206002060020600
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
c80600000c6510a63108621066111a601296012960129601016010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
0006000031563305432e7232b713287012270102501005010a5010250109501065010350100501005010050100501005010050100501005010050102500025000150003500025000150001500025000250001500
000300001f6431b62317613126030b6012260102601006010a6010260109601066010360100601006010060100601006010060100601006010060102600026000160003600026000160001600026000260001600
000400002a57326563225431e513285012250102501005010a5010250109501065010350100501005010050100501005010050100501005010050102500025000150003500025000150001500025000250001500
010d00000c0530445504255134453f6150445513245044550c0531344513245044553f6150445513245134450c0530445504255134453f6150445513245044550c0531344513245044553f615044551324513445
010d00000c0530045500255104453f6150045510245004550c0530044500245104553f6150045510245104450c0530045500255104453f6150045510245004550c0531044510245004553f615004551024500455
010d00000c0530245502255124453f6150245512245024550c0531244512245024553f6150245502255124450c0530245502255124453f6150245512245024550c0530244512245024553f615124550224512445
010d00002b5552a4452823523555214451f2351e5551c4452b235235552a445232352d5552b4452a2352b555284452a235285552644523235215551f4451c2351a555174451e2351a5551c4451e2351f55523235
010d000028555234452d2352b5552a4452b2352f55532245395303725536540374353b2503954537430342553654034235325552f2402d5352b2502a4452b530284552624623530214551f24023535284302a245
010d00002b5552a45528255235552b5452a44528545235452b5352a03528535235352b0352a03528735237352b0352a03528735237351f7251e7251c725177251f7151e7151c715177151371512715107150b715
0003000011070160701a0702007024060290502d040320303502037010390103b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 07084344
00 07084344
00 09084344
00 09084344
00 0a0b4344
02 090b4344
01 0c0d4344
00 0e0d4344
00 0c0d4344
00 0e0d4344
00 0c0f4344
00 0c0f4344
02 0e104344
01 11124344
00 11124344
00 11134344
00 14134344
02 14154344
01 1a424344
00 1b424344
00 1c424344
00 1a424344
00 1a1d4344
00 1b1d4344
00 1c1e4344
02 1a1f4344

