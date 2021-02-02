local addonName, ns = ...
local B, C, _, DB = unpack(_G.NDui)

ns[1] = B
ns[2] = C
ns[3] = {}
ns[4] = DB
ns[5] = {}

ns.oUF = _G.NDui.oUF

NDuiPlusDB, NDuiPlusCharDB = {}, {}

_G[addonName] = ns