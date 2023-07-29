--
-- NoTrespassing_loader.lua
--
-- This is file with NoTrespassing mod initialization functions.
--
-- Author: Bodzio528
--

local modName = g_currentModName
local modDirectory = g_currentModDirectory

function onStartMission(mission)        
    if g_noTrespassing ~= nil then
        local path = Utils.getFilename("data/noTrespassing.xml", modDirectory)
        loadModDataXml(path)
    end

    local userSettingsFile = Utils.getFilename("modSettings/NoTrespassing.xml", getUserProfileAppPath())
	if not fileExists(userSettingsFile) then
        createSettingsDataXml(userSettingsFile)
    else
        loadSettingsDataXml(userSettingsFile)
	end
end

local function validateTypes(typeManager)
    if typeManager.typeName == "vehicle" then
        g_specializationManager:addSpecialization("noTrespassing", "NoTrespassing", Utils.getFilename("NoTrespassing.lua", modDirectory), nil)

        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(Drivable, typeEntry.specializations)
                and SpecializationUtil.hasSpecialization(Enterable, typeEntry.specializations)
                and not SpecializationUtil.hasSpecialization(Locomotive, typeEntry.specializations)
            then
                g_vehicleTypeManager:addSpecialization(typeName, modName .. ".noTrespassing")
                
                print(modName .. " [INFO] added specialization to " .. typeName)
            -- else
                -- print(modName .. " [INFO] skip vehicle type " .. typeName)                
            end
        end
    end
end

local function init()
    -- print(modName .. " [DEBUG] init()")

    if g_noTrespassing ~= nil then 
        return 
    end

    getfenv(0)["g_noTrespassing"] = {}

    Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, onStartMission)
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateTypes)
end

init()

--------------------------------------------------------------------------------

function loadModDataXml(path)
    -- print(modName .. " [DEBUG] load mod data from file " .. path)
    
    -- provide sane defaults in case the xml file gets corrupted --
    local data = {
        difficulty = { 0.50, 1.0, 2.0 },
        ground = 2.0
    }

    if fileExists(path) then
        local xmlFile = loadXMLFile("noTrespassing", path)

        local key = "noTrespassing"
        local difficultyKey = key .. ".difficulty"
        if hasXMLProperty(xmlFile, difficultyKey) then
            data.difficulty = { 
                getXMLFloat(xmlFile, difficultyKey .. "#easy"), 
                getXMLFloat(xmlFile, difficultyKey .. "#normal"), 
                getXMLFloat(xmlFile, difficultyKey .. "#hard")
            }
            print(modName .. string.format(" [INFO] penalty modifiers: [ %s ]", table.concat(data.difficulty, " | ")))
        end

        local groundKey = key .. ".ground"
        if hasXMLProperty(xmlFile, groundKey) then
            data.ground = getXMLFloat(xmlFile, groundKey .. "#base")
            print(modName .. string.format(" [INFO] penalty base: %f", data.ground))
        end
        
        --[[ crop types loading omited for performance ]]--
        
        delete(xmlFile)
    else
        print(modName .. " [ERROR] Could not read file: " .. path)
    end

    getfenv(0)["g_noTrespassing"] = {}
    g_noTrespassing.data = data
end

function createSettingsDataXml(path)
    -- print(modName .. " [DEBUG] create mod settings to file " .. path)

    local key = "noTrespassing"
    local xmlFile = createXMLFile("noTrespassing", path, key)
    if xmlFile ~= 0 then
        setXMLFloat(xmlFile, key .. ".ground#base", g_noTrespassing.data.ground)

        saveXMLFile(xmlFile)
        delete(xmlFile)
    end
end

function loadSettingsDataXml(path)
    -- print(modName .. " [DEBUG] load mod settings from file " .. path)

    if g_noTrespassing ~= nil and g_noTrespassing.data ~= nil then
        local data = g_noTrespassing.data
        
        local xmlFile = loadXMLFile("noTrespassing", path)
        
        local groundKey = "noTrespassing.ground"
        if hasXMLProperty(xmlFile, groundKey) then
            data.ground = getXMLFloat(xmlFile, groundKey .. "#base")
            print(modName .. string.format(" [INFO] override penalty base: %f", g_noTrespassing.data.ground))
        end
    
        delete(xmlFile)
    else
        print(modName .. " [ERROR] mod data not initialized properly!")
    end
end