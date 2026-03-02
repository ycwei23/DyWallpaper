// Tests that every Loc property returns a non-empty string for all languages.
// This catches missing switch cases when adding new languages or strings.

func runLocalizationTests() {
    print("\n--- Localization Tests ---")

    // All supported languages
    let allLanguages = Language.allCases

    test("All languages are defined") {
        try assertEqual(allLanguages.count, 5)
    }

    test("Each language has a non-empty displayName") {
        for lang in allLanguages {
            try assertFalse(lang.displayName.isEmpty, "displayName empty for \(lang)")
        }
    }

    // Test every Loc property for all languages
    let locProperties: [(String, (Loc) -> String)] = [
        ("sectionVideo",            { $0.sectionVideo }),
        ("sectionDisplay",          { $0.sectionDisplay }),
        ("sectionPerformance",      { $0.sectionPerformance }),
        ("sectionAudio",            { $0.sectionAudio }),
        ("sectionGeneral",          { $0.sectionGeneral }),
        ("sectionLanguage",         { $0.sectionLanguage }),
        ("currentVideo",            { $0.currentVideo }),
        ("noVideoSelected",         { $0.noVideoSelected }),
        ("selectVideo",             { $0.selectVideo }),
        ("stopPlayback",            { $0.stopPlayback }),
        ("resumePlayback",          { $0.resumePlayback }),
        ("playbackSpeed",           { $0.playbackSpeed }),
        ("playbackSpeedNormal",     { $0.playbackSpeedNormal }),
        ("fillMode",                { $0.fillMode }),
        ("fillAspectFill",          { $0.fillAspectFill }),
        ("fillAspectFit",           { $0.fillAspectFit }),
        ("fillStretch",             { $0.fillStretch }),
        ("displayFooter",           { $0.displayFooter }),
        ("maxFrameRate",            { $0.maxFrameRate }),
        ("fps24",                   { $0.fps24 }),
        ("fps30",                   { $0.fps30 }),
        ("fps60",                   { $0.fps60 }),
        ("fpsUnlimited",            { $0.fpsUnlimited }),
        ("optimizeResolutionLabel", { $0.optimizeResolutionLabel }),
        ("optimizeResolutionDesc",  { $0.optimizeResolutionDesc }),
        ("performanceFooter",       { $0.performanceFooter }),
        ("launchAtLogin",           { $0.launchAtLogin }),
        ("launchAtLoginNote",       { $0.launchAtLoginNote }),
        ("menuSelectVideo",         { $0.menuSelectVideo }),
        ("menuResumePrefix",        { $0.menuResumePrefix }),
        ("menuMute",                { $0.menuMute }),
        ("menuUnmute",              { $0.menuUnmute }),
        ("menuStopPlayback",        { $0.menuStopPlayback }),
        ("menuPreferences",         { $0.menuPreferences }),
        ("menuQuit",                { $0.menuQuit }),
        ("alertLoginItemTitle",     { $0.alertLoginItemTitle }),
        ("alertLoginItemMessage",   { $0.alertLoginItemMessage }),
        ("alertLoginItemErrorPrefix", { $0.alertLoginItemErrorPrefix }),
        ("panelTitle",              { $0.panelTitle }),
        ("panelPrompt",             { $0.panelPrompt }),
    ]

    for (propName, getter) in locProperties {
        test("Loc.\(propName) is non-empty for all languages") {
            for lang in allLanguages {
                let loc = Loc(lang)
                let value = getter(loc)
                try assertFalse(value.isEmpty, "\(propName) is empty for \(lang)")
            }
        }
    }

    // Test that selectVideo and menuSelectVideo return the same value (they're the same concept)
    test("selectVideo and menuSelectVideo are consistent across languages") {
        for lang in allLanguages {
            let loc = Loc(lang)
            try assertEqual(loc.selectVideo, loc.menuSelectVideo)
        }
    }

    // Test that performanceFooter mentions "immediately" (in English at least)
    test("performanceFooter (English) reflects immediate effect") {
        let loc = Loc(.english)
        try assertTrue(loc.performanceFooter.lowercased().contains("immediately"),
                       "performanceFooter should mention 'immediately'")
    }
}
