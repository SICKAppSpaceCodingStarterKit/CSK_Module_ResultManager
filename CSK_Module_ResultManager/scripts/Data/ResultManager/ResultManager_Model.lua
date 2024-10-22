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

resultManager_Model.showProcessData = false -- Status if process data should be shown in UI
resultManager_Model.selectedExpression = '' -- Name of selected expression to edit / show
resultManager_Model.newExpressionName = 'ExpressionName' -- Name for new expression to create
resultManager_Model.selectedParameter = '' -- Selected parameter of expression
resultManager_Model.styleForUI = 'None' -- Optional parameter to set UI style
resultManager_Model.version = Engine.getCurrentAppVersion() -- Version of module

-- Parameters to be saved permanently if wanted
resultManager_Model.parameters = {}
resultManager_Model.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
resultManager_Model.parameters.expressions = {} -- Table of multiple expressions

-- Example of parameter structure
--[[
resultManager_Model.parameters.expressions[name] = {}
resultManager_Model.parameters.expressions[name].name -- Name of the expression, e.g. 'SumOfX+Y'.
resultManager_Model.parameters.expressions[name].mergeData -- Status if it only should merge data to e.g. forward multiple data via new event.
resultManager_Model.parameters.expressions[name].expression -- The expression to process, e.g. 'param1 + param2' (regarding sources of parameter see ".events").
resultManager_Model.parameters.expressions[name].criteriaType -- What kind of criteria should be used to check the processed expression. Check ENUM "CriteriaType".
resultManager_Model.parameters.expressions[name].criteria -- Criteria to compare with expression result. If 'criteriaType' = 'RANGE' this is the minimum valid value.
resultManager_Model.parameters.expressions[name].criteriaMax -- If 'criteriaType' = 'RANGE' this is the maximum valid value.
resultManager_Model.parameters.expressions[name].events = {} -- Register to the events listed to receive values from other apps/modules. Event on position '1' is related to expression parameter 'param1' and so on ...
resultManager_Model.parameters.expressions[name].parameterPositions = {} -- Position of event parameter to use
resultManager_Model.parameters.expressions[name].data = {} -- Stores temporarily the incoming parameters, received by the configured events.
resultManager_Model.parameters.expressions[name].eventFunctions = {} -- Internally used functions to react on events of parameter values.
resultManager_Model.parameters.expressions[name].paramAmount -- Amount of parameters to collect before expression processing.
resultManager_Model.parameters.expressions[name].checkCriteraToForward -- Status if results should only be forwarded via events if criteria was valid
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  resultManager_Model.styleForUI = theme
  Script.notifyEvent("ResultManager_OnNewStatusCSKStyle", resultManager_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

local function stringPack(args)
  local res = NULLATOM
  if type(args[1]) == 'string' then
    local paramSize = #args.__context.__packParam

    if paramSize == 1 then
      res = string.pack(args[1], args.__context.__packParam[1])
    elseif paramSize == 2 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2])
    elseif paramSize == 3 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3])
    elseif paramSize == 4 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3], args.__context.__packParam[4])
    elseif paramSize == 5 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3], args.__context.__packParam[4], args.__context.__packParam[5])
    elseif paramSize == 6 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3], args.__context.__packParam[4], args.__context.__packParam[5], args.__context.__packParam[6])
    elseif paramSize == 7 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3], args.__context.__packParam[4], args.__context.__packParam[5], args.__context.__packParam[6], args.__context.__packParam[7])
    elseif paramSize == 8 then
      res = string.pack(args[1], args.__context.__packParam[1], args.__context.__packParam[2], args.__context.__packParam[3], args.__context.__packParam[4], args.__context.__packParam[5], args.__context.__packParam[6], args.__context.__packParam[7], args.__context.__packParam[8])
    end
  end
  args.__context.__packParam = {}
  return res
end

local function stringUnpack(args)
  local res = NULLATOM
  if type(args[1]) == 'string' then
    if args.__context.__unpackParam[2] ~= nil and args.__context.__unpackParam[3] ~= nil then
      -- Cut string
      args.__context.__unpackParam[1] = string.sub(args.__context.__unpackParam[1], args.__context.__unpackParam[2], args.__context.__unpackParam[3])
    end
    res = string.unpack(args[1], args.__context.__unpackParam[1])
  end
  args.__context.__unpackParam = {}
  return res
end

local function searchAndCut(args)
  local res = NULLATOM
  if type(args.__context.__searchAndCutParam[1]) == 'string' then
    if args.__context.__searchAndCutParam[2] ~= nil and args.__context.__searchAndCutParam[3] ~= nil then --and args.__context.__searchAndCutParam[4] ~= nil and args.__context.__searchAndCutParam[5] ~= nil then
      local foundStart = string.find(args.__context.__searchAndCutParam[1], args.__context.__searchAndCutParam[2])
      if foundStart then
        local foundEnd = string.find(args.__context.__searchAndCutParam[1], args.__context.__searchAndCutParam[3], foundStart+1)
        if foundEnd then
          if args.__context.__searchAndCutParam[4] ~= nil and args.__context.__searchAndCutParam[5] ~= nil then
            res = string.sub(args.__context.__searchAndCutParam[1], foundStart+args.__context.__searchAndCutParam[4], foundEnd+args.__context.__searchAndCutParam[5])
          else
            res = string.sub(args.__context.__searchAndCutParam[1], foundStart, foundEnd)
          end
        end
      end
    end
  end
  args.__context.__searchAndCutParam = {}
  return res
end

local context = {}
context.__functions = {}
context.__packParam = {}
context.__unpackParam = {}
context.__searchAndCutParam = {}

context.__functions.stringPack = stringPack
context.__functions.stringUnpack = stringUnpack
context.__functions.searchAndCut = searchAndCut

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
  local expr = resultManager_Model.parameters.expressions[expressionName]['expression']
  if resultManager_Model.parameters.expressions[expressionName] and expr ~= '' then
    local resultValue, err
    if string.sub(expr, 1, 10) == 'stringPack' then
      local foundPos = 0
      local cnt = 1
      local foundParam = string.find(expr, 'param', foundPos)
      while foundParam do
        local paramPos = 'param' .. tostring(cnt)
        context.__packParam[cnt] = data[paramPos]
        cnt = cnt + 1
        foundPos = foundParam + 1
        foundParam = string.find(expr, 'param', foundPos)
        if not foundParam then
          break
        end
      end
      local pos = string.find(expr, ',')
      if pos then
        local newExpr = string.sub(expr, 1, pos-1) .. ')'
        resultValue, err = resultManager_Model.luaXP.evaluate(newExpr, context)
      end
    elseif string.sub(expr, 1, 12) == 'stringUnpack' then
      local foundParam = string.find(expr, 'param')
      if foundParam then
        local paramNumber = string.sub(expr, foundParam+5, foundParam+5)
        local paramPos = 'param' .. tostring(paramNumber)
        context.__unpackParam[1] = data[paramPos]

        local pos = string.find(expr, ',')

        if pos then
          local newExpr = string.sub(expr, 1, pos-1) .. ')'

          -- Check if string needs to be cutted
          local subStartPos = string.find(expr, ',', pos+1)
          if subStartPos then
            local subEndPos = string.find(expr, ',', subStartPos+1)

            if subStartPos then
              local expEndPos = string.find(expr, ')', subEndPos+1)

              local startPosToCut = string.sub(expr, subStartPos+1, subEndPos-1)
              local endPosToCut = string.sub(expr, subEndPos+1, expEndPos-1)

              startPosToCut = startPosToCut:gsub("%s+", "")
              startPosToCut = string.gsub(startPosToCut, "%s+", "")

              endPosToCut = endPosToCut:gsub("%s+", "")
              endPosToCut = string.gsub(endPosToCut, "%s+", "")

              context.__unpackParam[2] = tonumber(startPosToCut)
              context.__unpackParam[3] = tonumber(endPosToCut)
            end
          end
          resultValue, err = resultManager_Model.luaXP.evaluate(newExpr, context)
        end
      end
    elseif string.sub(expr, 1, 12) == 'searchAndCut' then

      local foundParam = string.find(expr, 'param')
      if foundParam then
        local paramNumber = string.sub(expr, foundParam+5, foundParam+5)
        local paramPos = 'param' .. tostring(paramNumber)
        context.__searchAndCutParam[1] = data[paramPos]
        local firstParamStart = string.find(expr, "'")

        if firstParamStart then
          local newExpr = string.sub(expr, 1, firstParamStart-1) .. ')'

          -- Check for additional parameters
          local firstParamEnd = string.find(expr, "'", firstParamStart+1)
          if firstParamEnd then
            local secondParamStart = string.find(expr, "'", firstParamEnd+1)
            if secondParamStart then
              local secondParamEnd = string.find(expr, "'", secondParamStart+1)
              if secondParamEnd then
                local thirdParamStart = string.find(expr, ",", secondParamEnd+1)
                if thirdParamStart then
                  local thirdParamEnd = string.find(expr, ",", thirdParamStart+1)
                  if thirdParamEnd then
                    local fourthParamEnd = string.find(expr, ")", thirdParamEnd+2)
                    if fourthParamEnd then
                      context.__searchAndCutParam[2] = string.sub(expr, firstParamStart+1, firstParamEnd-1)
                      context.__searchAndCutParam[3] = string.sub(expr, secondParamStart+1, secondParamEnd-1)

                      local tempParam4 = string.sub(expr, thirdParamStart+1, thirdParamEnd-1)
                      tempParam4 = tempParam4:gsub("%s+", "")
                      tempParam4 = string.gsub(tempParam4, "%s+", "")
                      context.__searchAndCutParam[4] = tonumber(tempParam4)

                      local tempParam5 = string.sub(expr, thirdParamEnd+1, fourthParamEnd-1)
                      tempParam5 = tempParam5:gsub("%s+", "")
                      tempParam5 = string.gsub(tempParam5, "%s+", "")
                      context.__searchAndCutParam[5] = tonumber(tempParam5)
                    end
                  end
                else
                  context.__searchAndCutParam[2] = string.sub(expr, firstParamStart+1, firstParamEnd-1)
                  context.__searchAndCutParam[3] = string.sub(expr, secondParamStart+1, secondParamEnd-1)
                end
              end
            end
          end
          resultValue, err = resultManager_Model.luaXP.evaluate("searchAndCut('Blub')", context)
        end
      end
    else
      resultValue, err = resultManager_Model.luaXP.evaluate(expr, data)
    end
    -----------------------------

    if resultValue == nil then
      Script.notifyEvent('ResultManager_OnNewStatusResult', "Error in evaluation of expression: " .. tostring(err.message))
      _G.logger:warning(nameOfModule .. ": Error in evaluation of expression: " .. tostring(err.message))
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
          _G.logger:warning(nameOfModule .. ": Value of expression '" .. expressionName .. "' is not of type 'number'")
          if expressionName == resultManager_Model.selectedExpression then
            Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'NUMBER'")
          end
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'NUMBER' then
        if type(resultValue) == 'number' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value of expression '" .. expressionName .. "' is not of type 'number'")
          if expressionName == resultManager_Model.selectedExpression then
            Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'NUMBER'")
          end
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'BOOL' then
        if type(resultValue) == 'boolean' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value of expression '" .. expressionName .. "' is not of type 'BOOL'")
          if expressionName == resultManager_Model.selectedExpression then
            Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'BOOL'")
          end
          processOK = false
        end
      elseif resultManager_Model.parameters.expressions[expressionName]['criteriaType'] == 'STRING' then
        if type(resultValue) == 'string' then
          -- Check if result is equal to criteria
          if resultValue == resultManager_Model.parameters.expressions[expressionName]['criteria'] then
            suc = true
          end
        else
          _G.logger:warning(nameOfModule .. ": Value of expression '" .. expressionName .. "' is not of type 'STRING'")
          if expressionName == resultManager_Model.selectedExpression then
            Script.notifyEvent('ResultManager_OnNewStatusResult', "Value is not of type 'STRING'")
          end
          processOK = false
        end
      end

      -- If currently selected show result on UI
      if expressionName == resultManager_Model.selectedExpression and resultManager_Model.showProcessData then
        Script.notifyEvent("ResultManager_OnNewStatusParameterList", resultManager_Model.helperFuncs.createJsonListExpressionParameters(resultManager_Model.parameters.expressions[expressionName].events, resultManager_Model.parameters.expressions[expressionName].data, resultManager_Model.selectedParameter))
        if processOK then
          Script.notifyEvent('ResultManager_OnNewStatusResult', tostring(resultValue))
        end
        Script.notifyEvent('ResultManager_OnNewStatusCriteriaResult', suc)
      end

      _G.logger:fine(nameOfModule .. ": Result of expression '" .. tostring(expressionName) .. "' = " .. tostring(suc))

      -- Push result via specific expression event
      if Script.isServedAsEvent("CSK_ResultManager.OnNewCriteriaResult_" .. expressionName) then
        Script.notifyEvent('ResultManager_OnNewCriteriaResult_'..expressionName, suc)
      end
      if Script.isServedAsEvent("CSK_ResultManager.OnNewResult_" .. expressionName) then
        if resultManager_Model.parameters.expressions[expressionName].checkCriteraToForward == true then
          -- Only notify result if criteria was valid
          if suc then
            Script.notifyEvent('ResultManager_OnNewResult_'..expressionName, resultValue)
          end
        else
          Script.notifyEvent('ResultManager_OnNewResult_'..expressionName, resultValue)
        end
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
---@param value5 any? Value to update
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
  if allData then
    if resultManager_Model.parameters.expressions[expressionName].mergeData == true then
      if Script.isServedAsEvent("CSK_ResultManager.OnNewData_" .. expressionName) then
        local dataAmount = resultManager_Model.parameters.expressions[expressionName]['paramAmount']
        if dataAmount == 1 then
          Script.notifyEvent('ResultManager_OnNewData_'..expressionName, resultManager_Model.parameters.expressions[expressionName]['data']['param1'])
        elseif dataAmount == 2 then
          Script.notifyEvent('ResultManager_OnNewData_'..expressionName, resultManager_Model.parameters.expressions[expressionName]['data']['param1'], resultManager_Model.parameters.expressions[expressionName]['data']['param2'])
        elseif dataAmount == 3 then
          Script.notifyEvent('ResultManager_OnNewData_'..expressionName, resultManager_Model.parameters.expressions[expressionName]['data']['param1'], resultManager_Model.parameters.expressions[expressionName]['data']['param2'], resultManager_Model.parameters.expressions[expressionName]['data']['param3'])
        elseif dataAmount == 4 then
          Script.notifyEvent('ResultManager_OnNewData_'..expressionName, resultManager_Model.parameters.expressions[expressionName]['data']['param1'], resultManager_Model.parameters.expressions[expressionName]['data']['param2'], resultManager_Model.parameters.expressions[expressionName]['data']['param3'], resultManager_Model.parameters.expressions[expressionName]['data']['param4'])
        end
        -- Clear parameters
        clearParameterData(expressionName)
      end
    elseif resultManager_Model.parameters.expressions[expressionName]['expression'] ~= '' then
      process(expressionName, resultManager_Model.parameters.expressions[expressionName]['data'])
    end
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
      local paramName = 'param' .. tostring(key)
      Script.deregister(value, resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName])
      Script.register(value, resultManager_Model.parameters.expressions[expressionName].eventFunctions[paramName])
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

local function addExpression(name, mergeData, expression, criteriaType, criteria, criteriaMax, events, parameterPositions)
  if name then
    if not resultManager_Model.parameters.expressions[name] then
      _G.logger:fine(nameOfModule .. ": Add expression '" .. tostring(name) .. "'.")
      resultManager_Model.parameters.expressions[name] = {}
      resultManager_Model.parameters.expressions[name].name = name
      resultManager_Model.parameters.expressions[name].mergeData = mergeData
      resultManager_Model.parameters.expressions[name].criteriaType = criteriaType
      resultManager_Model.parameters.expressions[name].criteria = criteria
      resultManager_Model.parameters.expressions[name].checkCriteraToForward = false
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
          local function addSource(updateValue1, updateValue2, updateValue3, updateValue4, updateValue5, updateValue6, updateValue7, updateValue8)
            setInternalValue(name, paramName, updateValue1, updateValue2, updateValue3, updateValue4, updateValue5, updateValue6, updateValue7, updateValue8)
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

      if not Script.isServedAsEvent("CSK_ResultManager.OnNewCriteriaResult_" .. name) then
        Script.serveEvent("CSK_ResultManager.OnNewCriteriaResult_" .. name, "ResultManager_OnNewCriteriaResult_" .. name, 'bool:1')
      end
      if not Script.isServedAsEvent("CSK_ResultManager.OnNewResult_" .. name) then
        Script.serveEvent("CSK_ResultManager.OnNewResult_" .. name, "ResultManager_OnNewResult_" .. name, 'auto:1')
      end
      if not Script.isServedAsEvent("CSK_ResultManager.OnNewData_" .. name) then
        Script.serveEvent("CSK_ResultManager.OnNewData_" .. name, "ResultManager_OnNewData_" .. name, 'auto:?,auto:?,auto:?,auto:?')
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
