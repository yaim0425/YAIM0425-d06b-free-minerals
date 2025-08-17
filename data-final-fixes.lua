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

    --- Crear las recetas de los fluidos
    This_MOD.create_recipes()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear entidad y relacionado
    This_MOD.create_entity()
    This_MOD.create_item()
    This_MOD.create_recipe()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valores de la referencia
function This_MOD.setting_mod()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores a duplicar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.resource = {}
    This_MOD.recipes = { create = {}, delete = {} }
    This_MOD.entity = GPrefix.entities["assembling-machine-2"]
    This_MOD.item = GPrefix.get_item_create_entity(This_MOD.entity)
    This_MOD.recipe = GPrefix.recipes[This_MOD.item.name][1]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Valores de configuración
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.amount = GPrefix.setting[This_MOD.id]["amount"]
    This_MOD.stack_size = GPrefix.setting[This_MOD.id]["stack_size"]

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Indicador del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Signal

    Signal = data.raw["virtual-signal"]["signal-deny"].icons[1].icon
    This_MOD.delete = { icon = Signal, scale = 0.5 }

    Signal = data.raw["virtual-signal"]["signal-check"].icons[1].icon
    This_MOD.create = { icon = Signal, scale = 0.5 }

    Signal = data.raw["virtual-signal"]["signal-star"].icons[1].icon
    This_MOD.indicator = { icon = Signal, scale = 0.25, shift = { 0, -5 } }

    Signal = data.raw["virtual-signal"]["signal-black"].icons[1].icon
    This_MOD.indicator_bg = { icon = Signal, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.actions = {
        delete = "ingredients",
        create = "results"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta base
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 1,

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

            --- Calcular el valor a utilizar
            local Amount = This_MOD.amount
            if This_MOD.stack_size then
                Amount = Amount * Resource.stack_size
                if Amount > 65000 then
                    Amount = 65000
                end
            end

            --- Actualizar los datos
            local Unit = This_MOD.stack_size and Resource.stack_size .. "x" .. This_MOD.amount or Amount
            Recipe.name = This_MOD.prefix .. action .. "-" .. Unit .. "u-" .. resource.name
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
                amount = Amount
            } }

            --- Guardar la recetas creadas
            table.insert(This_MOD.recipes[action], Recipe)

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

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.entity.name
    if GPrefix.entities[Name] then
        --- Modificar las recetas
        for action, _ in pairs(This_MOD.actions) do
            for _, resource in pairs(This_MOD.resource) do
                local Recipe = data.raw.recipe[This_MOD.prefix .. resource.name .. "-" .. action]
                Recipe.category = GPrefix.name .. "-free-" .. action
            end
        end
        return
    end


    --- Duplicar la entidad
    local Entity = util.copy(This_MOD.entity)

    --- Nombre de la entidad
    Entity.name = Name

    --- Anular los variables
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- Cambiar las propiedades
    Entity.energy_source = { type = "void" }
    table.insert(Entity.icons, This_MOD.indicator_bg)
    table.insert(Entity.icons, This_MOD.indicator)
    Entity.minable.results = { {
        type = "item",
        name = GPrefix.name .. "-free-" .. This_MOD.item.name,
        amount = 1
    } }

    --- Recetas validas
    Entity.crafting_categories = {}
    for action, _ in pairs(This_MOD.actions) do
        --- Agregar la categoria
        table.insert(
            Entity.crafting_categories,
            GPrefix.name .. "-free-" .. action
        )

        --- Crear las categorias
        GPrefix.extend({
            type = "recipe-category",
            name = GPrefix.name .. "-free-" .. action
        })

        --- Modificar las recetas
        for _, recipe in pairs(This_MOD.recipes[action]) do
            recipe.category = GPrefix.name .. "-free-" .. action
        end
    end

    --- Crear la entiadad
    GPrefix.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear los objetos
function This_MOD.create_item()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.item.name
    if GPrefix.items[Name] then return end

    --- Duplicar la entidad
    local Item = util.copy(This_MOD.item)

    --- Nombre de la entidad
    Item.name = Name

    --- Cambiar las propiedades
    Item.place_result = GPrefix.name .. "-free-" .. This_MOD.entity.name
    table.insert(Item.icons, This_MOD.indicator_bg)
    table.insert(Item.icons, This_MOD.indicator)

    --- Crear item
    GPrefix.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Crear la receta
function This_MOD.create_recipe()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar
    local Name = GPrefix.name .. "-free-" .. This_MOD.recipe.name
    if data.raw.recipe[Name] then return end

    --- Duplicar la receta
    local Recipe = util.copy(This_MOD.recipe)

    --- Cambiar los valores
    Recipe.name = Name
    Recipe.ingredients = {}
    Recipe.results = { {
        type = "item",
        name = GPrefix.name .. "-free-" .. This_MOD.item.name,
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
