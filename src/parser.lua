local raw = io.open('src/raw-dumpster.txt', 'r')

local MAX_LINE = 1000
local ELEMENT_SIZES = {
  section = 1.7,
  group = 1.7,

  word = 1.5,
  ipa = 1.2,
  definition = 1,
  example = 1,
  horizontal_rule = 1.5,
}
local SIZE_SCALE = 27

for i, j in pairs(ELEMENT_SIZES) do
  ELEMENT_SIZES[i] = j * SIZE_SCALE
end

CUSTOM_ID = 'custom-id-by-parser-'

local function split(input, delimiter)
    local result = {}

    for match in (input..delimiter):gmatch('(.-)'..delimiter) do
        table.insert(result, match)
    end

    return result
end

local function horizontal_rule(count)
  print('\n'..string.rep('---\n', count))
end

local line_cache = 0

local function page_break(length)
  line_cache = line_cache + length
  if line_cache >= MAX_LINE then
    line_cache = length
    print('\\newpage')
  else
    line_cache = line_cache + ELEMENT_SIZES.horizontal_rule
    horizontal_rule(1)
  end
end

local function tagify(name)
  local tag = string.gsub(name:lower(), ' ', '-')
  tag = string.gsub(tag, '[^%w%-]', '')  -- Remove special characters
  return tag
end

local function tokenizer(line)
  local TOKEN_POS = 2
  local END_POS = nil

  --[[for i = 1, #line do
    if string.sub(line, i, i) == ' ' then
      TOKEN_POS = i
      break
    end
  end

  for i = #line, 1, -1 do
    if string.sub(line, i, i) ~= ' ' then
      END_POS = i
      break
    end
  end

  if TOKEN_POS == nil or END_POS == nil then
    return
  end]]

  for i = #line, 1, -1 do
    if string.sub(line, i, i) ~= ' ' and not END_POS then
      END_POS = i
    end

    if string.sub(line, i, i) == '^' then
      TOKEN_POS = i + 1
      break
    end
  end

  return string.sub(line, 1, TOKEN_POS - 1),string.sub(line, TOKEN_POS + 1, END_POS)
end

local function word_data_parse(data, word)
  print('# *'..word..'*\n')

  if arg[1] ~= '--no-table' then
    if data.ipa then
      print('#### [ '..data.ipa..']\n')
    end

    for _, definition in ipairs(data.definitions) do
      if definition.type then
        print('[ '..definition.type..' ] '..definition.content..'\n')
      else
        print(definition.content..'\n')
      end

      for _, example in ipairs(definition.examples) do
        print('> *'..string.gsub(example, "%*", "**")..'*\n')
      end
    end
  else -- PDF
    if data.ipa then

      print('## [ '..string.gsub(data.ipa, 'ˈ', "'")..']\n')

    end

    for _, definition in ipairs(data.definitions) do
      if definition.type then
        print('- **[ '..definition.type..' ]** '..definition.content..'\n')
      else
        print('- '..definition.content..'\n')
      end

      for _, example in ipairs(definition.examples) do
        local yes = true

        for i=1,string.len(example) do
          if string.sub(example,i,i) == '*' then
            yes = false
            break
          end
        end

        if yes then
          print('ASTERISK EMERGENCY')
        end

        print('- - *'..string.gsub(example, "%*", "**")..'*\n')
      end
    end
  end
end

local function get_data_length(data)
  local value = ELEMENT_SIZES.word

  if data.ipa then
    value = value + ELEMENT_SIZES.ipa
  end

  local definition_count = 0
  local example_count = 0

  for _, definition in ipairs(data.definitions) do
    definition_count = definition_count + 1

    for _ in ipairs(definition.examples) do
      example_count = example_count + 1
    end
  end

  value = value + ELEMENT_SIZES.definition * definition_count + ELEMENT_SIZES.example * example_count

  return value
end

local function parse(LAYOUT)
  local sections = {}

  for section,_ in pairs(LAYOUT) do
    table.insert(sections, section)
  end

  table.sort(sections)

  if arg[1] ~= '--no-table' then
   print('# TABLE OF DUMPSTENTS\n')

    -- For some goddamn reason, Obsidian uses a completely different heading linking syntax
    -- so fall back on this whenever it's not working

    --[[for _, section in ipairs(sections) do
      print('['..section..']'..'(#'..tagify(section)..')\n')
    end]]

    for _, section in ipairs(sections) do
      print('[[#'..section..']]')
    end

    horizontal_rule(2)
  end

  for _, section in ipairs(sections) do
    line_cache = ELEMENT_SIZES.section
    print('\\newpage')
    print('\\begin{center}')

    print('{\\Huge '..section..' DUMPSTER}')

    print('\\end{center}')
    print()

    if arg[1] ~= '--no-table' then
      print('##### [[#TABLE OF DUMPSTENTS|BACK]]')
    end

    horizontal_rule(2)

    local groups = {}

    for group_name, _ in pairs(LAYOUT[section].__groups) do
      table.insert(groups, group_name)
    end

    table.sort(groups)

    for _, group_name in ipairs(groups) do
      local group = LAYOUT[section].__groups[group_name]
      local length = ELEMENT_SIZES.group
      for word, word_data in pairs(group) do
        if word ~= '__showname' then
          length = length + get_data_length(word_data)
        end
      end

      page_break(length)

      if group.__showname then
        print('\\begin{center}')
        print('{\\LARGE '..group_name..'}')
        print('\\end{center}')
      end

      for word, word_data in pairs(group) do
        if word ~= '__showname' then
          word_data_parse(word_data, word)
        end
      end

      --horizontal_rule(1)

      --print(line_cache)
    end


    local words = {}

    for word, _ in pairs(LAYOUT[section]) do
      if word ~= '__groups' then
        table.insert(words, word)
      end
    end

    table.sort(words)

    for _, word in ipairs(words) do
      local data = LAYOUT[section][word]

      page_break(get_data_length(data))

      word_data_parse(data, word)

      --horizontal_rule(1)

      --print(line_cache)
    end
  end
end

if not raw then
  print('Could not open files.')
  os.exit()
end

LAYOUT = {}

local current_word_data = {}
local word = nil
local section = nil
local group = nil

local i = 0

local function add_entry()
  if word ~= nil then
    if not group then
      if section then
        LAYOUT[section][word] = current_word_data
      -- else
      --   print("no FUCKING section")
      end
    else
      LAYOUT[section].__groups[group][word] = current_word_data
    end

    section = nil
    group = nil
    current_word_data = {}
  end
end

for line in raw:lines() do
  i = i + 1
  --print(i)
  local token,input = tokenizer(line)

  if not token or not input or (string.sub(token, #token, #token)) ~= '^' then
    goto continue
  end

  local tokens = split(token, '^')

  if tokens[1] == 'WORD' then
    add_entry()
    word = input
    current_word_data.definitions = {}
  end

  if tokens[1] == 'SEC' then
    section = input

    if not LAYOUT[section] then
      LAYOUT[section] = {__groups = {},}
    end
  end

  if tokens[1] == 'GR' then
    group = input

    if not LAYOUT[section].__groups[group] then
      LAYOUT[section].__groups[group] = {}
    end
  end

  if tokens[1] == 'GR*' then
    group = input

    if not LAYOUT[section].__groups[group] then
      LAYOUT[section].__groups[group] = {}
    end

    LAYOUT[section].__groups[group].__showname = true
  end

  if tokens[1] == 'IPA' then
    current_word_data.ipa = input
  end

  if tokens[1] == 'DEF' then
    table.insert(current_word_data.definitions, {
      content = input;
      examples = {};
    })

    if tokens[2] and tokens[2] ~= '' then
      current_word_data.definitions[#current_word_data.definitions].type = tokens[2]
    else
    end
  end

  if tokens[1] == 'EX' then
    table.insert(current_word_data.definitions[#current_word_data.definitions].examples, input)
  end

  ::continue::
end

add_entry()

parse(LAYOUT)

raw:close()


