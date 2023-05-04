public with sharing class Utils {

	public static SObject[] filter(SObject[] coll, String field, Object value, Boolean includeOrExclude) {
		SObject[] res = new SObject[]{};
		if(coll == null) return res;
		for(SObject x : coll) {
			Object val = getSObjectValue(x, field);
			if((value == val && includeOrExclude) || (!includeOrExclude && value != val)) res.add(x);
		}
		return res;
	}

	public static SObject[] filter(SObject[] coll, String field, Set<String> value, Boolean includeOrExclude) {
		SObject[] res = new SObject[]{};
		if(coll == null) return res;
		for(SObject x : coll) {
			Object val = getSObjectValue(x, field);
			if((includeOrExclude && value.contains((String) val)) || (!includeOrExclude && !value.contains((String) val))) res.add(x);
		}
		return res;
	}

	public static Set<String> getSet(SObject[] objList, String field) {
		Set<String> res = new Set<String>();
		if (String.isBlank(field) || objList == null || objList.isEmpty()) return res;
		else {
			Boolean isPlainField = !field.contains('.');
			for (SObject obj : objList) {
				Object val = getSObjectValueWithoutChecks(obj, field, isPlainField);
				if (val != null) res.add((String) val);
			}
			return res;
		}
	}

	public static Object getSObjectValue(SObject obj, String field) {
		if(String.isBlank(field) || obj == null) return null;
		else return getSObjectValueWithoutChecks(obj, field, !field.contains('.'));
	}

	private static Object getSObjectValueWithoutChecks(SObject obj, String field, Boolean isPlainField) {
		try {
			if(isPlainField) return obj.get(field);
			Map<String, String[]> tokensMap = new Map<String, String[]>();
			SObject subObj = obj;
			if(!tokensMap.containsKey(field)) tokensMap.put(field, field.split('\\.'));
			String[] tokens = tokensMap.get(field);
			for(Integer i = 0; i < tokens.size() - 1; i++) {
					subObj = subObj.getSObject(tokens[i]);
			}
			return subObj.get(tokens[tokens.size() - 1]);
		}
		catch(Exception e) {
			return null;
		}
	}
}