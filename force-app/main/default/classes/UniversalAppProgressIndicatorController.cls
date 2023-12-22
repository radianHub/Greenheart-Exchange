// RadianHub - Developer EBS
// Apex class for the LWC Universal Application Progress Indicator, dependent on Custom Metadata and Object Field Sets

public with sharing class UniversalAppProgressIndicatorController {
	public final static String INDICATOR_NOT_FOUND = 'No Settings found for Indicator {0}.';
	public final static String STEPS_NOT_FOUND = 'No Steps found for Indicator {0}.';

	public static Universal_App_Progress_Indicator__mdt indicator;
	public static List<Universal_App_Progress_Step__mdt> steps;

	@AuraEnabled(cacheable=true)
	public static Map<String, Object> getIndicatorSettings(String mdtName) {
		Map<String, Object> returnData = new Map<String, Object>();
		try {
			List<Universal_App_Progress_Indicator__mdt> indicatorList;
			if (indicator == null) {
				indicatorList = queryIndicator(mdtName);
			}

			if (indicator == null && (indicatorList == null || indicatorList.size() != 1)) {
				//query returned no results
				returnData.put('error', String.format(INDICATOR_NOT_FOUND, new List<Object>{ mdtName }));
			} else {
				if (indicator == null) {
					indicator = indicatorList[0];
				}
				returnData.put('settings', indicator);

				if (steps == null) {
					queryIndicatorSteps(indicator.Id);
				}

				if (steps == null || steps.size() < 1) {
					// indicator has no steps configured
					returnData.put('error', String.format(STEPS_NOT_FOUND, new List<Object>{ mdtName }));
				} else {
					returnData.put('steps', steps);
				}
			}
		} catch (Exception e) {
			returnData.put('error', e.getTypeName() + ' | ' + e.getMessage() + ' | ' + e.getStackTraceString());
		}
		return returnData;
	}

	private static List<Universal_App_Progress_Indicator__mdt> queryIndicator(String mdtName) {
		//indicator = [
		return [
			SELECT Id, MasterLabel
			FROM Universal_App_Progress_Indicator__mdt
			WHERE DeveloperName = :mdtName
			LIMIT 1
		];
	}

	private static void queryIndicatorSteps(String parentId) {
		steps = [
			SELECT Id, MasterLabel, Stages__c, StepNum__c
			FROM Universal_App_Progress_Step__mdt
			WHERE ProgressIndicator__c = :parentId
			ORDER BY StepNum__c ASC
		];
	}
}