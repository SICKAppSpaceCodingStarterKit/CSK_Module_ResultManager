---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('Data/ResultManager/helper/Json')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to create a json string out of expression parameters table content
---@param eventContent string[] Table with linked events for expression parameters
---@param valueContent string[] Table with current expression parameter values
---@return string jsonstring JSON string
local function createJsonListExpressionParameters(eventContent, valueContent)

  local list = {}
  if eventContent == nil then
    list = {{DTC_ParameterName = '-', DTC_LinkedEvent = '-', DTC_CurrentValue = '-'},}
  else

    for key, value in ipairs(eventContent) do
      local paramName = 'param' .. tostring(key)
      table.insert(list, {DTC_ParameterName = paramName, DTC_LinkedEvent = value, DTC_CurrentValue = valueContent[paramName]})
    end

    if #list == 0 then
      list = {{DTC_ParameterName = '-', DTC_LinkedEvent = '-', DTC_CurrentValue = '-'},}
    end
  end

  local jsonstring = funcs.json.encode(list)
  return jsonstring
end
funcs.createJsonListExpressionParameters = createJsonListExpressionParameters

--- Function to create a list with numbers
---@param size int Size of the list
---@return string list List of numbers
local function createStringListBySize(size)
  local list = "["
  if size >= 1 then
    list = list .. '"' .. tostring(1) .. '"'
  end
  if size >= 2 then
    for i=2, size do
      list = list .. ', ' .. '"' .. tostring(i) .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySize = createStringListBySize

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      if type(value) ~= 'function' then
        cont:add(key, value, nil)
      end
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to get content list out of table
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally seperated by ','
local function createContentList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return table.concat(sortedTable, ',')
end
funcs.createContentList = createContentList

--- Function to get content list as JSON string
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as JSON string
local function createJsonList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return funcs.json.encode(sortedTable)
end
funcs.createJsonList = createJsonList

--- Function to create a list from table
---@param content string[] Table with data entries
---@return string list String list
local function createStringListBySimpleTable(content)
  local list = "["
  if #content >= 1 then
    list = list .. '"' .. content[1] .. '"'
  end
  if #content >= 2 then
    for i=2, #content do
      list = list .. ', ' .. '"' .. content[i] .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

local function getAvailableEvents()
  local listOfEvents = {}

  local appNames = Engine.listApps()

  for key, value in pairs(appNames) do
    local startPos = string.find(value, '_', 5)
    if startPos then
      local crownName = 'CSK' .. string.sub(value, startPos, #value)
      local content = Engine.getCrownAsXML(crownName)
      local lastSearchPos = 0

      while true do
        local _, eventStart = string.find(content, 'event name="', lastSearchPos)
        if eventStart then
          lastSearchPos = eventStart+1
          local endPos = string.find(content, '"', eventStart+1)
          if endPos then
            local eventName = crownName .. '.' .. string.sub(content, eventStart+1, endPos-1)
            table.insert(listOfEvents, eventName)
          end
        else
          break
        end
      end
    end
  end
  return listOfEvents
end
funcs.getAvailableEvents = getAvailableEvents

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************