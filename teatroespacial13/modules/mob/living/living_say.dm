/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
    message = strings_regex_replace(message, TEATRO_STRING_DIRECTORY, IC_REGEX_FILTER, "in_character", "gi")
    . = ..()
