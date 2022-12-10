/**
 * 
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class SecurityHandler {
    private static SecurityHandler m_instance;
    public static SecurityHandler App {
        get {
            if(m_instance != null) {return m_instance; }
            m_instance = new SecurityHandler();
            return m_instance;
        }
    }


    public LogHandling Logger = LogHandling.Instance;

    public Boolean HasAccessToFeature(String key) {
        Boolean val = FeatureManagement.checkPermission(key);
        if(!val) {
            CustomPermission permission = [SELECT Id, MasterLabel, DeveloperName FROM CustomPermission WHERE
                    DeveloperName =: key];
            App.Logger.Error('User Does Not have Access to this Feature => ' + permission.MasterLabel );
            val = false;
        }
        return val;
    }


}