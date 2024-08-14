--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Data.ResultManager.FlowConfig.ResultManager_DataSource')
require('Data.ResultManager.FlowConfig.ResultManager_OnNewResult')
require('Data.ResultManager.FlowConfig.ResultManager_Process')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if resultManager_Model.parameters.flowConfigPriority then
      CSK_ResultManager.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)