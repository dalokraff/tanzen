return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`tanzen` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("tanzen", {
			mod_script       = "scripts/mods/tanzen/tanzen",
			mod_data         = "scripts/mods/tanzen/tanzen_data",
			mod_localization = "scripts/mods/tanzen/tanzen_localization",
		})
	end,
	packages = {
		"resource_packages/tanzen/tanzen",
	},
}
