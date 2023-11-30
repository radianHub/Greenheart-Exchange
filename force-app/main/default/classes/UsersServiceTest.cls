// TODO (FUTURE): This test class should probably test for cases where the ContactId, AccountId and J1_Opportunity__c are returned 
// TODO (CONTINUED): Elected to avoid this to reduce project scope and time
@isTest
private without sharing class UsersServiceTest {
    @isTest
    private static void getCurrentUserAccountContactOpportunity() {
        Test.startTest();
        User currentUser = UsersService.getCurrentUserAccountContactOpportunity();
        Test.stopTest();
        Assert.areEqual(UserInfo.getUserId(), currentUser.Id, 'User returned does not match expected user');
    }

}