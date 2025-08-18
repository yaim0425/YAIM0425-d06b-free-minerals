data:extend({
	{
		type = "bool-setting",
		name = "zzzYAIM0425-0600-stack_size",
		localised_name = {"", { "description.amount" }, " x ", { "gui-selector.stack-size" }},
		localised_description = { "",
			{ "gui-upgrade.module-limit" }, " ", "65k"
		},
		order = "1",
		setting_type = "startup",
		default_value = true
	}, {
		type = "int-setting",
		name = "zzzYAIM0425-0600-amount",
		localised_name = { "description.amount" },
		localised_description = { "",
			{ "gui-upgrade.module-limit" }, " ", "65k"
		},
		order = "2",
		setting_type = "startup",
		minimum_value = 2,
		maximum_value = 65000,
		default_value = 10
	}
})
