-- Block namespace
local BLOCK_NAMESPACE = "ResultManager_FC.OnNewResult"
local nameOfModule = 'CSK_ResultManager'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local expression = Container.get(handle, 'ExpressionName')
  local suc = CSK_ResultManager.selectExpressionByName(expression)

  if not suc then
    CSK_ResultManager.setExpressionName(expression)
    CSK_ResultManager.addExpressionViaUI()
  end

  local function localCallback()
    local mode = Container.get(handle, 'Mode')
    local cbFunction = Container.get(handle,"CB_Function")

    if cbFunction ~= nil then

      -- Check what mode should be used
      if mode == 'CRITERIA' then
        Script.callFunction(cbFunction, 'CSK_ResultManager.OnNewCriteriaResult_' .. expression)
      elseif mode == 'EXPRESSION' then
        Script.callFunction(cbFunction, 'CSK_ResultManager.OnNewResult_' .. expression)
      elseif mode == 'DATA' then
        Script.callFunction(cbFunction, 'CSK_ResultManager.OnNewData_' .. expression)
      end

    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************

local function create(expressionName, mode)

  local fullInstanceName = tostring(expressionName) .. tostring(mode)

  -- Check if same instance is already configured
  if nil ~= instanceTable[fullInstanceName] then
    _G.logger:warning(nameOfModule .. ": Expression already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'ExpressionName', expressionName)
    Container.add(handle, 'Mode', mode)
    Container.add(handle, "CB_Function", "")
    return(handle)
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)