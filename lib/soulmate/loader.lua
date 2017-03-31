-- redis.eval(this 1 base_key min_complete phrase score id)

local Underscore = { funcs = {} }
function Underscore:new(value, chained)
  return setmetatable({ _val = value, chained = chained or false }, self)
end
function Underscore.iter(list_or_iter)
  if type(list_or_iter) == "function" then return list_or_iter end
  
  return coroutine.wrap(function() 
    for i=1,#list_or_iter do
      coroutine.yield(list_or_iter[i])
    end
  end)
end
function Underscore.funcs.each(list, func)
  for i in Underscore.iter(list) do
    func(i)
  end
  return list
end
function Underscore.funcs.flatten(array)
  local all = {}
  
  for ele in Underscore.iter(array) do
    if type(ele) == "table" then
      local flattened_element = Underscore.funcs.flatten(ele)
      Underscore.funcs.each(flattened_element, function(e) all[#all+1] = e end)
    else
      all[#all+1] = ele
    end
  end
  return all
end

MIN_COMPLETE = ARGV[1]

function normalize(str)
  return string.gsub(string.lower(str), "[^%w%s]", ''):gsub("^%s*(.-)%s*$", "%1")
end

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
  table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

function fragmentize(word)
  fragments = {}
  for i = MIN_COMPLETE, (#word - (MIN_COMPLETE -1)), 1 do
    table.insert(fragments, word:sub(0, i))
  end
  table.insert(fragments, word)
  return fragments
end

fragmented_words = {}
words = split(normalize(ARGV[2]), " ")
for i = 1, #words, 1 do
  table.insert(fragmented_words, fragmentize(words[i]))
end

fragments = Underscore.funcs.flatten(fragmented_words)

for i = 1, #fragments, 1 do
  redis.call('sadd', KEYS[1], fragments[i])
  redis.call('zadd', KEYS[1]..":"..fragments[i], ARGV[3], ARGV[4])
end