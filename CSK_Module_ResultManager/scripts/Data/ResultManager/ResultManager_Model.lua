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

-- Optionally check if specific API was loaded via
--[[
if _G.availableAPIs.specific then
-- ... doSomething ...
end
]]

--[[
-- Create parameters / instances for this module
resultManager_Model.object = Image.create() -- Use any AppEngine CROWN
resultManager_Model.counter = 1 -- Short docu of variable
resultManager_Model.varA = 'value' -- Short docu of variable
--...
]]

-- Parameters to be saved permanently if wanted
resultManager_Model.parameters = {}
--resultManager_Model.parameters.paramA = 'paramA' -- Short docu of variable
--resultManager_Model.parameters.paramB = 123 -- Short docu of variable
--...

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--[[
-- Some internal code docu for local used function to do something
---@param content auto Some info text if function is not already served
local function doSomething(content)
  _G.logger:info(nameOfModule .. ": Do something")
  resultManager_Model.counter = resultManager_Model.counter + 1
end
resultManager_Model.doSomething = doSomething
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return resultManager_Model
