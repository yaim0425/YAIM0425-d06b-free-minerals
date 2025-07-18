---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local This_MOD = {}

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Obtener información desde el nombre de MOD
    GPrefix.split_name_folder(This_MOD)

    --- Valores de la referencia
    This_MOD.setting_mod()

    --- Fluidos a afectar
    This_MOD.get_resource()

    -- --- Crear las recetas de los fluidos
    -- This_MOD.create_recipes()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Crear entidad y relacionado
    -- This_MOD.create_entity()
    -- This_MOD.create_item()
    -- This_MOD.create_recipe()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores a duplicar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.resource = {}
    This_MOD.entity = GPrefix.entities["assembling-machine-1"]
    This_MOD.item = GPrefix.get_item_create_entity(This_MOD.entity)
    This_MOD.recipe = GPrefix.recipes[This_MOD.item.name][1]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores de configuración
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.amount = GPrefix.Setting[This_MOD.id]["amount"]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Indicador del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local BackColor = ""

    BackColor = data.raw["virtual-signal"]["signal-deny"].icons[1].icon
    This_MOD.delete = { icon = BackColor, scale = 0.5 }

    BackColor = data.raw["virtual-signal"]["signal-check"].icons[1].icon
    This_MOD.create = { icon = BackColor, scale = 0.5 }

    BackColor = data.raw.item["uranium-ore"].icons[1].icon
    This_MOD.indicator = { icon = BackColor, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.actions = {}
    This_MOD.actions.create = "results"
    This_MOD.actions.delete = "ingredients"

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta base
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 0.002,

        hide_from_player_crafting = true,
        category = "basic-crafting",
        subgroup = "",
        order = "",

        ingredients = {},
        results = {},
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Fluidos a afectar
function This_MOD.get_resource()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Objectos minables
    for _, element in pairs(data.raw.resource) do
        if element.minable then
            for _, result in pairs(element.minable.results or {}) do
                if result.type == "item" then
                    This_MOD.resource[result.name] = true
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar los minerales encontrados
    for name, _ in pairs(This_MOD.resource) do
        This_MOD.resource[name] = GPrefix.items[name]
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear las recetas
function This_MOD.create_recipes()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer los fluidos
    for action, propiety in pairs(This_MOD.actions) do
        for _, resource in pairs(This_MOD.resource) do
            --- Crear una copia de los datos
            local Recipe = util.copy(This_MOD.recipe_base)
            local Resource = util.copy(resource)

            --- Crear el subgroup
            local Subgroup = This_MOD.prefix .. Resource.subgroup .. "-" .. action
            GPrefix.duplicate_subgroup(Resource.subgroup, Subgroup)

            --- Actualizar los datos
            Recipe.name = This_MOD.prefix .. Resource.name .. "-" .. action
            Recipe.localised_name = Resource.localised_name
            Recipe.localised_description = Resource.localised_description

            Recipe.subgroup = Subgroup
            Recipe.order = Resource.order

            Recipe.icons = Resource.icons

            --- Variaciones entre las recetas
            table.insert(Recipe.icons, This_MOD[action])
            Recipe[propiety] = { {
                type = "item",
                name = Resource.name,
                amount = This_MOD.amount
            } }

            --- Crear el prototipo
            GPrefix.extend(Recipe)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Crear las entidades
function This_MOD.create_entity()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad
    local Entity = util.copy(This_MOD.entity)

    --- Nombre de la entidad
    Entity.name = This_MOD.prefix .. Entity.name

    --- Anular los variables
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- Cambiar las propiedades
    Entity.energy_source = { type = "void" }
    table.insert(Entity.icons, This_MOD.indicator)
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.prefix .. This_MOD.item.name,
        amount = 1
    } }

    --- Recetas validas
    Entity.crafting_categories = {}
    for action, _ in pairs(This_MOD.actions) do
        --- Agregar la categoria
        table.insert(
            Entity.crafting_categories,
            This_MOD.prefix .. action
        )

        --- Crear las categorias
        GPrefix.extend({
            type = "recipe-category",
            name = This_MOD.prefix .. action
        })

        --- Modificar las recetas
        for _, fluid in pairs(This_MOD.resource) do
            local Recipe = data.raw.recipe[This_MOD.prefix .. fluid.name .. "-" .. action]
            Recipe.category = This_MOD.prefix .. action
        end
    end

    --- Crear la entiadad
    GPrefix.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear los objetos
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la entidad
    local Item = util.copy(This_MOD.item)

    --- Nombre de la entidad
    Item.name = This_MOD.prefix .. Item.name

    --- Cambiar las propiedades
    Item.place_result = This_MOD.prefix .. Item.place_result
    table.insert(Item.icons, This_MOD.indicator)

    --- Crear item
    GPrefix.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.create_recipe()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Duplicar la receta
    local Recipe = util.copy(This_MOD.recipe)

    --- Cambiar los valores
    Recipe.name = This_MOD.prefix .. Recipe.name
    Recipe.ingredients = {}
    Recipe.results = { {
        type = "item",
        name = This_MOD.prefix .. This_MOD.item.name,
        amount = 1
    } }

    --- Crear la receta
    GPrefix.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
This_MOD.start()

---------------------------------------------------------------------------------------------------


if true then return end


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
