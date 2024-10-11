---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the ResultManager_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_ResultManager'

-- Timer to update UI via events after page was loaded
local tmrResultManager = Timer.create()
tmrResultManager:setExpirationTime(300)
tmrResultManager:setPeriodic(false)

-- Reference to global handle
local resultManager_Model

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
Script.serveEvent('CSK_ResultManager.OnNewResult_EXPRESSION', 'OnNewResult_EXPRESSION')
Script.serveEvent('CSK_ResultManager.OnNewCriteriaResult_EXPRESSION', 'OnNewCriteriaResult_EXPRESSION')
Script.serveEvent('CSK_ResultManager.OnNewData_EXPRESSION', 'OnNewData_EXPRESSION')

----------------------------------------------------------------

-- Real events
--------------------------------------------------

Script.serveEvent('CSK_ResultManager.OnNewStatusModuleVersion', 'ResultManager_OnNewStatusModuleVersion')
Script.serveEvent('CSK_ResultManager.OnNewStatusCSKStyle', 'ResultManager_OnNewStatusCSKStyle')
Script.serveEvent('CSK_ResultManager.OnNewStatusModuleIsActive', 'ResultManager_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_ResultManager.OnNewStatusExpressionSelected', 'ResultManager_OnNewStatusExpressionSelected')
Script.serveEvent('CSK_ResultManager.OnNewStatusListOfExpressions', 'ResultManager_OnNewStatusListOfExpressions')
Script.serveEvent('CSK_ResultManager.OnNewStatusSelectedExpression', 'ResultManager_OnNewStatusSelectedExpression')
Script.serveEvent('CSK_ResultManager.OnNewStatusExpressionName', 'ResultManager_OnNewStatusExpressionName')

Script.serveEvent('CSK_ResultManager.OnNewStatusEventInfo', 'ResultManager_OnNewStatusEventInfo')

Script.serveEvent('CSK_ResultManager.OnNewStatusMergeData', 'ResultManager_OnNewStatusMergeData')
Script.serveEvent('CSK_ResultManager.OnNewStatusExpression', 'ResultManager_OnNewStatusExpression')
Script.serveEvent('CSK_ResultManager.OnNewStatusResult', 'ResultManager_OnNewStatusResult')
Script.serveEvent('CSK_ResultManager.OnNewStatusCriteriaResult', 'ResultManager_OnNewStatusCriteriaResult')

Script.serveEvent('CSK_ResultManager.OnNewStatusCriteriaType', 'ResultManager_OnNewStatusCriteriaType')
Script.serveEvent('CSK_ResultManager.OnNewStatusCriteria', 'ResultManager_OnNewStatusCriteria')
Script.serveEvent('CSK_ResultManager.OnNewStatusCriteriaString', 'ResultManager_OnNewStatusCriteriaString')

Script.serveEvent('CSK_ResultManager.OnNewStatusCriteriaMaximum', 'ResultManager_OnNewStatusCriteriaMaximum')
Script.serveEvent('CSK_ResultManager.OnNewStatusParameterList', 'ResultManager_OnNewStatusParameterList')

Script.serveEvent('CSK_ResultManager.OnNewStatusSelectedParameter', 'ResultManager_OnNewStatusSelectedParameter')
Script.serveEvent('CSK_ResultManager.OnNewStatusLinkedEvent', 'ResultManager_OnNewStatusLinkedEvent')
Script.serveEvent('CSK_ResultManager.OnNewStatusEventParameterPosition', 'ResultManager_OnNewStatusEventParameterPosition')

Script.serveEvent('CSK_ResultManager.OnNewStatusAvailableEvents', 'ResultManager_OnNewStatusAvailableEvents')

Script.serveEvent('CSK_ResultManager.OnNewStatusFlowConfigPriority', 'ResultManager_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_ResultManager.OnNewStatusLoadParameterOnReboot", "ResultManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_ResultManager.OnPersistentDataModuleAvailable", "ResultManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_ResultManager.OnNewParameterName", "ResultManager_OnNewParameterName")
Script.serveEvent("CSK_ResultManager.OnDataLoadedOnReboot", "ResultManager_OnDataLoadedOnReboot")

Script.serveEvent('CSK_ResultManager.OnUserLevelOperatorActive', 'ResultManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelMaintenanceActive', 'ResultManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelServiceActive', 'ResultManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelAdminActive', 'ResultManager_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("ResultManager_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("ResultManager_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("ResultManager_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("ResultManager_OnUserLevelAdminActive", status)
end

--- Function to get access to the resultManager_Model object
---@param handle handle Handle of resultManager_Model object
local function setResultManager_Model_Handle(handle)
  resultManager_Model = handle
  if resultManager_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if resultManager_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("ResultManager_OnUserLevelAdminActive", true)
    Script.notifyEvent("ResultManager_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("ResultManager_OnUserLevelServiceActive", true)
    Script.notifyEvent("ResultManager_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrResultManager()

  updateUserLevel()

  Script.notifyEvent("ResultManager_OnNewStatusModuleVersion", 'v' .. resultManager_Model.version)
  Script.notifyEvent("ResultManager_OnNewStatusCSKStyle", resultManager_Model.styleForUI)
  Script.notifyEvent("ResultManager_OnNewStatusModuleIsActive", _G.availableAPIs.default)

  Script.notifyEvent("ResultManager_OnNewStatusListOfExpressions", resultManager_Model.helperFuncs.createJsonList(resultManager_Model.parameters.expressions))
  Script.notifyEvent("ResultManager_OnNewStatusSelectedExpression", resultManager_Model.selectedExpression)
  Script.notifyEvent("ResultManager_OnNewStatusResult", '')

  if resultManager_Model.selectedExpression ~= '' then
    Script.notifyEvent("ResultManager_OnNewStatusExpressionSelected", true)
    Script.notifyEvent("ResultManager_OnNewStatusExpressionName", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].name)
    Script.notifyEvent("ResultManager_OnNewStatusMergeData", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].mergeData)

    Script.notifyEvent("ResultManager_OnNewStatusExpression", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].expression)
    Script.notifyEvent("ResultManager_OnNewStatusCriteriaType", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaType)

    if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaType == 'STRING' then
      Script.notifyEvent("ResultManager_OnNewStatusCriteriaString", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria)
    else
      Script.notifyEvent("ResultManager_OnNewStatusCriteria", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria)
    end

    if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaType == 'RANGE' then
      Script.notifyEvent("ResultManager_OnNewStatusCriteriaMaximum", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaMax)
    end
    Script.notifyEvent("ResultManager_OnNewStatusParameterList", resultManager_Model.helperFuncs.createJsonListExpressionParameters(resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events, resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].data, resultManager_Model.selectedParameter))

    if resultManager_Model.selectedParameter ~= '' then
      Script.notifyEvent("ResultManager_OnNewStatusLinkedEvent", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events[resultManager_Model.selectedParameter])
      Script.notifyEvent("ResultManager_OnNewStatusSelectedParameter", 'param' .. tostring(resultManager_Model.selectedParameter))
      Script.notifyEvent("ResultManager_OnNewStatusEventParameterPosition", resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].parameterPositions[resultManager_Model.selectedParameter])
    else
      Script.notifyEvent("ResultManager_OnNewStatusSelectedParameter", 'none Selected')
      Script.notifyEvent("ResultManager_OnNewStatusEventParameterPosition", 1)
    end
  else
    Script.notifyEvent("ResultManager_OnNewStatusExpressionSelected", false)
    Script.notifyEvent("ResultManager_OnNewStatusEventInfo", '')
    Script.notifyEvent("ResultManager_OnNewStatusExpressionName", resultManager_Model.newExpressionName)
    Script.notifyEvent("ResultManager_OnNewStatusExpression", '')
    Script.notifyEvent("ResultManager_OnNewStatusParameterList", resultManager_Model.helperFuncs.createJsonListExpressionParameters(nil))
  end

  local eventList = resultManager_Model.helperFuncs.getAvailableEvents()
  Script.notifyEvent("ResultManager_OnNewStatusAvailableEvents", resultManager_Model.helperFuncs.createStringListBySimpleTable(eventList))
  Script.notifyEvent("ResultManager_OnNewStatusFlowConfigPriority", resultManager_Model.parameters.flowConfigPriority)
  Script.notifyEvent("ResultManager_OnNewStatusLoadParameterOnReboot", resultManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("ResultManager_OnPersistentDataModuleAvailable", resultManager_Model.persistentModuleAvailable)
  Script.notifyEvent("ResultManager_OnNewParameterName", resultManager_Model.parametersName)

end
Timer.register(tmrResultManager, "OnExpired", handleOnExpiredTmrResultManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrResultManager:start()
  return ''
end
Script.serveFunction("CSK_ResultManager.pageCalled", pageCalled)

local function selectExpressionByName(selection)
  local suc
  if resultManager_Model.parameters.expressions[selection] then
    suc = true
    _G.logger:fine(nameOfModule .. ": Select expression '" .. tostring(selection) .. "'.")
    resultManager_Model.selectedExpression = selection
    resultManager_Model.selectedParameter = ''
  else
    suc = false
  end
  handleOnExpiredTmrResultManager()
  return suc
end
Script.serveFunction('CSK_ResultManager.selectExpressionByName', selectExpressionByName)

local function setExpressionName(name)
  resultManager_Model.newExpressionName = name
end
Script.serveFunction('CSK_ResultManager.setExpressionName', setExpressionName)

local function addExpressionViaUI()
  if resultManager_Model.newExpressionName ~= '' then
    resultManager_Model.addExpression(resultManager_Model.newExpressionName, false, '', 'NUMBER', 100, nil, nil)
    selectExpressionByName(resultManager_Model.newExpressionName)
  else
    _G.logger:warning(nameOfModule .. ": No expression name defined in UI.")
  end
end
Script.serveFunction('CSK_ResultManager.addExpressionViaUI', addExpressionViaUI)

local function deleteExpressionViaUI()
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Delete expression '" .. tostring(resultManager_Model.selectedExpression) .. "'.")
    resultManager_Model.deregisterFromParameterEvent(resultManager_Model.selectedExpression)
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] = nil
  else
    _G.logger:warning(nameOfModule .. ": Expression '" .. tostring(resultManager_Model.selectedExpression) .. "' not available to delete.")
  end

  resultManager_Model.selectedExpression = ''
  resultManager_Model.selectedParameter = ''

  -- Check if there is another expression available to select
  for key, _ in pairs(resultManager_Model.parameters.expressions) do
    resultManager_Model.selectedExpression = key
    break
  end
  handleOnExpiredTmrResultManager()
end
Script.serveFunction('CSK_ResultManager.deleteExpressionViaUI', deleteExpressionViaUI)

local function setMergeData(status)
  _G.logger:fine(nameOfModule .. ": Set status of mergeData to '" .. tostring(status) .. "'.")
  resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].mergeData = status
  Script.notifyEvent("ResultManager_OnNewStatusMergeData", status)
  handleOnExpiredTmrResultManager()
end
Script.serveFunction('CSK_ResultManager.setMergeData', setMergeData)

local function setExpression(expression)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Set expression to '" .. tostring(expression) .. "'.")
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].expression = expression
  end
end
Script.serveFunction('CSK_ResultManager.setExpression', setExpression)

local function setCriteriaType(criteriaType)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Set criteria type to '" .. tostring(criteriaType) .. "'.")
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaType = criteriaType

    if criteriaType == 'NUMBER' then
      resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria = 123.0
    elseif criteriaType == 'RANGE' then
      resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria = 1.0
      resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaMax = 100.0
    elseif criteriaType == 'BOOL' then
      resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria = true
    elseif criteriaType == 'STRING' then
      resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria = 'TextToCheck'
    end
    handleOnExpiredTmrResultManager()
  end
end
Script.serveFunction('CSK_ResultManager.setCriteriaType', setCriteriaType)

local function setCriteria(criteria)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Set criteria to '" .. tostring(criteria) .. "'.")
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteria = criteria
  end
end
Script.serveFunction('CSK_ResultManager.setCriteria', setCriteria)

local function setCriteriaMaximum(maxCriteria)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Set criteria maximum to '" .. tostring(maxCriteria) .. "'.")
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].criteriaMax = maxCriteria
  end
end
Script.serveFunction('CSK_ResultManager.setCriteriaMaximum', setCriteriaMaximum)

--- Function to check if selection in UIs DynamicTable can find related pattern
---@param selection string Full text of selection
---@param pattern string Pattern to search for
---@param findEnd bool Find end after pattern
---@return string? Success if pattern was found or even postfix after pattern till next quotation marks if findEnd was set to TRUE
local function checkSelection(selection, pattern, findEnd)
  if selection ~= "" then
    local _, pos = string.find(selection, pattern)
    if pos == nil then
      return nil
    else
      if findEnd then
        pos = tonumber(pos)
        local endPos = string.find(selection, '"', pos+1)
        if endPos then
          local tempSelection = string.sub(selection, pos+1, endPos-1)
          if tempSelection ~= nil and tempSelection ~= '-' then
            return tempSelection
          end
        else
          return nil
        end
      else
        return 'true'
      end
    end
  end
  return nil
end

local function selectParameterViaUI(selection)
  local tempSelection = checkSelection(selection, '"DTC_ParameterName":"param', true)
  if tempSelection then
    local isSelected = checkSelection(selection, '"selected":true', false)
    if isSelected then
      _G.logger:fine(nameOfModule .. ": Selected 'param" .. tostring(tempSelection) .. "'.")
      resultManager_Model.selectedParameter = tonumber(tempSelection)
    else
      resultManager_Model.selectedParameter = ''
    end
    handleOnExpiredTmrResultManager()
  end
end
Script.serveFunction('CSK_ResultManager.selectParameterViaUI', selectParameterViaUI)

local function selectParameter(parameter)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression]['paramAmount'] then
    if parameter <= resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression]['paramAmount'] then
      _G.logger:fine(nameOfModule .. ": Selected 'param" .. parameter .. "'.")
      resultManager_Model.selectedParameter = parameter
      handleOnExpiredTmrResultManager()
      return true
    else
      _G.logger:info(nameOfModule .. ": Parameter 'param" .. parameter .. "' is not available.")
      return false
    end
  else
    return false
  end
end
Script.serveFunction('CSK_ResultManager.selectParameter', selectParameter)

local function setParameterEvent(event)
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    _G.logger:fine(nameOfModule .. ": Register to event '" .. event .. "' for 'param" .. tostring(resultManager_Model.selectedParameter) .. "' of expression '" .. resultManager_Model.selectedExpression .. "'.")
    resultManager_Model.deregisterFromParameterEvent(resultManager_Model.selectedExpression)
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events[resultManager_Model.selectedParameter] = event
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].parameterPositions[resultManager_Model.selectedParameter] = 1
    resultManager_Model.registerToParameterEvents(resultManager_Model.selectedExpression)
    resultManager_Model.clearParameterData(resultManager_Model.selectedExpression)
    handleOnExpiredTmrResultManager()
  end
end
Script.serveFunction('CSK_ResultManager.setParameterEvent', setParameterEvent)

local function setParameterPosition(pos)
  if pos >= 1 and pos <= 8 then
    _G.logger:fine(nameOfModule .. ": Set parameterPosition of 'param" .. tostring(resultManager_Model.selectedParameter) .. "' to '" .. pos .. "'.")
    resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].parameterPositions[resultManager_Model.selectedParameter] = pos
  else
    _G.logger:warning(nameOfModule .. ": Parameter position needs to be between 1 and 8.")
  end
end
Script.serveFunction('CSK_ResultManager.setParameterPosition', setParameterPosition)

local function selectEventViaUI(event)
  setParameterEvent(event)
end
Script.serveFunction('CSK_ResultManager.selectEventViaUI', selectEventViaUI)

local function addParameterViaUI()
  if resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression] then
    table.insert(resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events, '')
    resultManager_Model.addParameter(resultManager_Model.selectedExpression, #resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events, 1)
    selectParameter(#resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events)
    handleOnExpiredTmrResultManager()
  end
end
Script.serveFunction('CSK_ResultManager.addParameterViaUI', addParameterViaUI)

local function clearParameterDataViaUI()
  resultManager_Model.clearParameterData(resultManager_Model.selectedExpression)
  Script.notifyEvent("ResultManager_OnNewStatusParameterList", resultManager_Model.helperFuncs.createJsonListExpressionParameters(resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].events, resultManager_Model.parameters.expressions[resultManager_Model.selectedExpression].data))
end
Script.serveFunction('CSK_ResultManager.clearParameterDataViaUI', clearParameterDataViaUI)

--- Function to delete parameter / registration to parameter event
---@param exp string Expression parameter is related to
---@param param int Number of parameter to delete
local function deleteParameter(exp, param)
  if resultManager_Model.parameters.expressions[exp].events[param] then
    _G.logger:fine(nameOfModule .. ": Delete 'param".. param .. "' of expression '" .. exp .. "'.")
    resultManager_Model.deregisterFromParameterEvent(exp)
    table.remove(resultManager_Model.parameters.expressions[exp].events, param)
    table.remove(resultManager_Model.parameters.expressions[exp].parameterPositions, param)
    resultManager_Model.parameters.expressions[exp]['paramAmount'] = resultManager_Model.parameters.expressions[exp]['paramAmount'] - 1
    resultManager_Model.registerToParameterEvents(exp)
    resultManager_Model.clearParameterData(exp)
    resultManager_Model.selectedParameter = ''
  end
end

--- Function to clear all parameter / registration to parameter events of expression
---@param exp string Expression to clear all parameters
local function deleteAllParameter(exp)
  for i = 1, #resultManager_Model.parameters.expressions[exp].events do
    deleteParameter(exp, #resultManager_Model.parameters.expressions[exp].events)
  end
end

local function deleteParameterViaUI()
  deleteParameter(resultManager_Model.selectedExpression, resultManager_Model.selectedParameter)
  handleOnExpiredTmrResultManager()
end
Script.serveFunction('CSK_ResultManager.deleteParameterViaUI', deleteParameterViaUI)

local function executeExpressionViaUI()
  local temp = {}
  resultManager_Model.process(resultManager_Model.selectedExpression, temp)
end

Script.serveFunction('CSK_ResultManager.executeExpressionViaUI', executeExpressionViaUI)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_ResultManager.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for key, value in pairs(resultManager_Model.parameters.expressions) do
    deleteAllParameter(key)
  end
  handleOnExpiredTmrResultManager()
end
Script.serveFunction('CSK_ResultManager.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters()
  return resultManager_Model.helperFuncs.json.encode(resultManager_Model.parameters)
end
Script.serveFunction('CSK_ResultManager.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  resultManager_Model.parametersName = name
end
Script.serveFunction("CSK_ResultManager.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if resultManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(resultManager_Model.helperFuncs.convertTable2Container(resultManager_Model.parameters), resultManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, resultManager_Model.parametersName, resultManager_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send ResultManager parameters with name '" .. resultManager_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ResultManager.sendParameters", sendParameters)

--- Function to register on events provided e.g. by other modules (optionally react on timer started after loading of persistent parameters)
local function registerToEvents()
  for expressionName, _ in pairs(resultManager_Model.parameters.expressions) do
    resultManager_Model.registerToParameterEvents(expressionName)
  end
end

local function loadParameters()
  if resultManager_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(resultManager_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")

      -- Clear old registrations for parameter events
      for expressionName, _ in pairs(resultManager_Model.parameters.expressions) do
        resultManager_Model.deregisterFromParameterEvent(expressionName)
      end

      resultManager_Model.parameters = resultManager_Model.helperFuncs.convertContainer2Table(data)

      local lastSelected = ''

      -- If something needs to be configured/activated with new loaded data, place this here
      for expressionName, _ in pairs(resultManager_Model.parameters.expressions) do
        for key, value in ipairs(resultManager_Model.parameters.expressions[expressionName]['events']) do
          resultManager_Model.addParameter(expressionName, key)
        end
        if not Script.isServedAsEvent("CSK_ResultManager.OnNewResult_" .. expressionName) then
          Script.serveEvent("CSK_ResultManager.OnNewResult_" .. expressionName, "ResultManager_OnNewResult_" .. expressionName, 'auto:1')
        end
        if not Script.isServedAsEvent("CSK_ResultManager.OnNewCriteriaResult_" .. expressionName) then
          Script.serveEvent("CSK_ResultManager.OnNewCriteriaResult_" .. expressionName, "ResultManager_OnNewCriteriaResult_" .. expressionName, 'bool:1')
        end
        if not Script.isServedAsEvent("CSK_ResultManager.OnNewData_" .. expressionName) then
          Script.serveEvent("CSK_ResultManager.OnNewData_" .. expressionName, "ResultManager_OnNewData_" .. expressionName, 'auto:?,auto:?,auto:?,auto:?,')
        end
        lastSelected = expressionName
      end

      registerToEvents()

      resultManager_Model.selectedExpression = lastSelected
      resultManager_Model.selectedParameter = ''
      CSK_ResultManager.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_ResultManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  resultManager_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("ResultManager_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_ResultManager.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  resultManager_Model.parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("ResultManager_OnNewStatusFlowConfigPriority", resultManager_Model.parameters.flowConfigPriority)
end
Script.serveFunction('CSK_ResultManager.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      resultManager_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        resultManager_Model.parametersName = parameterName
        resultManager_Model.parameterLoadOnReboot = loadOnReboot
      end

      if resultManager_Model.parameterLoadOnReboot then
        loadParameters()
      end
      Script.notifyEvent('ResultManager_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_ResultManager.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setResultManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

