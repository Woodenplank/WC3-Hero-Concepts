--https://www.hiveworkshop.com/attachments/lightninglist-png.116282/
lightning_names = {
    ["Chain Lightning Primary"]  = "CLPB",
    ["Chain Lightning Secondary"]  = "CLSB",
    ["Drain"]  = "DRAB",
    ["Drain Life"]  = "DRAL",
    ["Drain Mana"]  = "DRAM",
    ["Finger of Death"]  = "AFOD",
    ["Forked Lighting"]  = "FORK",
    ["Healing Wave Primary"]  = "HWPB",
    ["Healing Wave Secondary"]  = "HWSB",
    ["Lightning Attack"]  = "CHIM",
    ["Magic Leash"]  = "LEAS", --[[GUI: Aerial Shackles]]
    ["Mana Burn"]  = "MBUR",
    ["Mana Flare"]  = "MFPB",
    ["Spirit Link"]  = "SPLK"
}
---@param codename string
---@param checkVisibility boolean
function AddLightningEffect(codename, checkVisibility, x1, y1, z1, x2, y2, z2)
     --[[If checkVisibility is true, the lightning won't be created and the function will return null unless the local player currently has visibility of at
        least one of the endpoints of the to be created lightning.)]]
    return AddLightningEx(lightning_names[codename], checkVisibility, x1, y1, z1, x2, y2, z2)
end