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

-- Script.serveEvent("CSK_ResultManager.OnNewEvent", "ResultManager_OnNewEvent")
Script.serveEvent("CSK_ResultManager.OnNewStatusLoadParameterOnReboot", "ResultManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_ResultManager.OnPersistentDataModuleAvailable", "ResultManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_ResultManager.OnNewParameterName", "ResultManager_OnNewParameterName")
Script.serveEvent("CSK_ResultManager.OnDataLoadedOnReboot", "ResultManager_OnDataLoadedOnReboot")

Script.serveEvent('CSK_ResultManager.OnUserLevelOperatorActive', 'ResultManager_OnUserLevelOperatorActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelMaintenanceActive', 'ResultManager_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelServiceActive', 'ResultManager_OnUserLevelServiceActive')
Script.serveEvent('CSK_ResultManager.OnUserLevelAdminActive', 'ResultManager_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

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

  -- Script.notifyEvent("ResultManager_OnNewEvent", false)

  Script.notifyEvent("ResultManager_OnNewStatusLoadParameterOnReboot", resultManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("ResultManager_OnPersistentDataModuleAvailable", resultManager_Model.persistentModuleAvailable)
  Script.notifyEvent("ResultManager_OnNewParameterName", resultManager_Model.parametersName)
  -- ...
end
Timer.register(tmrResultManager, "OnExpired", handleOnExpiredTmrResultManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrResultManager:start()
  return ''
end
Script.serveFunction("CSK_ResultManager.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  resultManager_Model.varA = value
end
Script.serveFunction("CSK_ResultManager.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  resultManager_Model.parametersName = name
end
Script.serveFunction("CSK_ResultManager.setParameterName", setParameterName)

local function sendParameters()
  if resultManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(resultManager_Model.helperFuncs.convertTable2Container(resultManager_Model.parameters), resultManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, resultManager_Model.parametersName, resultManager_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send ResultManager parameters with name '" .. resultManager_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ResultManager.sendParameters", sendParameters)

local function loadParameters()
  if resultManager_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(resultManager_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      resultManager_Model.parameters = resultManager_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_ResultManager.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_ResultManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  resultManager_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_ResultManager.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

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
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setResultManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

