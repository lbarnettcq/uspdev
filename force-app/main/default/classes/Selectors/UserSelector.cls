/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class UserSelector extends SObjectSelector {

    public UserSelector(){
        super(User.SObjectType);
    }
    private static UserSelector m_instance;
    public static UserSelector Instance {
        get {
            if(m_instance != null) {return m_instance;}
            m_instance = new UserSelector();
            return m_instance;
        }
    }



    public override Set<SObjectField> GetDefaultFields() {
        return new Set<SObjectField> {
                User.Id,
                User.FirstName,
                User.LastName,
                User.Alias,
                User.Username,
                User.Email,
                User.FederationIdentifier,
                User.IsActive,
                User.Division,
                User.MiddleName,
                User.Name,
                User.ProfileId,
                User.Unique_User_id__c,
                User.User_Classification__c
        };
    }

    public List<User> GetAll(){
        return queryAll();
    }
    /**
     * @param keyset
     *
     * @return List of All Users
     */

    public List<User> GetALlById(Set<Id> keyset) {
        return queryById(keyset);
    }
    /**
     * @param key
     *
     * @return Single User record
     */

    public List<User> GetOneByUsername(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(User.Username, key)).Execute();
    }
    /**
     * @param List<String> ListOfUsersnames
     *
     * @return List of Users from a list of Usernames
     */

    public List<User> GetByUsernames(List<String> keys) {
        return GetQueryFactory().WithCriteria(Criteria.ValueIn(User.Username, keys)).Execute();
    }

    public List<User> GetOneByEmail(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(User.Email, key)).Execute();
    }

    public List<User> GetUsersByEmail(List<String> key) {
        return GetQueryFactory().WithCriteria(Criteria.ValueIn(User.Email, key)).Execute();
    }

    public List<User> GetByUserClassification(String key) {
        return GetQueryFactory().WithCriteria(Criteria.Equals(User.User_Classification__c, key)).Execute();
    }
}