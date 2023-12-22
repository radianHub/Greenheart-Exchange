@isTest
public class UnivAppProgressIndicatorControllerTest {
	final static String defaultMDTName = 'FindThisIndicator';
	final static String mdtLabel = 'Find This Indicator';
	@isTest
	private static void errorHandling_NoIndicator() {
		String notFoundMDTName = 'Testing_Not_Found';
		// Error scenario -- no Indicator found
		Map<String, Object> ret = UniversalAppProgressIndicatorController.getIndicatorSettings(notFoundMDTName);

		System.assertEquals(
			String.format(
				UniversalAppProgressIndicatorController.INDICATOR_NOT_FOUND,
				new List<Object>{ notFoundMDTName }
			),
			ret.get('error'),
			'Did not handle the correct error scenario: ' + UniversalAppProgressIndicatorController.INDICATOR_NOT_FOUND
		);
	}

	@isTest
	private static void errorHandling_NoSteps() {
		// Error scenario -- no Steps found
		UniversalAppProgressIndicatorController.indicator = createIndicator(defaultMDTName, mdtLabel);

		Map<String, Object> ret = UniversalAppProgressIndicatorController.getIndicatorSettings(defaultMDTName);

		System.assertEquals(
			String.format(UniversalAppProgressIndicatorController.STEPS_NOT_FOUND, new List<Object>{ defaultMDTName }),
			ret.get('error'),
			'Did not handle the correct error scenario: ' + UniversalAppProgressIndicatorController.STEPS_NOT_FOUND
		);
	}

	@isTest
	private static void getData() {
		// Success scenario -- returned data
		Universal_App_Progress_Indicator__mdt indicator = createIndicator(defaultMDTName, mdtLabel);
		System.debug('indicator');
		System.debug(indicator);
		UniversalAppProgressIndicatorController.indicator = indicator;
		UniversalAppProgressIndicatorController.steps = createSteps(1, indicator.Id);

		Map<String, Object> ret = UniversalAppProgressIndicatorController.getIndicatorSettings(defaultMDTName);

		System.debug(ret);
		System.assertEquals(true, ret.containsKey('settings'), 'Did not successfully return Indicator data.');
		System.assertEquals(true, ret.containsKey('steps'), 'Did not successfully return Steps data.');
	}

	/*@isTest
	private static void getDataQuery() {
		// Success scenario -- returned data
		Universal_App_Progress_Indicator__mdt indicator = createIndicator(defaultMDTName, mdtLabel);
		UniversalAppProgressIndicatorController.indicator = indicator;

		List<Universal_App_Progress_Step__mdt> steps = createSteps(3, indicator.Id);

		Map<String, Object> ret = UniversalAppProgressIndicatorController.getIndicatorSettings(defaultMDTName);

		System.debug(ret);

		System.assertEquals(
			true,
			ret.containsKey('settings'),
			'Did not successfully return Indicator data from query.'
		);
		System.assertEquals(true, ret.containsKey('steps'), 'Did not successfully return Steps data from query.');
	}*/

	private static Universal_App_Progress_Indicator__mdt createIndicator(String name, String label) {
		return new Universal_App_Progress_Indicator__mdt(DeveloperName = name, MasterLabel = label);
	}

	private static List<Universal_App_Progress_Step__mdt> createSteps(Integer count, Id indicatorId) {
		List<Universal_App_Progress_Step__mdt> steps = new List<Universal_App_Progress_Step__mdt>();

		for (Integer i = 0; i < count; i++) {
			Integer uniqueNum = i + 1;
			Universal_App_Progress_Step__mdt step = new Universal_App_Progress_Step__mdt(
				DeveloperName = 'Step' + uniqueNum,
				StepNum__c = uniqueNum,
				Stages__c = 'testStage',
				ProgressIndicator__c = indicatorId
			);
			steps.add(step);
		}
		System.debug('steps');
		System.debug(steps);
		return steps;
	}
}