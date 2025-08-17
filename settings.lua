data:extend({
	{
		type = "bool-setting",
		name = "zzzYAIM0425-0600-stack-size",
		localised_name = { "gui-selector.stack-size" },
		localised_description = { "",
			{ "gui.off" }, " -> ", { "gui-blueprint-parametrisation.value" }, " = ", { "description.amount" }, "\n",
			{ "gui.on" }, " -> ", { "gui-blueprint-parametrisation.value" }, " = ", { "description.amount" }, " x ", { "gui-selector.stack-size" }, "\n",
			{ "gui-upgrade.module-limit" }, " ", "" .. 65000
		},
		order = "1",
		setting_type = "startup",
		default_value = false
	}, {
		type = "int-setting",
		name = "zzzYAIM0425-0600-amount",
		localised_name = { "description.amount" },
		order = "2",
		setting_type = "startup",
		minimum_value = 2,
		maximum_value = 65000,
		default_value = 500
	}
})
