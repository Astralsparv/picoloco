local db=fetch("pages.pod")

local titles={
    "|icoLoco",
    "P|coLoco",
    "Pi|oLoco",
    "Pic|Loco",
    "Pico|oco",
    "PicoL|co",
    "PicoLo|o",
    "PicoLoc|",
    "PicoLoco",
    "||||||||",
    "||||||||",
    "||||||||",
    "| boo! |",
    "| boo! |",
    "| boo! |",
    "| boo! |",
    "| boo! |",
    "| boo! |",
    "||||||||",
    "||||||||",
    "||||||||",
    "PicoLoco",
    "PicoLoc|",
    "PicoLo|o",
    "PicoL|co",
    "Pico|oco",
    "Pic|Loco",
    "Pi|oLoco",
    "P|coLoco",
    "|icoLoco",
}
local n=1
local dance=5

function _init()
    if (db) then
        local el=getElementById("availability")
        el:set("text","(online)")
        local count=0

        for _,_ in pairs(db) do
            count+=1
        end
        local el=pushElement("p8text",{text="Home to "..count.." pages!",align="center"})
        local el=pushElement("input",{id="input",placeholder="search query",enter=[[search(self.text)]],margin_left=2})
    else
        getElementById("availability"):set("text","Can't access the database")
    end
end

function _update()
    if ((dance>5) and (flr(rnd(36000))==0)) dance=0 --they won't believe you.
    dance+=1
    if (dance==5) then
        n+=1
        dance=0
        if (n>#titles) n=1 dance=5
        getElementById("title"):set("text",titles[n])
    end
end

function pushResult(url,data)
    local el=pushElement("link")
    local title="No Title"
    local author=""
    local description=""
    if (data.meta) then
        title=data.meta.title
        author=data.meta.author
        description=data.meta.description
    end
    el:set("text",title or "No Title")
    el:set("margin_left",2)
    el:set("margin_top",5)
    el:set("target",url)
    if (author!="") then
        local el=pushElement("p8text")
        el:set("text",author)
        el:set("margin_left",2)
        el:set("color",5)
    end
    if (description!="") then
        local el=pushElement("p8text")
        el:set("text",description)
        el:set("margin_left",2)
        el:set("color",5)
    end
    local el=pushElement("p8text")
    el:set("text",url)
    el:set("margin_left",2)
    el:set("color",5)
end

function push(str1,str2)
    if (str2) str1..=" "..str2
    return str1
end

function merge(a,b)
    local i,j=1,1
    local res={}
    local left,right={},{}
    while i<=#a and j<=#b do
        if (a[i].hits<b[j].hits) then
            add(res,a[i])
            i+=1
        else
            add(res,b[j])
            j+=1
        end
    end
    while i<=#a do
        add(res,a[i])
        i+=1
    end
    while j<=#b do
        add(res,b[j])
        j+=1
    end
    return res
end

function mergesort(table)
    if (#table<=1) return table
    local left={}
    local right={}
    for i=1,#table do
        if (i>#table/2) then
            add(right,table[i])
        else
            add(left,table[i])
        end
    end
    left=mergesort(left)
    right=mergesort(right)
    return merge(left,right)
end

function search(query)
    destroyElement("input")
    local el=pushElement("title")
    el:set("text","Searching for: "..query)
    el:set("margin_left",2)
    el:set("align","left")
    el:set("color",0)
    if (db) then
        query=query:lower()
        local finds={}
        for url,data in pairs(db) do
            local values=""
            if (data.meta) then
                values=push(values,data.meta.title)
                values=push(values,data.meta.description)
                values=push(values,data.meta.author)
                values=push(values,data.meta.url)
            end
            local count=0
            if (query=="") then
                count=1
            else
                while true do
                    local _,endindex=values:find(query, 1, true)
                    if (endindex==nil) break
                    values=values:sub(endindex+1,#values)
                    count+=1
                end
                values=data.text or ""
                local n=0
                while true do
                    local _,endindex=values:find(query, 1, true)
                    if (endindex==nil) break
                    values=values:sub(endindex+1,#values)
                    n+=1
                end
                n=min(25,n)
                count+=n/10
            end
            if (count>0) then
                if (finds[url]==nil) finds[url]=0
                finds[url]+=count
            end
        end
        local table={}
        for k,v in pairs(finds) do
            add(table,{url=k,hits=v})
        end
        table=mergesort(table)
        for i=1,#table do
            pushResult(table[i].url,db[table[i].url])
        end
    end
end