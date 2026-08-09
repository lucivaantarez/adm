local __ok,__err=pcall(function()
local Players=game:GetService("Players") local RS=game:GetService("ReplicatedStorage") local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService") local TPS=game:GetService("TeleportService") local LP=Players.LocalPlayer local HS=game:GetService("HttpService")
local VERSION="2.1.1a" local MAX_OFFER=18 local CFG_VER=2
local LOGO_URL="https://raw.githubusercontent.com/lucivaantarez/farm/main/lazyhub-logo.png"
local Fsys=require(RS:WaitForChild("Fsys")).load
local function lm(n) local ok,m=pcall(function() return Fsys(n) end) return ok and m or nil,ok end
local ClientData,cd_ok=lm("ClientData") local InventoryDB,idb_ok=lm("InventoryDB") local Router,rt_ok=lm("RouterClient") local UIManager,um_ok=lm("UIManager")
local KindDB local kindC={} local function ekdb() if KindDB then return true end local ok,m=pcall(function() return Fsys("KindDB") end) if ok and m then KindDB=m return true end return false end
local function kget(id) if not id then return nil end if kindC[id] then return kindC[id] end if ekdb() then local ok,d=pcall(function() return KindDB[id] end) if ok and type(d)=="table" then kindC[id]=d return d end end return nil end
local Rem={} local function cr(n) if not Router then Rem[n]={ok=false} return end local ok,r=pcall(function() return Router.get(n) end) Rem[n]={ok=ok,ref=ok and r or nil} end
cr("TradeAPI/SendTradeRequest") cr("TradeAPI/AddItemToOffer") cr("TradeAPI/RemoveItemFromOffer")
local CFG_PATH="lazyhub_config.json"
local Config={_v=CFG_VER,opacity=1,notify_sound=true,grid_density="normal",trade_cats={pets=true},auto_cats={pets=true}}
local function scfg() pcall(function() writefile(CFG_PATH,HS:JSONEncode(Config)) end) end
local function lcfg() pcall(function() local r=HS:JSONDecode(readfile(CFG_PATH)) if r._v==CFG_VER then for k,v in pairs(r) do if Config[k]~=nil then Config[k]=v end end end end) end
lcfg()
local function logcrash(m) pcall(function() local p="" pcall(function() p=readfile("lazyhub_crashes.txt") end) writefile("lazyhub_crashes.txt",p.."\n["..os.date("%Y-%m-%d %H:%M:%S").."] "..tostring(m)) end) end
local function logrec(partner,gave,got) pcall(function() local p="" pcall(function() p=readfile("lazyhub_trades.csv") end) if p=="" then p="time,partner,gave,got\n" end local gs,rs={},{} for _,g in ipairs(gave or {}) do table.insert(gs,tostring(g.id or g)) end for _,r in ipairs(got or {}) do table.insert(rs,tostring(r.id or r)) end writefile("lazyhub_trades.csv",p..os.date("%Y-%m-%d %H:%M:%S")..","..tostring(partner)..","..table.concat(gs,";")..","..table.concat(rs,";").."\n") end) end
local C={bg=Color3.fromRGB(0,0,0),rail=Color3.fromRGB(8,8,10),panel=Color3.fromRGB(13,13,16),card=Color3.fromRGB(17,17,21),cell=Color3.fromRGB(21,21,26),cellOn=Color3.fromRGB(32,26,55),chip=Color3.fromRGB(24,24,29),purple=Color3.fromRGB(167,119,255),cyan=Color3.fromRGB(78,231,255),red=Color3.fromRGB(255,82,104),green=Color3.fromRGB(86,226,150),amber=Color3.fromRGB(255,196,74),text=Color3.fromRGB(240,242,250),dim=Color3.fromRGB(150,155,175),muted=Color3.fromRGB(96,100,120),info=Color3.fromRGB(200,203,218)}
local FT,FB,FN,FL=Enum.Font.GothamBlack,Enum.Font.GothamBold,Enum.Font.Gotham,Enum.Font.Code
local RARS={"common","uncommon","rare","ultra_rare","legendary"} local TYPS={"NP","R","F","FR","N","NR","NFR","M","MR","MFR"}
local RCOL={common=Color3.fromRGB(150,155,172),uncommon=Color3.fromRGB(120,220,140),rare=Color3.fromRGB(96,165,250),ultra_rare=Color3.fromRGB(192,132,252),legendary=Color3.fromRGB(255,196,74)}
local function nice(r) if r=="ultra_rare" then return "Ultra-Rare" end return (tostring(r or "?"):gsub("^%l",string.upper)) end
local function comma(n) local s=tostring(math.floor(n or 0)) local k repeat s,k=s:gsub("^(-?%d+)(%d%d%d)","%1,%2") until k==0 return s end
local sndI local function ps(id) if not Config.notify_sound then return end pcall(function() if not sndI then sndI=Instance.new("Sound") sndI.Volume=0.4 sndI.Parent=workspace end sndI.SoundId="rbxasset://sounds/"..id sndI:Play() end) end
local SND={click="electronicpingshort.wav",done="switch.ogg",fail="impact_water.mp3"}
local LOGO=nil pcall(function() if LOGO_URL~="" then local d=game:HttpGet(LOGO_URL) writefile("lazyhub_logo.png",d) LOGO=getcustomasset("lazyhub_logo.png") end end)
local ALL_CATS={{key="pets",label="PETS"},{key="eggs",label="EGGS"},{key="food",label="FOOD"},{key="toys",label="TOYS"},{key="gifts",label="GIFTS"},{key="strollers",label="STROLLERS"},{key="transport",label="VEHICLES"},{key="pet_accessories",label="PET WEAR"},{key="stickers",label="STICKERS"},{key="roleplay",label="ROLEPLAY"}}
local function build_stacks(cf)
    local st={} if not ClientData then return st,{} end local ok_i,inv=pcall(function() return ClientData.get("inventory") end) if not ok_i or not inv then return st,{} end
    local cats=ALL_CATS if cf and next(cf) then cats={} for _,c in ipairs(ALL_CATS) do if cf[c.key] then table.insert(cats,c) end end if #cats==0 then cats=ALL_CATS end end
    for _,ci in ipairs(cats) do local cat=ci.key local rc=cat=="eggs" and "pets" or cat
    local ok2,items=pcall(function() return inv[rc] end) if not ok2 or type(items)~="table" then items={} end
    for u,item in pairs(items) do pcall(function() if type(item)~="table" or not item.id then return end local id=item.id
    local nm,img,rar,ise=tostring(id),"","item",false
    if rc=="pets" then local o3,def=pcall(function() return InventoryDB.pets[id] end)
    if o3 and type(def)=="table" then nm=def.name or nm img=def.image or "" rar=tostring(def.rarity or "?"):lower() ise=def.is_egg and true or false end
    if cat=="eggs" and not ise then return end if cat=="pets" and ise then return end
    else local def=kget(id) if def then nm=def.name or nm img=def.image or "" end end
    local tag="" if rc=="pets" and not ise then local p=item.properties or {}
    if p.mega_neon then tag="M" elseif p.neon then tag="N" end if p.flyable then tag=tag.."F" end if p.rideable then tag=tag.."R" end if tag=="" then tag="NP" end
    else tag=ci.label:sub(1,4) end
    local key=cat.."|"..tostring(id).."|"..tag local s=st[key]
    if not s then s={key=key,name=nm,image=img,rarity=rar,tag=tag,category=cat,uniques={}} st[key]=s end
    table.insert(s.uniques,u) end) end end
    local arr={} for _,s in pairs(st) do table.insert(arr,s) end
    table.sort(arr,function(a,b) local ac=a.category or "" local bc=b.category or "" if ac~=bc then return ac<bc end if a.name==b.name then return a.tag<b.tag end return a.name<b.name end)
    return st,arr
end
local gui=Instance.new("ScreenGui") gui.Name="LazyHub" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")
local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=o end
local FADE={} local function tr(o) table.insert(FADE,o) return o end
local root=Instance.new("Frame") root.Size=UDim2.fromOffset(680,660) root.Position=UDim2.new(0.5,-340,0.5,-330) root.BackgroundColor3=C.bg root.BorderSizePixel=0 root.Active=true root.ClipsDescendants=true root.Parent=gui corner(root,16) tr(root)
local header=Instance.new("Frame") header.Size=UDim2.new(1,0,0,50) header.BackgroundColor3=C.panel header.BorderSizePixel=0 header.Active=true header.Parent=root corner(header,16) tr(header)
local hfix=Instance.new("Frame") hfix.Size=UDim2.new(1,0,0,14) hfix.Position=UDim2.new(0,0,1,-14) hfix.BackgroundColor3=C.panel hfix.BorderSizePixel=0 hfix.Parent=header tr(hfix)
local logo=Instance.new("ImageLabel") logo.Size=UDim2.fromOffset(30,30) logo.Position=UDim2.fromOffset(12,10) logo.BackgroundColor3=LOGO and C.panel or C.purple logo.BorderSizePixel=0 logo.Image=LOGO or "" logo.ScaleType=Enum.ScaleType.Fit logo.Parent=header corner(logo,9)
if not LOGO then local l=Instance.new("TextLabel") l.Size=UDim2.fromScale(1,1) l.BackgroundTransparency=1 l.Font=FT l.Text="L" l.TextColor3=Color3.new(1,1,1) l.TextSize=16 l.Parent=logo end
local brand=Instance.new("TextLabel") brand.Size=UDim2.fromOffset(160,18) brand.Position=UDim2.fromOffset(50,6) brand.BackgroundTransparency=1 brand.Font=FT brand.Text="LazyHub" brand.TextColor3=C.text brand.TextSize=17 brand.TextXAlignment=Enum.TextXAlignment.Left brand.Parent=header
local sub=Instance.new("TextLabel") sub.Size=UDim2.fromOffset(200,12) sub.Position=UDim2.fromOffset(51,24) sub.BackgroundTransparency=1 sub.Font=FN sub.Text="by lanavienrose  ·  trade edition" sub.TextColor3=C.purple sub.TextSize=9 sub.TextXAlignment=Enum.TextXAlignment.Left sub.Parent=header
local function hbtn(x,t,col) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(28,28) b.Position=UDim2.new(1,x,0,11) b.BackgroundColor3=C.cell b.BorderSizePixel=0 b.Font=FB b.Text=t b.TextColor3=col b.TextSize=14 b.Parent=header corner(b,9) tr(b) return b end
local closeBtn=hbtn(-38,"X",C.red) local minBtn=hbtn(-72,"-",C.amber)
local tradeHud=Instance.new("Frame") tradeHud.Size=UDim2.new(1,0,0,20) tradeHud.Position=UDim2.fromOffset(0,50) tradeHud.BackgroundColor3=C.purple tradeHud.BackgroundTransparency=0.75 tradeHud.BorderSizePixel=0 tradeHud.Visible=false tradeHud.ZIndex=10 tradeHud.Parent=root
local hudTxt=Instance.new("TextLabel") hudTxt.Size=UDim2.fromScale(1,1) hudTxt.BackgroundTransparency=1 hudTxt.Font=FB hudTxt.Text="" hudTxt.TextColor3=C.text hudTxt.TextSize=9 hudTxt.Parent=tradeHud
local RAIL_W=120 local shell=Instance.new("Frame") shell.Size=UDim2.new(1,0,1,-50) shell.Position=UDim2.fromOffset(0,50) shell.BackgroundTransparency=1 shell.Parent=root
local rail=Instance.new("Frame") rail.Size=UDim2.new(0,RAIL_W,1,0) rail.BackgroundColor3=C.rail rail.BorderSizePixel=0 rail.Parent=shell tr(rail) corner(rail,14)
local rLay=Instance.new("UIListLayout") rLay.Padding=UDim.new(0,4) rLay.SortOrder=Enum.SortOrder.LayoutOrder rLay.Parent=rail
local rPad=Instance.new("UIPadding") rPad.PaddingTop=UDim.new(0,10) rPad.PaddingLeft=UDim.new(0,7) rPad.PaddingRight=UDim.new(0,7) rPad.Parent=rail
local pages,navs={},{} local curTab=""
local function show(name) curTab=name for n,p in pairs(pages) do p.Visible=(n==name) end for n,b in pairs(navs) do local on=(n==name) b.BackgroundColor3=on and C.cellOn or C.rail
local ic,tx,fb=b:FindFirstChild("ic"),b:FindFirstChild("tx"),b:FindFirstChild("fb") if ic then ic.ImageColor3=on and C.cyan or C.muted end if tx then tx.TextColor3=on and C.text or C.muted end if fb then fb.TextColor3=on and C.cyan or C.muted end end end
local navN=0
local function page(nm,lbl,ico) navN=navN+1 local b=Instance.new("TextButton") b.Size=UDim2.new(1,0,0,34) b.BackgroundColor3=C.rail b.BorderSizePixel=0 b.Text="" b.LayoutOrder=navN b.Parent=rail corner(b,8)
local ic=Instance.new("ImageLabel") ic.Name="ic" ic.Size=UDim2.fromOffset(16,16) ic.Position=UDim2.fromOffset(10,9) ic.BackgroundTransparency=1 ic.Image=ico ic.ImageColor3=C.muted ic.ScaleType=Enum.ScaleType.Fit ic.Parent=b
local tx=Instance.new("TextLabel") tx.Name="tx" tx.Size=UDim2.new(1,-34,1,0) tx.Position=UDim2.fromOffset(32,0) tx.BackgroundTransparency=1 tx.Font=FB tx.Text=lbl tx.TextColor3=C.muted tx.TextSize=11 tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=b
local fb=Instance.new("TextLabel") fb.Name="fb" fb.Size=UDim2.fromOffset(16,16) fb.Position=UDim2.fromOffset(10,9) fb.BackgroundTransparency=1 fb.Font=FB fb.Text=lbl:sub(1,1) fb.TextColor3=C.muted fb.TextSize=13 fb.Parent=b task.spawn(function() task.wait(1) if ic.IsLoaded then fb.Visible=false end end)
b.MouseButton1Click:Connect(function() show(nm) end) navs[nm]=b
local p=Instance.new("Frame") p.Name=nm p.Size=UDim2.new(1,-RAIL_W,1,0) p.Position=UDim2.fromOffset(RAIL_W,0) p.BackgroundTransparency=1 p.Visible=false p.Parent=shell pages[nm]=p return p end
local pTrade=page("trade","TRADE","rbxassetid://6034684949")
local pAuto=page("auto","AUTO TRADE","rbxassetid://6034509993")
local pSet=page("settings","SETTINGS","rbxassetid://6031280882")
-- LOG (collapsible strip)
local function mklog(par)
    local col=true local st=Instance.new("Frame") st.Size=UDim2.new(1,-20,0,36) st.Position=UDim2.new(0,10,1,-40) st.BackgroundColor3=C.panel st.BorderSizePixel=0 st.Parent=par st.ClipsDescendants=true corner(st,8) tr(st)
    local lb=Instance.new("ScrollingFrame") lb.Size=UDim2.new(1,-8,1,-4) lb.Position=UDim2.fromOffset(4,2) lb.BackgroundTransparency=1 lb.BorderSizePixel=0 lb.ScrollBarThickness=2 lb.ScrollBarImageColor3=C.muted lb.CanvasSize=UDim2.new() lb.Parent=st
    local ll=Instance.new("UIListLayout") ll.Padding=UDim.new(0,1) ll.SortOrder=Enum.SortOrder.LayoutOrder ll.Parent=lb
    local n,rows=0,{}
    local function lg(msg,c2) n=n+1 local r=Instance.new("Frame") r.Size=UDim2.new(1,0,0,12) r.BackgroundTransparency=1 r.LayoutOrder=n r.Parent=lb
    local t=Instance.new("TextLabel") t.Size=UDim2.fromOffset(38,12) t.BackgroundTransparency=1 t.Font=FL t.Text=os.date("%H:%M") t.TextColor3=C.muted t.TextSize=8 t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=r
    local m=Instance.new("TextLabel") m.Size=UDim2.new(1,-42,1,0) m.Position=UDim2.fromOffset(42,0) m.BackgroundTransparency=1 m.Font=FL m.Text=msg m.TextColor3=c2 or C.info m.TextSize=9 m.TextXAlignment=Enum.TextXAlignment.Left m.TextTruncate=Enum.TextTruncate.AtEnd m.Parent=r
    table.insert(rows,r) while #rows>150 do rows[1]:Destroy() table.remove(rows,1) end
    task.defer(function() lb.CanvasSize=UDim2.fromOffset(0,ll.AbsoluteContentSize.Y+4) lb.CanvasPosition=Vector2.new(0,math.max(0,lb.CanvasSize.Y.Offset-lb.AbsoluteSize.Y)) end) end
    st.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then col=not col st.Size=UDim2.new(1,-20,0,col and 36 or 120) st.Position=UDim2.new(0,10,1,col and -40 or -124) end end)
    return lg
end
-- PLAYER POPUP (compact dropdown)
local function mkplayer(par,y)
    local tgt=nil
    local btn=Instance.new("TextButton") btn.Size=UDim2.fromOffset(130,26) btn.Position=UDim2.fromOffset(10,y) btn.BackgroundColor3=C.panel btn.BorderSizePixel=0 btn.Font=FB btn.Text="▼ No target" btn.TextColor3=C.muted btn.TextSize=10 btn.TextXAlignment=Enum.TextXAlignment.Left btn.AutoButtonColor=false btn.Parent=par corner(btn,7) tr(btn)
    local bpad=Instance.new("UIPadding") bpad.PaddingLeft=UDim.new(0,8) bpad.Parent=btn
    local pop=Instance.new("ScrollingFrame") pop.Size=UDim2.fromOffset(220,140) pop.Position=UDim2.fromOffset(10,y+28) pop.BackgroundColor3=C.panel pop.BorderSizePixel=0 pop.ScrollBarThickness=3 pop.ScrollBarImageColor3=C.muted pop.CanvasSize=UDim2.new() pop.Visible=false pop.ZIndex=20 pop.Parent=par corner(pop,9) tr(pop)
    local pl=Instance.new("UIListLayout") pl.Padding=UDim.new(0,3) pl.SortOrder=Enum.SortOrder.LayoutOrder pl.Parent=pop
    local pp=Instance.new("UIPadding") pp.PaddingTop=UDim.new(0,4) pp.PaddingLeft=UDim.new(0,4) pp.PaddingRight=UDim.new(0,4) pp.Parent=pop
    local pR={} local sendBtn=Instance.new("TextButton") sendBtn.Size=UDim2.fromOffset(76,26) sendBtn.Position=UDim2.fromOffset(146,y) sendBtn.BackgroundColor3=C.purple sendBtn.BorderSizePixel=0 sendBtn.Font=FB sendBtn.Text="SEND TRADE" sendBtn.TextColor3=Color3.new(1,1,1) sendBtn.TextSize=9 sendBtn.Visible=false sendBtn.Parent=par corner(sendBtn,7)
    local function rebuild()
        for _,r in ipairs(pR) do r:Destroy() end pR={}
        for i,p2 in ipairs(Players:GetPlayers()) do if p2~=LP then
        local r=Instance.new("TextButton") r.Size=UDim2.new(1,0,0,30) r.BackgroundColor3=C.cell r.BorderSizePixel=0 r.Text="" r.LayoutOrder=i r.Parent=pop corner(r,7)
        local av=Instance.new("ImageLabel") av.Size=UDim2.fromOffset(24,24) av.Position=UDim2.fromOffset(4,3) av.BackgroundColor3=C.card av.BorderSizePixel=0 av.ScaleType=Enum.ScaleType.Crop av.Parent=r corner(av,6)
        task.spawn(function() pcall(function() av.Image=Players:GetUserThumbnailAsync(p2.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end) end)
        local dn=Instance.new("TextLabel") dn.Size=UDim2.new(1,-36,0,13) dn.Position=UDim2.fromOffset(32,3) dn.BackgroundTransparency=1 dn.Font=FB dn.TextSize=10 dn.TextColor3=C.text dn.TextXAlignment=Enum.TextXAlignment.Left dn.TextTruncate=Enum.TextTruncate.AtEnd dn.Text=p2.DisplayName dn.Parent=r
        local un=Instance.new("TextLabel") un.Size=UDim2.new(1,-36,0,11) un.Position=UDim2.fromOffset(32,16) un.BackgroundTransparency=1 un.Font=FN un.TextSize=8 un.TextColor3=C.muted un.TextXAlignment=Enum.TextXAlignment.Left un.Text="@"..p2.Name un.Parent=r
        r.MouseButton1Click:Connect(function() tgt=p2 btn.Text="▼ "..p2.DisplayName btn.TextColor3=C.text sendBtn.Visible=true pop.Visible=false end)
        table.insert(pR,r) end end pop.CanvasSize=UDim2.fromOffset(0,pl.AbsoluteContentSize.Y+8)
    end
    btn.MouseButton1Click:Connect(function() pop.Visible=not pop.Visible if pop.Visible then rebuild() end end)
    sendBtn.MouseButton1Click:Connect(function() if tgt and tgt.Parent and Rem["TradeAPI/SendTradeRequest"] and Rem["TradeAPI/SendTradeRequest"].ok then pcall(function() Rem["TradeAPI/SendTradeRequest"].ref:FireServer(tgt) end) sendBtn.Text="SENT" sendBtn.BackgroundColor3=C.muted task.delay(3,function() sendBtn.Text="SEND TRADE" sendBtn.BackgroundColor3=C.purple end) end end)
    return {get=function() return tgt end,set=function(p2) tgt=p2 if p2 then btn.Text="▼ "..p2.DisplayName btn.TextColor3=C.text sendBtn.Visible=true end end}
end
-- CATEGORY POPUP (compact dropdown)
local function mkcat(par,y,def,onChange)
    local act={} for k,v in pairs(def) do act[k]=v end
    local btn=Instance.new("TextButton") btn.Size=UDim2.fromOffset(80,26) btn.Position=UDim2.new(1,-90,0,y) btn.BackgroundColor3=C.panel btn.BorderSizePixel=0 btn.Font=FB btn.Text="CATEGORY" btn.TextColor3=C.dim btn.TextSize=9 btn.Parent=par corner(btn,7) tr(btn)
    local pop=Instance.new("Frame") pop.Size=UDim2.fromOffset(140,0) pop.Position=UDim2.new(1,-150,0,y+28) pop.BackgroundColor3=C.panel pop.BorderSizePixel=0 pop.Visible=false pop.ZIndex=25 pop.Parent=par corner(pop,9) tr(pop)
    local cl=Instance.new("UIListLayout") cl.Padding=UDim.new(0,2) cl.SortOrder=Enum.SortOrder.LayoutOrder cl.Parent=pop
    local cp=Instance.new("UIPadding") cp.PaddingTop=UDim.new(0,4) cp.PaddingLeft=UDim.new(0,4) cp.PaddingRight=UDim.new(0,4) cp.PaddingBottom=UDim.new(0,4) cp.Parent=pop
    for ci,ci2 in ipairs(ALL_CATS) do local r=Instance.new("TextButton") r.Size=UDim2.new(1,0,0,20) r.BackgroundColor3=act[ci2.key] and C.cellOn or C.cell r.BorderSizePixel=0 r.Font=FB r.Text=ci2.label r.TextColor3=act[ci2.key] and C.text or C.muted r.TextSize=9 r.LayoutOrder=ci r.Parent=pop corner(r,5)
    r.MouseButton1Click:Connect(function() if act[ci2.key] then act[ci2.key]=nil r.BackgroundColor3=C.cell r.TextColor3=C.muted else act[ci2.key]=true r.BackgroundColor3=C.cellOn r.TextColor3=C.text end if onChange then onChange(act) end end) end
    pop.Size=UDim2.fromOffset(140,cl.AbsoluteContentSize.Y+8)
    btn.MouseButton1Click:Connect(function() pop.Visible=not pop.Visible end)
    return {get=function() return act end}
end
-- GRID (compact, multi-search, 2-row controls)
local function mkgrid(par,top,bottom,gridId,catpop)
    local ALL,STACKS={},{} local picked={} local search,fRar,fTyp="",{},{} local rendering=false
    local function reload() STACKS,ALL=build_stacks(catpop.get()) end reload()
    local function any(t) return next(t)~=nil end
    local function visible()
        if search=="" and not any(fRar) and not any(fTyp) then return ALL end
        local out={} for _,s in ipairs(ALL) do local ok=true
        if search~="" then
            local terms={} for term in search:gmatch("[^,]+") do local t=term:match("^%s*(.-)%s*$") if t~="" then table.insert(terms,t:lower()) end end
            if #terms>0 then local found=false for _,t in ipairs(terms) do if s.name:lower():find(t,1,true) then found=true break end end if not found then ok=false end end
        end
        if any(fRar) and not fRar[s.rarity] then ok=false end
        if any(fTyp) and not fTyp[s.tag] then ok=false end
        if ok then table.insert(out,s) end end return out
    end
    local function tpick() local n=0 for _,c in pairs(picked) do n=n+c end return n end
    -- Row 2: search + fill + clear + refresh
    local sb=Instance.new("TextBox") sb.Size=UDim2.new(1,-278,0,26) sb.Position=UDim2.fromOffset(10,top) sb.BackgroundColor3=C.panel sb.BorderSizePixel=0 sb.Font=FN sb.PlaceholderText="Search (ride, fly)" sb.Text="" sb.TextColor3=C.text sb.PlaceholderColor3=C.muted sb.TextSize=10 sb.ClearTextOnFocus=false sb.Parent=par corner(sb,7) tr(sb)
    local fillB=Instance.new("TextButton") fillB.Size=UDim2.fromOffset(46,26) fillB.Position=UDim2.new(1,-262,0,top) fillB.BackgroundColor3=C.panel fillB.BorderSizePixel=0 fillB.Font=FB fillB.Text="FILL 18" fillB.TextColor3=C.amber fillB.TextSize=9 fillB.Parent=par corner(fillB,7) tr(fillB)
    local clrB=Instance.new("TextButton") clrB.Size=UDim2.fromOffset(40,26) clrB.Position=UDim2.new(1,-212,0,top) clrB.BackgroundColor3=C.panel clrB.BorderSizePixel=0 clrB.Font=FB clrB.Text="CLEAR" clrB.TextColor3=C.muted clrB.TextSize=9 clrB.Parent=par corner(clrB,7) tr(clrB)
    local filtB=Instance.new("TextButton") filtB.Size=UDim2.fromOffset(48,26) filtB.Position=UDim2.new(1,-168,0,top) filtB.BackgroundColor3=C.panel filtB.BorderSizePixel=0 filtB.Font=FB filtB.Text="FILTER" filtB.TextColor3=C.dim filtB.TextSize=9 filtB.Parent=par corner(filtB,7) tr(filtB)
    local refB=Instance.new("TextButton") refB.Size=UDim2.fromOffset(26,26) refB.Position=UDim2.new(1,-116,0,top) refB.BackgroundColor3=C.panel refB.BorderSizePixel=0 refB.Font=FB refB.Text="⟳" refB.TextColor3=C.cyan refB.TextSize=14 refB.Parent=par corner(refB,7) tr(refB)
    -- filter drawer
    local dw=Instance.new("Frame") dw.Size=UDim2.new(1,-20,0,60) dw.Position=UDim2.fromOffset(10,top+30) dw.BackgroundColor3=C.panel dw.BorderSizePixel=0 dw.Visible=false dw.Parent=par corner(dw,8) tr(dw)
    local dP=Instance.new("UIPadding") dP.PaddingTop=UDim.new(0,4) dP.PaddingLeft=UDim.new(0,6) dP.Parent=dw
    local dL=Instance.new("UIListLayout") dL.Padding=UDim.new(0,2) dL.SortOrder=Enum.SortOrder.LayoutOrder dL.Parent=dw
    local function cL(t,o) local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,9) l.BackgroundTransparency=1 l.Font=FN l.Text=t l.TextColor3=C.muted l.TextSize=7 l.TextXAlignment=Enum.TextXAlignment.Left l.LayoutOrder=o l.Parent=dw end
    local function cR(o) local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,16) f.BackgroundTransparency=1 f.LayoutOrder=o f.Parent=dw local l=Instance.new("UIListLayout") l.FillDirection=Enum.FillDirection.Horizontal l.Padding=UDim.new(0,2) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=f return f end
    cL("RARITY",1) local rR=cR(2) cL("TYPE",3) local rT=cR(4) local cn=0
    local function chip(p2,lb,col,set,key) cn=cn+1 local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(#lb*6+10,14) b.BackgroundColor3=C.chip b.BorderSizePixel=0 b.Font=FB b.Text=lb b.TextColor3=C.muted b.TextSize=7 b.LayoutOrder=cn b.Parent=p2 corner(b,7)
    b.MouseButton1Click:Connect(function() if set[key] then set[key]=nil b.BackgroundColor3=C.chip b.TextColor3=C.muted else set[key]=true b.BackgroundColor3=col b.TextColor3=C.bg end if render then render() end end) end
    for _,r in ipairs(RARS) do chip(rR,nice(r):upper(),RCOL[r],fRar,r) end for _,t in ipairs(TYPS) do chip(rT,t,C.cyan,fTyp,t) end
    local gridTop=top+28
    local grid=Instance.new("ScrollingFrame") grid.Position=UDim2.fromOffset(8,gridTop) grid.Size=UDim2.new(1,-16,1,-(gridTop+bottom)) grid.BackgroundColor3=C.panel grid.BorderSizePixel=0 grid.ScrollBarThickness=3 grid.ScrollBarImageColor3=C.purple grid.CanvasSize=UDim2.new() grid.Parent=par corner(grid,9) tr(grid)
    local gl=Instance.new("UIGridLayout") gl.CellSize=UDim2.fromOffset(76,86) gl.CellPadding=UDim2.fromOffset(3,3) gl.SortOrder=Enum.SortOrder.LayoutOrder gl.Parent=grid
    local gP=Instance.new("UIPadding") gP.PaddingTop=UDim.new(0,4) gP.PaddingLeft=UDim.new(0,4) gP.PaddingBottom=UDim.new(0,4) gP.Parent=grid
    local emL=Instance.new("TextLabel") emL.Size=UDim2.fromScale(1,1) emL.BackgroundTransparency=1 emL.Font=FN emL.Text="No items match" emL.TextColor3=C.muted emL.TextSize=11 emL.Visible=false emL.Parent=grid
    local selC=Instance.new("TextLabel") selC.Size=UDim2.fromOffset(46,22) selC.Position=UDim2.new(1,-56,0,top+2) selC.BackgroundColor3=C.purple selC.BorderSizePixel=0 selC.Font=FB selC.TextSize=9 selC.TextColor3=Color3.new(1,1,1) selC.Text="0/18" selC.ZIndex=5 selC.Parent=par corner(selC,7)
    -- picker
    local ov=Instance.new("TextButton") ov.Size=UDim2.fromScale(1,1) ov.BackgroundColor3=Color3.new(0,0,0) ov.BackgroundTransparency=0.45 ov.Text="" ov.Visible=false ov.ZIndex=30 ov.AutoButtonColor=false ov.Parent=root corner(ov,16)
    local qb=Instance.new("Frame") qb.Size=UDim2.fromOffset(250,170) qb.Position=UDim2.new(0.5,-125,0.5,-85) qb.BackgroundColor3=C.panel qb.BorderSizePixel=0 qb.ZIndex=31 qb.Parent=ov corner(qb,12)
    local qI=Instance.new("ImageLabel") qI.Size=UDim2.fromOffset(40,40) qI.Position=UDim2.fromOffset(10,10) qI.BackgroundColor3=C.cell qI.BorderSizePixel=0 qI.ScaleType=Enum.ScaleType.Fit qI.ZIndex=32 qI.Parent=qb corner(qI,8)
    local qN=Instance.new("TextLabel") qN.Size=UDim2.fromOffset(175,16) qN.Position=UDim2.fromOffset(58,12) qN.BackgroundTransparency=1 qN.Font=FB qN.TextSize=12 qN.TextColor3=C.text qN.TextXAlignment=Enum.TextXAlignment.Left qN.TextTruncate=Enum.TextTruncate.AtEnd qN.ZIndex=32 qN.Parent=qb
    local qS=Instance.new("TextLabel") qS.Size=UDim2.fromOffset(175,12) qS.Position=UDim2.fromOffset(58,29) qS.BackgroundTransparency=1 qS.Font=FN qS.TextSize=9 qS.TextColor3=C.muted qS.TextXAlignment=Enum.TextXAlignment.Left qS.ZIndex=32 qS.Parent=qb
    local qV=Instance.new("TextBox") qV.Size=UDim2.fromOffset(80,34) qV.Position=UDim2.fromOffset(85,60) qV.BackgroundColor3=C.cell qV.BorderSizePixel=0 qV.Font=FT qV.TextSize=16 qV.TextColor3=C.text qV.Text="1" qV.ClearTextOnFocus=false qV.ZIndex=32 qV.Parent=qb corner(qV,8)
    local function qbt(x,t) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(54,34) b.Position=UDim2.fromOffset(x,60) b.BackgroundColor3=C.cell b.BorderSizePixel=0 b.Font=FT b.Text=t b.TextColor3=C.cyan b.TextSize=14 b.ZIndex=32 b.Parent=qb corner(b,8) return b end
    local qMn,qPl=qbt(10,"-"),qbt(186,"+")
    local qRm=Instance.new("TextButton") qRm.Size=UDim2.fromOffset(68,28) qRm.Position=UDim2.fromOffset(10,106) qRm.BackgroundColor3=C.cell qRm.BorderSizePixel=0 qRm.Font=FB qRm.Text="REMOVE" qRm.TextColor3=C.red qRm.TextSize=9 qRm.ZIndex=32 qRm.Parent=qb corner(qRm,7)
    local qMx=Instance.new("TextButton") qMx.Size=UDim2.fromOffset(68,28) qMx.Position=UDim2.fromOffset(84,106) qMx.BackgroundColor3=C.cell qMx.BorderSizePixel=0 qMx.Font=FB qMx.Text="ALL" qMx.TextColor3=C.amber qMx.TextSize=9 qMx.ZIndex=32 qMx.Parent=qb corner(qMx,7)
    local qAd=Instance.new("TextButton") qAd.Size=UDim2.fromOffset(82,28) qAd.Position=UDim2.fromOffset(158,106) qAd.BackgroundColor3=C.purple qAd.BorderSizePixel=0 qAd.Font=FT qAd.Text="ADD" qAd.TextColor3=Color3.new(1,1,1) qAd.TextSize=10 qAd.ZIndex=32 qAd.Parent=qb corner(qAd,7)
    local qCur
    local function clQ(n) if not qCur then return 1 end local tp=tpick() local al=picked[qCur.key] or 0 return math.clamp(math.floor(tonumber(n) or 1),0,math.min(#qCur.uniques,MAX_OFFER-tp+al)) end
    local function sQ(n) qV.Text=tostring(clQ(n)) end
    local function oQ(s) qCur=s qI.Image=s.image~="" and s.image or "" qN.Text=s.name qS.Text=s.tag.."  "..nice(s.rarity).."  own "..#s.uniques sQ(picked[s.key] or math.min(#s.uniques,MAX_OFFER-tpick()+(picked[s.key] or 0))) ov.Visible=true end
    qMn.MouseButton1Click:Connect(function() sQ((tonumber(qV.Text) or 1)-1) end) qPl.MouseButton1Click:Connect(function() sQ((tonumber(qV.Text) or 0)+1) end)
    qMx.MouseButton1Click:Connect(function() sQ(qCur and #qCur.uniques or 1) end) qV.FocusLost:Connect(function() sQ(qV.Text) end) ov.MouseButton1Click:Connect(function() ov.Visible=false end)
    qRm.MouseButton1Click:Connect(function() if qCur then picked[qCur.key]=nil end ov.Visible=false if render then render() end end)
    qAd.MouseButton1Click:Connect(function() if not qCur then return end local n=clQ(qV.Text) if n<=0 then picked[qCur.key]=nil else picked[qCur.key]=n end ov.Visible=false if render then render() end end)
    local render local cells={}
    function render() if rendering then return end rendering=true for _,c in ipairs(cells) do c:Destroy() end cells={}
    local vis=visible() emL.Visible=(#vis==0)
    for i,s in ipairs(vis) do local n=picked[s.key] or 0
    local cell=Instance.new("TextButton") cell.BackgroundColor3=n>0 and C.cellOn or C.cell cell.BorderSizePixel=0 cell.Text="" cell.LayoutOrder=i cell.AutoButtonColor=false cell.Parent=grid corner(cell,8)
    if s.rarity=="ultra_rare" or s.rarity=="legendary" then local g2=Instance.new("UIStroke") g2.Color=RCOL[s.rarity] g2.Thickness=1.5 g2.Transparency=0.6 g2.Parent=cell end
    local strip=Instance.new("Frame") strip.Size=UDim2.new(1,-12,0,3) strip.Position=UDim2.fromOffset(6,3) strip.BackgroundColor3=RCOL[s.rarity] or C.muted strip.BorderSizePixel=0 strip.Parent=cell corner(strip,2)
    local img=Instance.new("ImageLabel") img.Size=UDim2.fromOffset(38,38) img.Position=UDim2.new(0.5,-19,0,10) img.BackgroundTransparency=1 img.Image=s.image~="" and s.image or "rbxassetid://6031225819" if s.image=="" then img.ImageColor3=C.muted end img.ScaleType=Enum.ScaleType.Fit img.Parent=cell
    local nm=Instance.new("TextLabel") nm.Size=UDim2.new(1,-4,0,11) nm.Position=UDim2.fromOffset(2,50) nm.BackgroundTransparency=1 nm.Font=FB nm.TextSize=7 nm.TextColor3=C.text nm.TextTruncate=Enum.TextTruncate.AtEnd nm.Text=s.name nm.Parent=cell
    local ct=n>0 and (#s.uniques..">"..n) or (s.tag.." x"..#s.uniques)
    local meta=Instance.new("TextLabel") meta.Size=UDim2.new(1,-4,0,10) meta.Position=UDim2.fromOffset(2,62) meta.BackgroundTransparency=1 meta.Font=FN meta.TextSize=7 meta.TextColor3=n>0 and C.text or C.muted meta.Text=ct meta.Parent=cell
    if n>0 then local edge=Instance.new("Frame") edge.Size=UDim2.new(0,3,1,-8) edge.Position=UDim2.fromOffset(0,4) edge.BackgroundColor3=C.cyan edge.BorderSizePixel=0 edge.Parent=cell corner(edge,2)
    local badge=Instance.new("TextLabel") badge.Size=UDim2.fromOffset(22,14) badge.Position=UDim2.new(1,-26,0,8) badge.BackgroundColor3=C.purple badge.BorderSizePixel=0 badge.Font=FB badge.TextSize=8 badge.TextColor3=Color3.new(1,1,1) badge.Text=tostring(n) badge.Parent=cell corner(badge,7) end
    if s.tag:find("M") then local st2=Instance.new("TextLabel") st2.Size=UDim2.fromOffset(10,10) st2.Position=UDim2.fromOffset(2,2) st2.BackgroundTransparency=1 st2.Font=FT st2.Text="*" st2.TextColor3=C.amber st2.TextSize=10 st2.Parent=cell
    elseif s.tag:find("N") then local st2=Instance.new("TextLabel") st2.Size=UDim2.fromOffset(8,8) st2.Position=UDim2.fromOffset(2,2) st2.BackgroundTransparency=1 st2.Font=FB st2.Text="*" st2.TextColor3=C.cyan st2.TextSize=8 st2.Parent=cell end
    local lt=0 cell.MouseButton1Click:Connect(function() local now=tick() if now-lt<0.35 then picked[s.key]=math.min(#s.uniques,MAX_OFFER-tpick()+(picked[s.key] or 0)) if render then render() end else lt=now task.delay(0.36,function() if tick()-lt>=0.35 then oQ(s) end end) end end)
    table.insert(cells,cell) end
    grid.CanvasSize=UDim2.fromOffset(0,gl.AbsoluteContentSize.Y+10) selC.Text=tpick().."/"..MAX_OFFER rendering=false end
    local dbT=0 local function dbR() dbT=tick() local t=dbT task.delay(0.15,function() if dbT==t and render then render() end end) end
    sb:GetPropertyChangedSignal("Text"):Connect(function() search=sb.Text dbR() end)
    filtB.MouseButton1Click:Connect(function() local o=not dw.Visible dw.Visible=o filtB.Text=o and "HIDE" or "FILTER" filtB.TextColor3=o and C.cyan or C.dim
    local gt=o and (top+30+64) or gridTop grid.Position=UDim2.fromOffset(10,gt) grid.Size=UDim2.new(1,-20,1,-(gt+bottom)) task.defer(render) end)
    clrB.MouseButton1Click:Connect(function() picked={} render() end)
    refB.MouseButton1Click:Connect(function() reload() picked={} render() end)
    fillB.MouseButton1Click:Connect(function() local rem=MAX_OFFER-tpick() if rem<=0 then return end local vis=visible() local sorted={} for _,s in ipairs(vis) do table.insert(sorted,s) end table.sort(sorted,function(a,b) return #a.uniques>#b.uniques end)
    for _,s in ipairs(sorted) do if rem<=0 then break end local al=picked[s.key] or 0 local av=#s.uniques-al if av>0 then local take=math.min(av,rem) picked[s.key]=al+take rem=rem-take end end render() end)
    render()
    return {render=render,refresh=function() reload() render() end,stacks=function() return STACKS end,picked=function() return picked end,total=tpick,clear=function() picked={} render() end,
    get_uniques=function() local out={} for key,n in pairs(picked) do local s=STACKS[key] if s then for i=1,math.min(n,#s.uniques) do table.insert(out,s.uniques[i]) end end end return out end,
    get_chunks=function() local all={} for key,n in pairs(picked) do local s=STACKS[key] if s then for i=1,math.min(n,#s.uniques) do table.insert(all,s.uniques[i]) end end end local ch={} for i=1,#all,MAX_OFFER do local c={} for j=i,math.min(i+MAX_OFFER-1,#all) do table.insert(c,all[j]) end table.insert(ch,c) end return ch,#all end,
    setCatFilter=function() reload() render() end}
end
-- TRADE TAB
local trLogStrip -- no log strip on trade tab
local function trLog(msg,col) end -- silent on trade tab
local trPl=mkplayer(pTrade,6)
local trCat=mkcat(pTrade,6,Config.trade_cats,function(f) Config.trade_cats=f scfg() trGrid.setCatFilter() trGrid.refresh() end)
local trModeQ=true
local mSw=Instance.new("Frame") mSw.Size=UDim2.fromOffset(180,24) mSw.Position=UDim2.new(0.5,-90,0,6) mSw.BackgroundColor3=C.panel mSw.BorderSizePixel=0 mSw.Parent=pTrade corner(mSw,7) tr(mSw)
local mQ=Instance.new("TextButton") mQ.Size=UDim2.new(0.5,0,1,0) mQ.BackgroundColor3=C.purple mQ.BorderSizePixel=0 mQ.Font=FB mQ.Text="QUEUE" mQ.TextColor3=Color3.new(1,1,1) mQ.TextSize=9 mQ.Parent=mSw corner(mQ,7)
local mI=Instance.new("TextButton") mI.Size=UDim2.new(0.5,0,1,0) mI.Position=UDim2.new(0.5,0,0,0) mI.BackgroundColor3=C.panel mI.BorderSizePixel=0 mI.Font=FB mI.Text="INSTANT" mI.TextColor3=C.muted mI.TextSize=9 mI.Parent=mSw corner(mI,7)
local trGrid=mkgrid(pTrade,36,38,"trade",trCat)
local trFire=Instance.new("TextButton") trFire.Size=UDim2.new(1,-16,0,30) trFire.Position=UDim2.new(0,8,1,-34) trFire.BackgroundColor3=C.cyan trFire.BorderSizePixel=0 trFire.Font=FT trFire.Text="PUT IN TRADE" trFire.TextColor3=C.bg trFire.TextSize=12 trFire.Parent=pTrade corner(trFire,8)
local instCnt=Instance.new("TextLabel") instCnt.Size=UDim2.new(1,-16,0,26) instCnt.Position=UDim2.new(0,8,1,-34) instCnt.BackgroundColor3=C.card instCnt.BorderSizePixel=0 instCnt.Font=FT instCnt.Text="0/"..MAX_OFFER instCnt.TextColor3=C.text instCnt.TextSize=13 instCnt.Visible=false instCnt.Parent=pTrade corner(instCnt,8)
local function swMode(q) trModeQ=q mQ.BackgroundColor3=q and C.purple or C.panel mQ.TextColor3=q and Color3.new(1,1,1) or C.muted mI.BackgroundColor3=q and C.panel or C.purple mI.TextColor3=q and C.muted or Color3.new(1,1,1) trFire.Visible=q instCnt.Visible=not q trGrid.clear() end
mQ.MouseButton1Click:Connect(function() swMode(true) end) mI.MouseButton1Click:Connect(function() swMode(false) end)
local function gts() if not UIManager then return nil end local ok,app=pcall(function() return UIManager.apps.TradeApp end) if not ok or not app then return nil end local o2,s=pcall(function() return app:_get_local_trade_state() end) return o2 and s or nil end
local function gta() if not UIManager then return nil end local ok,app=pcall(function() return UIManager.apps.TradeApp end) return ok and app or nil end
local function moc() local s=gts() if not s then return 0 end local ok,it=pcall(function() return s.sender_offer.items end) return ok and type(it)=="table" and #it or 0 end
local trBusy=false
trFire.MouseButton1Click:Connect(function() if trBusy then return end local s=gts() if not s then trLog("No trade box open.",C.amber) return end
local ch,tot=trGrid.get_chunks() if tot==0 then trLog("Nothing picked.",C.amber) return end local chunk=ch[1]
trBusy=true trFire.Text="FILLING..." trFire.BackgroundColor3=C.cell
task.spawn(function() local ok2,e2=pcall(function() trLog("Adding "..#chunk.." items...",C.cyan)
for _,u in ipairs(chunk) do if not gts() then trLog("Trade closed.",C.red) break end pcall(function() Rem["TradeAPI/AddItemToOffer"].ref:FireServer(u) end) end
task.wait(0.3) local mc=moc() trLog("Offer: "..mc.."/"..MAX_OFFER,C.green) ps(SND.done)
if tot>MAX_OFFER then trLog((tot-MAX_OFFER).." remaining for next trade.",C.amber) end trGrid.clear() trGrid.refresh()
end) if not ok2 then trLog("Error: "..tostring(e2),C.red) logcrash("trade: "..tostring(e2)) end
trBusy=false trFire.Text="PUT IN TRADE" trFire.BackgroundColor3=C.cyan end) end)
local instAdding=false
local function instAdd(stack) if instAdding then return end local s=gts() if not s then trLog("Open a trade first.",C.amber) return end
local mc=moc() if mc>=MAX_OFFER then trLog(MAX_OFFER.."/"..MAX_OFFER.." full.",C.red) return end if #stack.uniques==0 then return end
instAdding=true pcall(function() Rem["TradeAPI/AddItemToOffer"].ref:FireServer(stack.uniques[1]) end) task.wait(0.08) instAdding=false
instCnt.Text=(mc+1).."/"..MAX_OFFER instCnt.TextColor3=(mc+1)>=MAX_OFFER and C.red or C.text task.defer(function() trGrid.refresh() end) end
-- AUTO TRADE TAB
local atLog=mklog(pAuto)
local atPl=mkplayer(pAuto,6)
local atCat=mkcat(pAuto,6,Config.auto_cats,function(f) Config.auto_cats=f scfg() atGrid.setCatFilter() atGrid.refresh() end)
local autoAccept,autoRetry,forceAll=Config.auto_accept or false,Config.auto_retry~=false,Config.force_accept_all or false
local function tgb(x,w,txt,on,col,par,y) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(w,24) b.Position=UDim2.fromOffset(x,y) b.BackgroundColor3=C.panel b.BorderSizePixel=0 b.Font=FB b.Text=txt b.TextColor3=on and (col or C.green) or C.red b.TextSize=9 b.Parent=par corner(b,7) tr(b) return b end
local atAcc=tgb(10,90,autoAccept and "ACCEPT: ON" or "ACCEPT: OFF",autoAccept,C.green,pAuto,36)
local atRet=tgb(106,80,autoRetry and "RETRY: ON" or "RETRY: OFF",autoRetry,C.green,pAuto,36)
local atFrc=tgb(192,80,forceAll and "FORCE: ON" or "FORCE: OFF",forceAll,C.red,pAuto,36)
local atCount=Instance.new("TextLabel") atCount.Size=UDim2.fromOffset(80,16) atCount.Position=UDim2.new(1,-90,0,40) atCount.BackgroundTransparency=1 atCount.Font=FT atCount.Text="0 trades" atCount.TextColor3=C.green atCount.TextSize=11 atCount.TextXAlignment=Enum.TextXAlignment.Right atCount.Parent=pAuto
atAcc.MouseButton1Click:Connect(function() autoAccept=not autoAccept atAcc.Text=autoAccept and "ACCEPT: ON" or "ACCEPT: OFF" atAcc.TextColor3=autoAccept and C.green or C.red Config.auto_accept=autoAccept scfg() end)
atRet.MouseButton1Click:Connect(function() autoRetry=not autoRetry atRet.Text=autoRetry and "RETRY: ON" or "RETRY: OFF" atRet.TextColor3=autoRetry and C.green or C.red Config.auto_retry=autoRetry scfg() end)
atFrc.MouseButton1Click:Connect(function() forceAll=not forceAll atFrc.Text=forceAll and "FORCE: ON" or "FORCE: OFF" atFrc.TextColor3=forceAll and C.red or C.muted Config.force_accept_all=forceAll scfg() atLog(forceAll and "FORCE: accepting ALL dialogs" or "Force off",forceAll and C.red or C.muted) end)
local atGrid=mkgrid(pAuto,64,76,"auto",atCat)
local prevBar=Instance.new("Frame") prevBar.Size=UDim2.new(1,-16,0,18) prevBar.Position=UDim2.new(0,8,1,-72) prevBar.BackgroundColor3=C.card prevBar.BorderSizePixel=0 prevBar.Parent=pAuto corner(prevBar,7)
local prevTxt=Instance.new("TextLabel") prevTxt.Size=UDim2.fromScale(1,1) prevTxt.BackgroundTransparency=1 prevTxt.Font=FL prevTxt.Text="IDLE" prevTxt.TextColor3=C.muted prevTxt.TextSize=9 prevTxt.Parent=prevBar
local atStartBtn=Instance.new("TextButton") atStartBtn.Size=UDim2.new(1,-16,0,30) atStartBtn.Position=UDim2.new(0,8,1,-38) atStartBtn.BackgroundColor3=C.green atStartBtn.BorderSizePixel=0 atStartBtn.Font=FT atStartBtn.Text="START AUTO TRADE" atStartBtn.TextColor3=C.bg atStartBtn.TextSize=12 atStartBtn.Parent=pAuto corner(atStartBtn,8)
local atRunning=false local tradesDone=0
local STATES={IDLE="IDLE",REQ="REQUESTING",WAIT="WAITING",FILL="FILLING",NEG="NEGOTIATING",CONF="CONFIRMING"}
local function upP(s2,d) prevTxt.Text="["..s2.."] "..(d or "") prevTxt.TextColor3=s2==STATES.IDLE and C.muted or C.text end
local function doAuto()
    local target=atPl.get() if not target or not target.Parent then atLog("No valid target.",C.red) return end
    local chunks,total=atGrid.get_chunks() if total==0 then atLog("No items picked.",C.red) return end
    atRunning=true atStartBtn.Text="STOP" atStartBtn.BackgroundColor3=C.red atLog("Auto: "..total.." items, "..#chunks.." trade(s)",C.cyan) local startT=tick()
    task.spawn(function() local cursor=1 local ok2,e2=pcall(function()
    while atRunning and cursor<=#chunks do local chunk=chunks[cursor] local tn=cursor.."/"..#chunks local skip=false
    if not target.Parent then atLog("Target left. Waiting...",C.amber) upP("WAITING","rejoin") local uid=target.UserId local rej=false
    for w=1,120 do if not atRunning then return end task.wait(2) for _,p in ipairs(Players:GetPlayers()) do if p.UserId==uid then target=p atPl.set(p) rej=true break end end if rej then break end end
    if not rej then atLog("Target gone.",C.red) break end atLog("Rejoined.",C.green) end
    upP(STATES.REQ,"Trade "..tn) atLog("["..tn.."] Requesting...",C.cyan) ps(SND.click)
    Rem["TradeAPI/SendTradeRequest"].ref:FireServer(target) pcall(function() gta():_on_accept_pressed() end)
    upP(STATES.WAIT,"Trade "..tn) local opened=false
    for w=1,30 do if not atRunning then return end task.wait(1) if gts() then opened=true break end end
    if not opened then atLog("["..tn.."] Timeout",C.amber) ps(SND.fail) if autoRetry and atRunning then atLog("Retry 5s...",C.muted) task.wait(5) else cursor=cursor+1 end skip=true end
    if not skip then atLog("["..tn.."] Opened",C.green)
    upP(STATES.FILL,tn.." 0/"..#chunk)
    for ci,u in ipairs(chunk) do if not atRunning or not gts() then break end pcall(function() Rem["TradeAPI/AddItemToOffer"].ref:FireServer(u) end) if ci%6==0 then task.wait(0.08) end upP(STATES.FILL,tn.." "..ci.."/"..#chunk) end
    task.wait(0.3) atLog("["..tn.."] Filled "..#chunk,C.green)
    upP(STATES.NEG,tn) pcall(function() gta():_on_accept_pressed() end) local negOk=false
    for w=1,20 do if not atRunning then return end task.wait(0.5) pcall(function() gta():_on_accept_pressed() end) local st=gts()
    if st and st.current_stage=="confirmation" then negOk=true break end if not st then atLog("["..tn.."] Closed",C.red) skip=true break end end
    if not skip and negOk then upP(STATES.CONF,tn) pcall(function() gta():_on_confirm_pressed() end) local done=false
    for w=1,20 do if not atRunning then return end task.wait(0.5) pcall(function() gta():_on_confirm_pressed() end) if not gts() then done=true break end end
    if done then tradesDone=tradesDone+1 atCount.Text=tradesDone.." trades"
    local got={} pcall(function() local st=gts() if st then for _,it in ipairs(st.recipient_offer.items) do table.insert(got,it) end end end)
    atLog("["..tn.."] DONE #"..tradesDone,C.green) ps(SND.done) logrec(target.Name,chunk,got) cursor=cursor+1
    local el=tick()-startT local tpm=tradesDone/(el/60) local rem=#chunks-cursor+1 local eta=rem>0 and math.ceil(rem/(tpm/60)) or 0
    atLog(("%.1f/min ETA %ds"):format(tpm,eta),C.info) task.wait(1) atGrid.refresh()
    if cursor>#chunks then break end
    else atLog("["..tn.."] Confirm stuck",C.red) if autoRetry then task.wait(3) end end end end
    if atRunning and cursor<=#chunks then atLog("Cooldown 3s...",C.muted) task.wait(3) end end
    end) if not ok2 then atLog("Crash: "..tostring(e2),C.red) logcrash("auto: "..tostring(e2)) end
    atRunning=false atStartBtn.Text="START AUTO TRADE" atStartBtn.BackgroundColor3=C.green upP(STATES.IDLE,"")
    if cursor>#chunks then atLog("Queue exhausted.",C.green) ps(SND.done) end end)
end
atStartBtn.MouseButton1Click:Connect(function() if atRunning then atRunning=false atLog("Stopping...",C.amber) return end doAuto() end)
task.spawn(function() task.wait(2) while gui.Parent do local iv=(autoAccept or forceAll) and 0.15 or 2 task.wait(iv)
if autoAccept or forceAll then pcall(function() if not UIManager then return end local da=UIManager.apps.DialogApp
if da and da.ticket_count and da.completed_ticket and da.ticket_count>da.completed_ticket then da.force_response_signal:Fire(da.completed_ticket+1,table.pack("Accept")) atLog("Auto-accepted",C.green) end end) end end end)
-- SETTINGS
local function sH(y,t) local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-20,0,12) l.Position=UDim2.fromOffset(12,y) l.BackgroundTransparency=1 l.Font=FN l.Text=t l.TextColor3=C.muted l.TextSize=8 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=pSet end
local function sC(y,h) local f=Instance.new("Frame") f.Size=UDim2.new(1,-24,0,h) f.Position=UDim2.fromOffset(12,y) f.BackgroundColor3=C.card f.BorderSizePixel=0 f.Parent=pSet corner(f,9) tr(f) return f end
sH(6,"APPEARANCE") local opC=sC(18,42)
local opT=Instance.new("TextLabel") opT.Size=UDim2.new(1,-70,0,14) opT.Position=UDim2.fromOffset(10,4) opT.BackgroundTransparency=1 opT.Font=FB opT.Text="Opacity" opT.TextColor3=C.text opT.TextSize=11 opT.TextXAlignment=Enum.TextXAlignment.Left opT.Parent=opC
local opV=Instance.new("TextLabel") opV.Size=UDim2.fromOffset(40,14) opV.Position=UDim2.new(1,-48,0,4) opV.BackgroundTransparency=1 opV.Font=FT opV.Text=math.floor(Config.opacity*100).."%" opV.TextColor3=C.purple opV.TextSize=11 opV.TextXAlignment=Enum.TextXAlignment.Right opV.Parent=opC
local trk=Instance.new("TextButton") trk.Size=UDim2.new(1,-20,0,10) trk.Position=UDim2.fromOffset(10,24) trk.BackgroundColor3=C.cell trk.BorderSizePixel=0 trk.Text="" trk.AutoButtonColor=false trk.Parent=opC corner(trk,5)
local fil=Instance.new("Frame") fil.Size=UDim2.fromScale(Config.opacity,1) fil.BackgroundColor3=C.purple fil.BorderSizePixel=0 fil.Parent=trk corner(fil,5)
local knb=Instance.new("Frame") knb.Size=UDim2.fromOffset(12,12) knb.Position=UDim2.new(Config.opacity,-12,0.5,-6) knb.BackgroundColor3=C.text knb.BorderSizePixel=0 knb.Parent=trk corner(knb,6)
sH(64,"SOUND") local snC=sC(76,32)
local snT=Instance.new("TextLabel") snT.Size=UDim2.new(1,-70,0,14) snT.Position=UDim2.fromOffset(10,6) snT.BackgroundTransparency=1 snT.Font=FB snT.Text="Notifications" snT.TextColor3=C.text snT.TextSize=11 snT.TextXAlignment=Enum.TextXAlignment.Left snT.Parent=snC
local snB=Instance.new("TextButton") snB.Size=UDim2.fromOffset(50,22) snB.Position=UDim2.new(1,-58,0.5,-11) snB.BackgroundColor3=Config.notify_sound and C.green or C.muted snB.BorderSizePixel=0 snB.Font=FB snB.Text=Config.notify_sound and "ON" or "OFF" snB.TextColor3=C.bg snB.TextSize=9 snB.Parent=snC corner(snB,7)
snB.MouseButton1Click:Connect(function() Config.notify_sound=not Config.notify_sound snB.Text=Config.notify_sound and "ON" or "OFF" snB.BackgroundColor3=Config.notify_sound and C.green or C.muted scfg() end)
sH(112,"GRID") local gdC=sC(124,32)
local gdT=Instance.new("TextLabel") gdT.Size=UDim2.new(1,-70,0,14) gdT.Position=UDim2.fromOffset(10,6) gdT.BackgroundTransparency=1 gdT.Font=FB gdT.Text="Cell size" gdT.TextColor3=C.text gdT.TextSize=11 gdT.TextXAlignment=Enum.TextXAlignment.Left gdT.Parent=gdC
local gdB=Instance.new("TextButton") gdB.Size=UDim2.fromOffset(60,22) gdB.Position=UDim2.new(1,-68,0.5,-11) gdB.BackgroundColor3=C.purple gdB.BorderSizePixel=0 gdB.Font=FB gdB.Text="NORMAL" gdB.TextColor3=Color3.new(1,1,1) gdB.TextSize=9 gdB.Parent=gdC corner(gdB,7)
gdB.MouseButton1Click:Connect(function() local cp=gdB.Text=="NORMAL" gdB.Text=cp and "COMPACT" or "NORMAL"
for _,pg in pairs(pages) do for _,ch in ipairs(pg:GetDescendants()) do if ch:IsA("UIGridLayout") and ch.Parent:IsA("ScrollingFrame") then ch.CellSize=cp and UDim2.fromOffset(62,72) or UDim2.fromOffset(76,86) end end end end)
sH(160,"SESSION") local rjC=sC(172,32)
local rjT=Instance.new("TextLabel") rjT.Size=UDim2.new(1,-70,0,14) rjT.Position=UDim2.fromOffset(10,6) rjT.BackgroundTransparency=1 rjT.Font=FB rjT.Text="Rejoin server" rjT.TextColor3=C.text rjT.TextSize=11 rjT.TextXAlignment=Enum.TextXAlignment.Left rjT.Parent=rjC
local rjB=Instance.new("TextButton") rjB.Size=UDim2.fromOffset(56,22) rjB.Position=UDim2.new(1,-64,0.5,-11) rjB.BackgroundColor3=C.purple rjB.BorderSizePixel=0 rjB.Font=FT rjB.Text="REJOIN" rjB.TextColor3=Color3.new(1,1,1) rjB.TextSize=9 rjB.Parent=rjC corner(rjB,7)
rjB.MouseButton1Click:Connect(function() pcall(function() TPS:Teleport(game.PlaceId,LP) end) end)
local rstC=sC(210,32)
local rstT=Instance.new("TextLabel") rstT.Size=UDim2.new(1,-70,0,14) rstT.Position=UDim2.fromOffset(10,6) rstT.BackgroundTransparency=1 rstT.Font=FB rstT.Text="Reset all" rstT.TextColor3=C.text rstT.TextSize=11 rstT.TextXAlignment=Enum.TextXAlignment.Left rstT.Parent=rstC
local rstB=Instance.new("TextButton") rstB.Size=UDim2.fromOffset(56,22) rstB.Position=UDim2.new(1,-64,0.5,-11) rstB.BackgroundColor3=C.red rstB.BorderSizePixel=0 rstB.Font=FT rstB.Text="RESET" rstB.TextColor3=Color3.new(1,1,1) rstB.TextSize=9 rstB.Parent=rstC corner(rstB,7)
rstB.MouseButton1Click:Connect(function() pcall(function() if atRunning then atRunning=false end end) trGrid.clear() atGrid.clear() trGrid.refresh() atGrid.refresh() trLog("Reset.",C.amber) atLog("Reset.",C.amber) end)
sH(248,"HEALTH") local hcC=sC(260,10) local hcY=4
for n,d in pairs(Rem) do local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-10,0,10) l.Position=UDim2.fromOffset(5,hcY) l.BackgroundTransparency=1 l.Font=FL l.TextSize=8 l.TextColor3=d.ok and C.green or C.red l.TextXAlignment=Enum.TextXAlignment.Left l.Text=(d.ok and "OK" or "XX").."  "..n l.Parent=hcC hcY=hcY+12 end
hcC.Size=UDim2.new(1,-24,0,math.max(hcY+2,16))
sH(hcY+268,"ABOUT") local abC=sC(hcY+280,46)
local abT=Instance.new("TextLabel") abT.Size=UDim2.new(1,-12,0,38) abT.Position=UDim2.fromOffset(6,4) abT.BackgroundTransparency=1 abT.Font=FN
abT.Text="LazyHub v"..VERSION.." by lanavienrose\nTrade edition. Queue/instant mode. Auto trade with cursor chunking." abT.TextColor3=C.muted abT.TextSize=9 abT.TextXAlignment=Enum.TextXAlignment.Left abT.TextYAlignment=Enum.TextYAlignment.Top abT.TextWrapped=true abT.Parent=abC
local function setOp(a) Config.opacity=a for _,o in ipairs(FADE) do o.BackgroundTransparency=1-a end opV.Text=math.floor(a*100).."%" end
do local dg=false local function upd(px) local rel=math.clamp((px-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0.2,1) fil.Size=UDim2.fromScale(rel,1) knb.Position=UDim2.new(rel,-12,0.5,-6) setOp(rel) end
trk.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true upd(i.Position.X) end end)
UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if dg then dg=false scfg() end end end) end
-- CHROME
do local d,sp,sa header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d,sp,sa=true,i.Position,root.AbsolutePosition end end)
UIS.InputChanged:Connect(function(i) if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dt=i.Position-sp root.Position=UDim2.fromOffset(sa.X+dt.X,sa.Y+dt.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end) end
local grip=Instance.new("TextButton") grip.Size=UDim2.fromOffset(16,16) grip.Position=UDim2.new(1,-18,1,-18) grip.BackgroundColor3=C.cell grip.BorderSizePixel=0 grip.Text="" grip.AutoButtonColor=false grip.ZIndex=6 grip.Parent=root corner(grip,8)
do local rz,sp,ss grip.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rz,sp,ss=true,i.Position,root.AbsoluteSize end end)
UIS.InputChanged:Connect(function(i) if rz and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dt=i.Position-sp root.Size=UDim2.fromOffset(math.max(500,ss.X+dt.X),math.max(440,ss.Y+dt.Y)) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rz=false end end) end
local orb=Instance.new("TextButton") orb.Size=UDim2.fromOffset(48,48) orb.Position=UDim2.fromOffset(32,180) orb.BackgroundColor3=Color3.fromRGB(10,10,12) orb.BorderSizePixel=0 orb.Text="" orb.Visible=false orb.AutoButtonColor=false orb.Parent=gui corner(orb,24)
if LOGO then local oi=Instance.new("ImageLabel") oi.Size=UDim2.fromOffset(34,34) oi.Position=UDim2.fromOffset(7,7) oi.BackgroundTransparency=1 oi.Image=LOGO oi.ScaleType=Enum.ScaleType.Fit oi.Parent=orb
else local ol=Instance.new("TextLabel") ol.Size=UDim2.fromScale(1,1) ol.BackgroundTransparency=1 ol.Font=FT ol.Text="L" ol.TextColor3=C.purple ol.TextSize=20 ol.Parent=orb end
local orbC=Instance.new("TextLabel") orbC.Size=UDim2.fromOffset(18,12) orbC.Position=UDim2.new(1,-18,0,-2) orbC.BackgroundColor3=C.green orbC.BorderSizePixel=0 orbC.Font=FB orbC.TextSize=8 orbC.TextColor3=C.bg orbC.Text="" orbC.Visible=false orbC.Parent=orb corner(orbC,6)
do local d2,mv,sp2,sa2
orb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2,mv,sp2,sa2=true,false,i.Position,orb.AbsolutePosition end end)
UIS.InputChanged:Connect(function(i) if d2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dt=i.Position-sp2 if math.abs(dt.X)+math.abs(dt.Y)>6 then mv=true end orb.Position=UDim2.fromOffset(sa2.X+dt.X,sa2.Y+dt.Y) end end)
UIS.InputEnded:Connect(function(i) if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and d2 then d2=false if not mv then orb.Visible=false root.Visible=true end end end) end
minBtn.MouseButton1Click:Connect(function() root.Visible=false orb.Visible=true if tradesDone>0 then orbC.Text=tostring(tradesDone) orbC.Visible=true end end)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
UIS.InputBegan:Connect(function(i,g) if g then return end if i.KeyCode==Enum.KeyCode.RightShift then if root.Visible then root.Visible=false orb.Visible=true else orb.Visible=false root.Visible=true end end end)
-- HUD WATCHER
local lastMy,lastTh=0,0
task.spawn(function() while gui.Parent do local iv=(curTab=="trade" or atRunning) and 0.3 or 2 task.wait(iv)
pcall(function() local st=gts() if st then local mc,tc=0,0 pcall(function() mc=#st.sender_offer.items tc=#st.recipient_offer.items end)
hudTxt.Text="TRADE | You: "..mc.."/"..MAX_OFFER.." | Them: "..tc tradeHud.Visible=true
if not trModeQ then instCnt.Text=mc.."/"..MAX_OFFER instCnt.TextColor3=mc>=MAX_OFFER and C.red or C.text end
if mc~=lastMy then lastMy=mc end if tc~=lastTh then lastTh=tc end
else tradeHud.Visible=false if lastMy>0 or lastTh>0 then lastMy=0 lastTh=0 task.defer(function() trGrid.refresh() atGrid.refresh() end) end end end) end end)
setOp(Config.opacity) show("trade") trLog("LazyHub v"..VERSION.." ready",C.purple) atLog("Select target & items, then start.",C.info)
end)
if not __ok then pcall(function() writefile("lazyhub_error.txt",tostring(__err)) end)
pcall(function() local eg=Instance.new("ScreenGui") eg.Name="E" eg.ResetOnSpawn=false eg.Parent=(gethui and gethui()) or game.Players.LocalPlayer:WaitForChild("PlayerGui")
local f=Instance.new("Frame") f.Size=UDim2.fromOffset(380,160) f.Position=UDim2.new(0.5,-190,0.5,-80) f.BackgroundColor3=Color3.fromRGB(12,12,15) f.BorderSizePixel=0 f.Active=true f.Draggable=true f.Parent=eg
local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,12) c.Parent=f
local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-20,0,20) t.Position=UDim2.fromOffset(10,8) t.BackgroundTransparency=1 t.Font=Enum.Font.GothamBlack t.Text="LazyHub failed" t.TextColor3=Color3.fromRGB(255,82,104) t.TextSize=14 t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=f
local m=Instance.new("TextLabel") m.Size=UDim2.new(1,-20,1,-56) m.Position=UDim2.fromOffset(10,32) m.BackgroundTransparency=1 m.Font=Enum.Font.Code m.Text=tostring(__err) m.TextColor3=Color3.fromRGB(240,242,250) m.TextSize=10 m.TextWrapped=true m.TextXAlignment=Enum.TextXAlignment.Left m.TextYAlignment=Enum.TextYAlignment.Top m.Parent=f
local x=Instance.new("TextButton") x.Size=UDim2.fromOffset(60,24) x.Position=UDim2.new(1,-70,1,-30) x.BackgroundColor3=Color3.fromRGB(167,119,255) x.BorderSizePixel=0 x.Font=Enum.Font.GothamBold x.Text="CLOSE" x.TextColor3=Color3.new(1,1,1) x.TextSize=10 x.Parent=f
local xc=Instance.new("UICorner") xc.CornerRadius=UDim.new(0,8) xc.Parent=x x.MouseButton1Click:Connect(function() eg:Destroy() end) end) end

