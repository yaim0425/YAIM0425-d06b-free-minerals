---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.reference_values()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            --- Crear los elementos
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Crear las recetas para los minerales
    This_MOD.create_recipe___free()

    --- Ejecutar otro MOD
    if GMOD.d01b then GMOD.d01b.start() end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si se cargó antes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Indicador del mod
    This_MOD.delete = { icon = GMOD.signal.deny, scale = 0.5 }
    This_MOD.create = { icon = GMOD.signal.check, scale = 0.5 }

    This_MOD.indicator = { icon = GMOD.signal.star, scale = 0.25, shift = { 0, -5 } }
    This_MOD.indicator_bg = { icon = GMOD.signal.black, scale = 0.25, shift = { 0, -5 } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de referencia
    This_MOD.old_entity_name = "assembling-machine-2"
    This_MOD.new_entity_name = GMOD.name .. "-A00A-market"
    This_MOD.new_localised_name = { "", { "entity-name.market" } }

    --- Acciones
    This_MOD.actions = {
        delete = "ingredients",
        create = "results"
    }

    --- Receta base
    This_MOD.recipe_base = {
        type = "recipe",
        name = "",
        localised_name = {},
        localised_description = {},
        energy_required = 1,

        hide_from_player_crafting = true,
        subgroup = "",
        order = "",

        ingredients = {},
        results = {}
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar valores de referencia
        if GMOD.entities[This_MOD.new_entity_name] then return end

        --- Validar la entity
        if not entity then return end

        --- Validar el item
        if not item then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Fluidos a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function get_resource()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variable a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Output = {}

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Objectos minables
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        for _, element in pairs(data.raw.resource) do
            if element.minable then
                for _, result in pairs(element.minable.results or {}) do
                    if result.type == "item" then
                        local Item = GMOD.items[result.name]
                        local Amount = This_MOD.setting.amount
                        if This_MOD.setting.stack_size then
                            Amount = Amount * Item.stack_size
                            Output[result.name] =
                                Amount > 65000 and
                                65000 or
                                Amount
                        end
                    end
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Devolver el resultado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return Output

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad que se va a duplicar
    valide_entity(
        GMOD.items[This_MOD.old_entity_name],
        GMOD.entities[This_MOD.old_entity_name]
    )

    --- Material a afectar
    This_MOD.resource = get_resource()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = This_MOD.new_entity_name

    --- Apodo
    Item.localised_name = This_MOD.new_localised_name

    --- Actualizar el order
    local Order = tonumber(Item.order) + 2
    Item.order = GMOD.pad_left_zeros(#Item.order, Order)

    --- Agregar indicador del MOD
    table.insert(Item.icons, This_MOD.indicator_bg)
    table.insert(Item.icons, This_MOD.indicator)

    --- Entidad a crear
    Item.place_result = This_MOD.new_entity_name

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(space.entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = This_MOD.new_entity_name

    --- Apodo
    Entity.localised_name = This_MOD.new_localised_name

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- Elimnar propiedades inecesarias
    Entity.fast_replaceable_group = nil
    Entity.next_upgrade = nil

    --- No usa energía
    Entity.energy_source = { type = "void" }

    --- Categoria de fabricación
    Entity.crafting_categories = {}

    --- Agregar indicador del MOD
    Entity.icons = GMOD.copy(space.item.icons)
    table.insert(Entity.icons, This_MOD.indicator_bg)
    table.insert(Entity.icons, This_MOD.indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = This_MOD.new_entity_name

    --- Apodo y descripción
    Recipe.localised_name = This_MOD.new_localised_name

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Productividad
    Recipe.allow_productivity = true
    Recipe.maximum_productivity = 1000000

    --- Receta desbloqueada por tecnología
    Recipe.enabled = true

    --- Agregar indicador del MOD
    Recipe.icons = GMOD.copy(space.item.icons)
    table.insert(Recipe.icons, This_MOD.indicator_bg)
    table.insert(Recipe.icons, This_MOD.indicator)

    --- Ingredientes
    Recipe.ingredients = {}

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = This_MOD.new_entity_name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_recipe___free()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Procesar cada recurso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_resource(args)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Calcular el valor a utilizar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Name =
            This_MOD.prefix ..
            args.action .. "-" ..
            (
                This_MOD.setting.stack_size and
                args.item.stack_size .. "x" .. This_MOD.setting.amount or
                args.amount
            ) .. "u-" ..
            args.item.name

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if data.raw.recipe[Name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgroup
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Subgroup =
            This_MOD.prefix ..
            args.item.subgroup .. "-" ..
            args.action
        GMOD.duplicate_subgroup(args.item.subgroup, Subgroup)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el elemento
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Recipe = GMOD.copy(This_MOD.recipe_base)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nombre
        Recipe.name = Name

        --- Apodo y descripción
        Recipe.localised_name = args.item.localised_name
        Recipe.localised_description = args.item.localised_description

        --- Subgrupo y Order
        Recipe.subgroup = Subgroup
        Recipe.order = args.item.order

        --- Agregar indicador del MOD
        Recipe.icons = GMOD.copy(args.item.icons)

        --- Categoria de fabricación
        Recipe.category = This_MOD.prefix .. args.action

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Variaciones entre las recetas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        table.insert(Recipe.icons, This_MOD[args.action])
        Recipe[args.propiety] = { {
            type = "item",
            name = args.item.name,
            amount = args.amount,
            ignored_by_stats = This_MOD.setting.amount
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer cada mineral
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for resource, amount in pairs(This_MOD.resource) do
        for action, propiety in pairs(This_MOD.actions) do
            validate_resource({
                item = GMOD.items[resource],
                action = action,
                amount = amount,
                propiety = propiety
            })
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear categoria y agrega a la maquita
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Category = GMOD.entities[This_MOD.new_entity_name].crafting_categories
    for action, _ in pairs(This_MOD.actions) do
        local Name = This_MOD.prefix .. action
        if GMOD.get_key(Category, Name) then break end
        GMOD.extend({ type = "recipe-category", name = Name })
        table.insert(Category, Name)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
