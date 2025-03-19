GLOBAL_LIST_EMPTY(regex_strings)

/proc/strings_regex_replace(needle, directory, filepath, key, flags)
	filepath = sanitize_filepath(filepath)
	load_strings_file(filepath, directory)

	if((filepath in GLOB.string_cache) && (key in GLOB.string_cache[filepath]))
		if(!LAZYACCESSASSOC(GLOB.regex_strings, filepath, key))
			var/list/all_operations = LAZYACCESSASSOC(GLOB.string_cache, filepath, key)
			for(var/leetspeak in all_operations)
				var/regex/r = regex(leetspeak, flags)
				LAZYADDASSOC(GLOB.regex_strings, key, r)
				GLOB.regex_strings[key][r] = all_operations[leetspeak]
		for(var/regex/r as anything in LAZYACCESS(GLOB.regex_strings, key))
			needle = replacetext(needle, r, GLOB.regex_strings[key][r])
		return needle
	else
		CRASH("strings list not found: [directory]/[filepath], index=[key]")
