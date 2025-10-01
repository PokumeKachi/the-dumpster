local classes = {}

classes.Section = {}
classes.Section.__index = classes.Section
classes.Entry = {}
classes.Entry.__index = classes.Entry
classes.Definition = {}
classes.Definition.__index = classes.Definition

function classes.Section.new()
  local instance = setmetatable({}, classes.Section)
  instance.name = ""
  return instance
end

function classes.Section:SetName(name)
  self.name = name
end

function classes.Entry.new()
  local instance = setmetatable({}, classes.Entry)
  instance.word = nil
  instance.ipa = nil
  instance.definitions = {}
  instance.examples = {}
  return instance
end

function classes.Definition.new()
  local instance = setmetatable({}, classes.Definition)

  return instance
end

return classes
