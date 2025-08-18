---------------------------------------------------------------------------------------------------
---> settings-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Cargar las funciones
require("__zzzYAIM0425-0000-lib__.settings-final-fixes")

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Opciones: stack_size
table.insert(This_MOD, {
	type = "bool-setting",
	name = GPrefix.name .. "-0600-stack_size",
	localised_name = { "", { "description.amount" }, " x ", { "gui-selector.stack-size" } },
	localised_description = { "",
		{ "gui-upgrade.module-limit" }, " ", "65k"
	},
	setting_type = "startup",
	default_value = true
})
This_MOD[#This_MOD].order = tostring(#This_MOD)

--- Opciones: amount
table.insert(This_MOD, {
	type = "int-setting",
	name = GPrefix.name .. "-0600-amount",
	localised_name = { "description.amount" },
	order = "2",
	setting_type = "startup",
	minimum_value = 2,
	maximum_value = 65000,
	default_value = 10
})
This_MOD[#This_MOD].order = tostring(#This_MOD)

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Cargar la configuración
data:extend(This_MOD)

---------------------------------------------------------------------------------------------------
