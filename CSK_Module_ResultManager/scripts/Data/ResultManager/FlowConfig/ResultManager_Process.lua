-- Block namespace
local BLOCK_NAMESPACE = 'ResultManager_FC.Process'
local nameOfModule = 'CSK_ResultManager'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function checkParameter(paramNumber, paramEvent, parameterPosition)
  while true do
    local suc = CSK_ResultManager.selectParameter(paramNumber)
    if not suc then
      CSK_ResultManager.addParameterViaUI()
    else
      break
    end
  end
  CSK_ResultManager.setParameterEvent(paramEvent)
  CSK_ResultManager.setParameterPosition(parameterPosition)
end

local function process(handle, source1, source2, source3, source4)

  local parameterEvent = { p1=source1 or 'none', p2=source2 or 'none', p3=source3 or 'none', p4=source4 or 'none'}

  local expName = Container.get(handle, 'ExpressionName')
  local suc = CSK_ResultManager.selectExpressionByName(expName)

  if not suc then
    CSK_ResultManager.setExpressionName(expName)
    CSK_ResultManager.addExpressionViaUI()
  end

  for key, value in pairs(parameterEvent) do
    if value ~= 'none' then
      local pos = string.sub(key, #key, #key)
      local parameterPosition = Container.get(handle, 'ParameterPosition' .. pos)
      checkParameter(tonumber(pos), value, parameterPosition)
    end
  end

  local mode = Container.get(handle, 'Mode')
  if mode == 'CRITERIA' then
    CSK_ResultManager.setMergeData(false)
    return 'CSK_ResultManager.OnNewCriteriaResult_' .. expName
  elseif mode == 'EXPRESSION' then
    CSK_ResultManager.setMergeData(false)
    return 'CSK_ResultManager.OnNewResult_' .. expName
  elseif mode == 'DATA' then
    CSK_ResultManager.setMergeData(true)
    return 'CSK_ResultManager.OnNewData_' .. expName
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.process', process)

--*************************************************************
--*************************************************************

local function create(expressionName, mode, param1EventPos, param2EventPos, param3EventPos, param4EventPos)

  local fullInstanceName = tostring(expressionName) .. tostring(mode)

  -- Check if same instance is already configured
  if nil ~= instanceTable[fullInstanceName] then
    _G.logger:warning(nameOfModule .. ": Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'ExpressionName', expressionName)
    Container.add(handle, 'Mode', mode)

    local parameterPosition = { paramPos1=param1EventPos or 1, paramPos2=param2EventPos or 1, paramPos3=param3EventPos or 1, paramPos4=param4EventPos or 1 }

    for key, value in pairs(parameterPosition) do
      local pos = string.sub(key, #key, #key)
      Container.add(handle, 'ParameterPosition' .. pos, value)
    end

    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
