public with sharing class HeirarchyProvider {
    public static List<SelectOption> PopulateSelectOptionsFromCurrentUser() {
        List<SelectOption> options = new List<SelectOption>();

        // collect roles
        UserRole myRole;
        Map<Id, UserRole> allRoles = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
        if (allRoles == null || allRoles.isEmpty()) {
            return options;
        }

        // prepare vars
        Map<Id, String> mappedRoles = new Map<Id, String>();
        Map<Id, List<Id>> parentChildMap = new Map<Id, List<Id>>();
        Set<Id> rolesToQuery = new Set<Id>();

        // find current user's role info
        for (UserRole role : allRoles.values()) {
            if (myRole != null) { break; }
            if (role.Id != UserInfo.getUserRoleId()) { continue; }
            myRole = role;
            parentChildMap.put(myRole.Id, new List<Id>());
            rolesToQuery.add(myRole.Id);
        }

        // map subordinate roles to myRole in a chain
        mapSubordinates(allRoles, mappedRoles, parentChildMap, myRole, 1);

        rolesToQuery.addAll(mappedRoles.keySet());

        // pull all users with mapped roles
        List<User> subordinateUsers = [ SELECT Id, FirstName, LastName, UserRoleId
        FROM User
        WHERE UserRoleId IN :rolesToQuery ];

        options.add(new SelectOption(UserInfo.getUserId()
                , UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));

        // crosswalk users to mapped roles, build options list
        for (Id r : mappedRoles.keySet()) {
            String roleName = mappedRoles.get(r);
            for (User u : subordinateUsers) {
                if (u.UserRoleId == r) {
                    options.add(new SelectOption(u.Id
                            , roleName + ' : ' + u.FirstName + ' ' + u.LastName));
                }
            }
        }

        return options;
    }

    private static void mapSubordinates(Map<Id, UserRole> allRoles, Map<Id, String> mappedRoles
            , Map<Id, List<Id>> parentChildMap, UserRole parent, Integer depth) {
        if (parent == null) { return; }
        if (parentChildMap == null) { parentChildMap = new Map<Id, List<Id>>(); }
        parentChildMap.put(parent.Id, new List<Id>());
        if (allRoles == null) { return; }
        if (mappedRoles == null) { return; }
        Integer numTabs = depth == null ? 1 : depth;
        Map<Id, UserRole> children = findSubordinateRoles(allRoles, parent.Id);
        Map<String, Id> nameIdMap = new Map<String, Id>();
        List<String> names = new List<String>();
        // prep child lists
        for (Id key : children.keySet()) {
            nameIdMap.put(children.get(key).Name, key);
            names.add(children.get(key).Name);
        }
        // sort name list
        names.sort();
        for (String n : names) {
            mappedRoles.put(nameIdMap.get(n), tabOver(n, numTabs));
            parentChildMap.get(parent.Id).add(nameIdMap.get(n));
            mapSubordinates(allRoles, mappedRoles, parentChildMap, allRoles.get(nameIdMap.get(n)), numTabs+1);
        }
    }

    private static String tabOver(String n, Integer i) {
        return ' ' + ('. ').repeat(i) + n;
    }

    private static Map<Id, UserRole> findSubordinateRoles(Map<Id, UserRole> allRoles, Id parentId) {
        Map<Id, UserRole> results = new Map<Id, UserRole>();
        if (allRoles == null) { return results; }
        if (parentId == null) { return results; }
        for (UserRole role : allRoles.values()) {
            if (role.Id == parentId) { continue; }
            if (role.ParentRoleId != parentId) { continue; }
            results.put(role.Id, role);
        }
        system.debug('<><><> Subordinates Found ['+ parentId +'] :: '+results);
        return results;
    }
}