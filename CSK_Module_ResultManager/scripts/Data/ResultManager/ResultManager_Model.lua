---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_ResultManager'

local resultManager_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
resultManager_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
resultManager_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
resultManager_Model.parametersName = 'CSK_ResultManager_Parameter' -- name of parameter dataset to be used for this module
resultManager_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the ResultManager_Model interface and give access
-- to the ResultManager_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setResultManager_ModelHandle = require('Data/ResultManager/ResultManager_Controller')
setResultManager_ModelHandle(resultManager_Model)

--Loading helper functions if needed
resultManager_Model.helperFuncs = require('Data/ResultManager/helper/funcs')

-- Loading LuaXP as a simple arithmetic expression parser for Lua.
resultManager_Model.luaXP = require('Data/ResultManager/LuaXP')

resultManager_Model.selectedExpression = '' -- Name of selected expression to edit / show
resultManager_Model.newExpressionName = '' -- Name for new expression to create
resultManager_Model.selectedParameter = '' -- Selected parameter of expression

-- Parameters to be saved permanently if wanted
resultManager_Model.parameters = {}
resultManager_Model.parameters.expressions = {} -- Table of multiple expressions

-- Example of parameter structure
--[[
resultManager_Model.parameters.expressions[name] = {}
resultManager_Model.parameters.expressions[name].name -- Name of the expression, e.g. 'SumOfX+Y'.
resultManager_Model.parameters.expressions[name].expression -- The expression to process, e.g. 'param1 + param2' (regarding sources of parameter see ".events").
resultManager_Model.parameters.expressions[name].criteriaType -- What kind of criteria should be used to check the processed expression. Check ENUM "CriteriaType".
resultManager_Model.parameters.expressions[name].criteria -- Criteria to compare with expression result. If 'criteriaType' = 'RANGE' this is the minimum valid value.
resultManager_Model.parameters.expressions[name].criteriaMax -- If 'criteriaType' = 'RANGE' this is the maximum valid value.
resultManager_Model.parameters.expressions[name].events = {} -- Register to the events listed to receive values from other apps/modules. Event on position '1' is related to expression parameter 'param1' and so on ...
resultManager_Model.parameters.expressions[name].parameterPositions = {} -- Position of event parameter to use
resultManager_Model.parameters.expressions[name].data = {} -- Stores temporarily the incoming parameters, received by the configured events.
resultManager_Model.parameters.expressions[name].eventFunctions = {} -- Internally used functions to react on events of parameter values.
resultManager_Model.parameters.expressions[name].paramAmount -- Amount of parameters to collect before expression processing.
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to clear temporarily saved parameter data
local function clearParameterData(expressionName)
  if resultManager_Model.parameters.expressions[expressionName] then
    _G.logger:fine(nameOfModule .. ": Clear temporary data of expression '" .. expressionName .. "'.")
    for key, value in pairs(resultManager_Model.parameters.expressions[expressionName].data) do
      resultManager_Model.parameters.expressions[expressionName].data[key] = nil
    end
  end
end
resultManager_Model.clearParameterData = clearParameterData

-- Function to process predefined expression with optional data to use for this
---@param expressionName string Name of the expression to process
---@param data any[] Needed variables/data to process selected expression
local function process(expressionName, data)

  if resultManager_Model.parameters.expressions[expressionName] and resultManager_Model.parameters.expressions[expressionName]['expression'] ~= '' then
    local tempResult = nil
    local resultValue, err = resultManager_Model.luaXP.evaluate(resultManager_Model.parameters.expressions[expressionName]['expression'], data)

    if resultValue == nil then
      Script.notifyEvent('ResultManager_OnNewStatusResult', "Error in evaluation of expression: " .. err.message)
      error("Error in evaluation of expression: " .. err.message)
    else
      local suc = false
      local processOK = true

      if resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'RANGE' then
        -- Check if result is within criteria range
        if type(resultValue) == 'number' then
          if resultValue >= resultManager_Model.parameters.expressions[expressionName]['criteria'] and resultValue <= resultManager_Model.parameters.expressions[expressionName]['criteriaMax'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value is not of type 'number'")
          Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'NUMBER'")
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'NUMBER' then
        if type(resultValue) == 'number' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value is not of type 'number'")
          Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'NUMBER'")
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'BOOL' then
        if type(resultValue) == 'boolean' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value is not of type 'BOOL'")
          Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'BOOL'")
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'STRING' then
        if type(resultValue) == 'string' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value is not of type 'STRING'")
          Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'STRING'")
          processOK = false
        end
      end

      -- If currently selected show result on UI
      if expressionName == resultManager_Model.selectedExpression then
        Script.notifyEvent("ResultManager_OnNewStatusParameterList", resultManager_Model.helperFuncs.createJsonListExpressionParameters(resultManager_Model.parameters.expressions[expressionName].events, resultManager_Model.parameters.expressions[expressionName].data))
        if processOK then
          Script.notifyEvent('ResultManager_OnNewStatusResult', tostring(resultValue))
        end
        Script.notifyEvent('ResultManager_OnNewStatusCriteriaResult', suc)

      end

      _G.logger:info(nameOfModule .. ": Result of expression '" .. tostring(expressionName) .. "' = " .. tostring(suc))

      -- Push result via specific expression event
      if Script.isServedAsEvent("CSK_ResultManager.OnNewResult_" .. expressionName) then
        Script.notifyEvent('ResultManager_OnNewResult_'..expressionName, suc)
      end

      -- Clear parameters
      clearParameterData(expressionName)

    end
  else
    _G.logger:warning(nameOfModule .. ": No expression available.")
  end
end
resultManager_Model.process = process

-- Function to react on received values for expression parameters of registered events
---@param expressionName string Name of the expression
---@param paramName string Name of the parameter the value belongs to
---@param value1 any Value to update
---@param value2 any? Value to update
---@param value3 any? Value to update
---@param value4 any? Value to update
---@param value5 any Value to update
---@param value6 any? Value to update
---@param value7 any? Value to update
---@param value8 any? Value to update
local function setInternalValue(expressionName, paramName, value1, value2, value3, value4, value5, value6, value7, value8)
  local parameterLocation = tonumber(string.sub(paramName, #paramName, #paramName))
  if resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 1 and value1 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value1
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 2 and value2 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value2
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 3 and value3 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value3
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 4 and value4 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value4
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 5 and value5 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value5
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 6 and value6 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value6
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 7 and value7 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value7
  elseif resultManager_Model.parameters.expressions[expressionName].parameterPositions[parameterLocation] == 8 and value8 ~= nil then
    resultManager_Model.parameters.expressions[expressionName]['data'][paramName] = value8
  else
    _G.logger:fine(nameOfModule .. ": Parameter not available")
  end

  local allData = true
  for i = 1, resultManager_Model.parameters.expressions[expressionName]['paramAmount'], 1 do
    local tempParamName = 'param' .. tostring(i)
    if resultManager_Model.parameters.expressions[expressionName]['data'][tempParamName] == nil then
      allData = false
    end
  end

  -- If all param data was set, run the expression
  if allData and resultManager_Model.parameters.expressions[expressionName]['expression'] ~= '' then
    process(expressionName, resultManager_Model.parameters.expressions[expressionName]['data'])
  end
end

-- Function to deregister from parameter events
---@param expressionName string Name of the expression
local function deregisterFromParameterEvent(expressionName)
  _G.logger:fine(nameOfModule .. ": Deregister from parameter events of expression '" .. tostring(expressionName) .. "'.")
  for key, value in ipairs(resultManager_Model.parameters.expressions[expressionName].events) do
    if value ~= '' then
      local paramName = 'param' .. tostring(key)
      Script.deregister(value, resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName])
    end
  end
end
resultManager_Model.deregisterFromParameterEvent = deregisterFromParameterEvent

-- Function to register for parameter events
---@param expressionName string Name of the expression to register its parameter
local function registerToParameterEvents(expressionName)
  _G.logger:fine(nameOfModule .. ": Register to parameter events of expression '" .. tostring(expressionName) .. "'.")
  for key, value in ipairs(resultManager_Model.parameters.expressions[expressionName].events) do
    if Script.isServedAsEvent(value) then
      local paramName = 'param' .. tostring(key)
      local suc = Script.deregister(value, resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName])
      Script.register(value, resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName])
    else
      _G.logger:warning(nameOfModule .. ": Event '" .. tostring(value) .. "' is not available.")
    end
  end
end
resultManager_Model.registerToParameterEvents = registerToParameterEvents

-- Function to add parameter to expression to be received by an event
---@param expressionName string Name of the expression to add parameter
---@param paramNo int Number of parameter
---@param parameterPosition int? Optional parameter position of event
local function addParameter(expressionName, paramNo, parameterPosition)
  local paramName = 'param' .. tostring(paramNo)
  _G.logger:fine(nameOfModule .. ": Add '" .. paramName .. "' to expression '" .. expressionName .. "'.")
  local function addSource(updateValue1, updateValue2, updateValue3, updateValue4, updateValue5, updateValue6, updateValue7, updateValue8)
    setInternalValue(expressionName, paramName, updateValue1, updateValue2, updateValue3, updateValue4, updateValue5, updateValue6, updateValue7, updateValue8)
  end
  resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName] = addSource
  resultManager_Model.parameters.expressions[expressionName].paramAmount = paramNo

  if parameterPosition then
    resultManager_Model.parameters.expressions[expressionName].parameterPositions[paramNo] = parameterPosition
  end

  clearParameterData(expressionName)

end
resultManager_Model.addParameter = addParameter

local function addExpression(name, expression, criteriaType, criteria, criteriaMax, events, parameterPositions)
  if name then
    if not resultManager_Model.parameters.expressions[name] then
      _G.logger:info(nameOfModule .. ": Add expression '" .. tostring(name) .. "'.")
      resultManager_Model.parameters.expressions[name] = {}
      resultManager_Model.parameters.expressions[name].name = name
      resultManager_Model.parameters.expressions[name].criteriaType = criteriaType
      resultManager_Model.parameters.expressions[name].criteria = criteria
      if criteriaMax then
        resultManager_Model.parameters.expressions[name].criteriaMax = criteriaMax
      else
        resultManager_Model.parameters.expressions[name].criteriaMax = 99999999.0
      end
      resultManager_Model.parameters.expressions[name].expression = expression
      resultManager_Model.parameters.expressions[name].data = {}

      resultManager_Model.parameters.expressions[name].events = {}
      resultManager_Model.parameters.expressions[name].eventFunctions = {}
      resultManager_Model.parameters.expressions[name].parameterPositions = {}

      -- If a list of events is provided, register to this events.
      -- Register on event on position '1' in event list for parameter 'param1' and so on ...
      if events then
        resultManager_Model.parameters.expressions[name].events = events
        for key, value in ipairs(events) do

          local paramName = 'param' .. tostring(key)
          local function addSource(updateValue)
            setInternalValue(name, paramName, updateValue)
          end
          resultManager_Model.parameters.expressions[name].eventFunctions[paramName] = addSource

          if parameterPositions then
            table.insert(resultManager_Model.parameters.expressions[name].parameterPositions, parameterPositions[key])
          else
            table.insert(resultManager_Model.parameters.expressions[name].parameterPositions, 1)
          end

        end
        resultManager_Model.parameters.expressions[name].paramAmount = #events
        registerToParameterEvents(name)
      end

      if not Script.isServedAsEvent("CSK_ResultManager.OnNewResult_" .. name) then
        Script.serveEvent("CSK_ResultManager.OnNewResult_" .. name, "ResultManager_OnNewResult_" .. name, 'bool:1')
      end
      resultManager_Model.selectedExpression = name
    else
      _G.logger:warning(nameOfModule .. ": Expression already exists.")
    end
  else
    _G.logger:warning(nameOfModule .. ": No expression name defined.")
  end
end
Script.serveFunction('CSK_ResultManager.addExpression', addExpression)
resultManager_Model.addExpression = addExpression

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return resultManager_Model
