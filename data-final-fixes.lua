---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local ThisMOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function ThisMOD.Start()
    --- Valores de la referencia
    ThisMOD.setSetting()

    --- Objectos a afectar
    ThisMOD.getItems()

    --- Crear las recetas de los minerales
    ThisMOD.CreateRecipes()
end

--- Valores de la referencia
function ThisMOD.setSetting()
    --- Otros valores
    ThisMOD.Prefix   = "zzzYAIM0425-0600-"
    ThisMOD.name     = "free-minerals"
    ThisMOD.quantity = GPrefix.Setting[ThisMOD.Prefix]["quantity"]

    --- Indicador del MOD
    local BackColor  = ""

    BackColor        = data.raw["virtual-signal"]["signal-deny"].icon
    ThisMOD.delete   = { icon = BackColor, scale = 0.5 }

    BackColor        = data.raw["virtual-signal"]["signal-check"].icon
    ThisMOD.create   = { icon = BackColor, scale = 0.5 }

    ThisMOD.actions  = {
        ["create"] = "results",
        ["delete"] = "ingredients"
    }

    --- Receta base
    ThisMOD.recipe   = {
        type                      = "recipe",
        name                      = "",
        localised_name            = {},
        localised_description     = {},
        energy_required           = 0.002,

        hide_from_player_crafting = true,
        enabled                   = true,
        category                  = "basic-crafting",
        subgroup                  = ThisMOD.Subgroup,
        order                     = "",

        ingredients               = {},
        results                   = {}
    }
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Objectos a afectar
function ThisMOD.getItems()
    --- Objectos a duplicar
    ThisMOD.Items = {}

    --- Objectos minables
    for _, element in pairs(data.raw.resource) do
        if element.minable then
            local minable = element.minable
            if minable.result then
                ThisMOD.Items[minable.result] = true
            end
            for _, result in pairs(minable.results or {}) do
                if result.type == "item" then
                    ThisMOD.Items[result.name] = true
                end
            end
        end
    end

    --- Cargar los minerales encontrados
    for name, _ in pairs(ThisMOD.Items) do
        ThisMOD.Items[name] = GPrefix.items[name]
    end
end

--- Crear las recetas de los minerables
function ThisMOD.CreateRecipes()
    --- Contenedor de las nuevas recetas
    local Recipes = {}

    --- Recorrer los minerales
    for action, propiety in pairs(ThisMOD.actions) do
        for _, Item in pairs(ThisMOD.Items) do
            --- Crear una copia de los datos
            local recipe   = util.copy(ThisMOD.recipe)
            local item     = util.copy(Item)

            --- Crear el subgroup
            local subgroup = ThisMOD.Prefix .. item.subgroup .. "-" .. action
            GPrefix.duplicate_subgroup(item.subgroup, subgroup)

            --- Actualizar los datos
            recipe.name                  = ThisMOD.Prefix .. item.name .. "-" .. action
            recipe.localised_name        = item.localised_name
            recipe.localised_description = item.localised_description

            recipe.subgroup              = subgroup
            recipe.order                 = item.order

            recipe.icons                 = item.icons

            --- Variaciones entre las recetas
            table.insert(recipe.icons, ThisMOD[action])
            recipe[propiety] = { {
                type = "item",
                name = item.name,
                amount = ThisMOD.quantity
            } }

            --- Crear el prototipo
            GPrefix.addDataRaw({ recipe })

            --- Guardar la nueva receta
            Recipes[action] = Recipes[action] or {}
            table.insert(Recipes[action], recipe)
        end
    end

    --- Ordenar las recetas
    for action, _ in pairs(ThisMOD.actions) do
        GPrefix.setOrder(Recipes[action])
    end
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
ThisMOD.Start()

---------------------------------------------------------------------------------------------------
