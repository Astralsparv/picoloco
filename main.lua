local db=fetch("pages.pod")
local hitWeight=2

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
local appendScores=(__queries.score!=nil)
local q=__queries.q

function _init()
    if (db) then
        local el=dom.getElementById("availability")
        el:set("text","(online)")
        local count=0

        for _,_ in pairs(db) do
            count+=1
        end
        local el=dom.pushElement("p8text",{text="Home to "..count.." pages!",align="center"})
        local el=dom.pushElement("input",{id="input",placeholder="search query",enter=[[search(self.text)]],margin_left=2})
        if (q) then
            search(q,true)
        end
    else
        dom.getElementById("availability"):set("text","Can't access the database")
    end
end

function _update()
    if ((dance>5) and (flr(rnd(36000))==0)) dance=0 --they won't believe you.
    dance+=1
    if (dance==5) then
        n+=1
        dance=0
        if (n>#titles) n=1 dance=5
        dom.getElementById("title"):set("text",titles[n])
    end
end

function pushResult(url,data,score)
    local el=dom.pushElement("link")
    local title="No Title"
    local author=""
    local description=""
    if (data.meta) then
        title=data.meta.title
        author=data.meta.author
        description=data.meta.description
    end
    el:set("text",title or "No Title")
    el:set("margin_top",5)
    el:set("target",url)
    if (author!="") then
        local el=dom.pushElement("text")
        el:set("text",author)
        el:set("class","smalltext")
    end
    if (description!="") then
        local el=dom.pushElement("text")
        el:set("text",description)
        el:set("class","smalltext")
    end
    local el=dom.pushElement("text")
    el:set("text",url)
    el:set("class","smalltext")
    if (appendScores) then
        local el=dom.pushElement("text")
        el:set("text","score: "..score)
        el:set("class","smalltext")
    end
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
        if (a[i].hits>b[j].hits) then
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

function search(q,querying)
    if (not querying) then
        if (q=="") q=" " -- returns nil if query == ""
        file.openPage("?q="..query.pack(q),"self")
        return
    end
    local el=dom.pushElement("title")
    el:set("text","Searching for: "..q)
    el:set("margin_left",2)
    el:set("align","left")
    el:set("color",0)
    if (db) then
        q=q:lower()
        local finds={}
        for url,data in pairs(db) do
            local values=""
            if (data.meta) then
                values=push(values,data.meta.title)
                values=push(values,data.meta.description)
                values=push(values,data.meta.author)
                values=push(values,data.meta.url)
            end
            values=values:lower()
            local count=0
            if (q=="" or q==" ") then
                count=1
            else
                local queries=q:split(" ")
                for i=0, #queries do
                    local c=0
                    local q=queries[i] or q --also search full string
                    if (q!="") then
                        while true do
                            local _,endindex=values:find(q, 1, true)
                            if (endindex==nil) break
                            values=values:sub(endindex+1,#values)
                            c+=1
                        end
                        values=(data.text or ""):lower()
                        local n=0
                        while true do
                            local _,endindex=values:find(q, 1, true)
                            if (endindex==nil) break
                            values=values:sub(endindex+1,#values)
                            n+=1
                        end
                        n=min(25,n)
                        c+=n/10
                        count+=c
                    end
                end
            end
            if (count>0) then
                if (finds[url]==nil) finds[url]=0
                finds[url]+=count
                finds[url]+=db[url].hits*hitWeight
            end
        end
        local table={}
        for k,v in pairs(finds) do
            add(table,{url=k,hits=v}) --hits = score, should rename
        end
        table=mergesort(table)
        if (#table>0) then
            local results=dom.pushElement("text",{text=#table.." results found",margin_left=2})
        else
            local results=dom.pushElement("text",{text="no results found :(",margin_left=2})
        end
        for i=1,#table do
            pushResult(table[i].url,db[table[i].url],finds[table[i].url])
        end
    end
end