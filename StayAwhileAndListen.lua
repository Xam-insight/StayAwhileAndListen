-- Author      : Xam
-- Create Date : 10/07/2015 00:00:00 AM

local f = CreateFrame("Frame");

local BUTTON_LIST = {}
local willPlay, soundHandle

function f:EventHandler(event, arg1, ...)
    if event=="ADDON_LOADED" and arg1=="Blizzard_EncounterJournal" then
        SAAL_Load()
    end
end

function SAAL_CreateButton(objectId, parent, buttonIndex)
    local button = CreateFrame("BUTTON", "SAALButton", parent, "SAALButtonTemplate");
    button:SetAttribute("objectId", objectId)
    button:Show();
    BUTTON_LIST[buttonIndex] = button;
    return button;
end


function SAAL_Play(self)
    StopMusic()
    SAAL_StopSound(soundHandle)

    self:SetNormalTexture("Interface\\Common\\VoiceChat-Muted")
    self:SetHighlightTexture("")
    self:SetScript("OnClick", function(self) SAAL_Stop(self); end)

    DEFAULT_CHAT_FRAME:AddMessage(self:GetAttribute("objectId").."_"..SAAL_SoundFileLanguage)
    willPlay, soundHandle = PlaySoundFile("Interface\\Addons\\StayAwhileAndListen\\sounds\\"..self:GetAttribute("objectId").."_"..SAAL_SoundFileLanguage..".mp3", "MASTER")
    if not willPlay then
        local x = random(1, 9);
        willPlay, soundHandle = PlaySoundFile("Interface\\Addons\\StayAwhileAndListen\\sounds\\NoSound_"..x.."_"..SAAL_SoundFileLanguage..".mp3", "MASTER")
        UIErrorsFrame:AddMessage(SAAL_NoEntryMessage, 1.0, 0.0, 0.0, 53, 5);
    end
    if not willPlay then
        willPlay, soundHandle = PlaySoundKitID(11466, "DIALOG", false)
    end
end

function SAAL_CreateButtons()
    local bossIndex = 1;
    local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
    local bossButton;

    local encounter = EncounterJournal.encounter
    if encounter then
        local objectId = "SAALButton_Instance_"..EncounterJournal.instanceID
        if BUTTON_LIST[0] then
            local button = BUTTON_LIST[0];
            button:SetAttribute("objectId", objectId)
            button:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
            button:SetHighlightTexture("Interface\\Common\\VoiceChat-On")
            button:SetScript("OnClick", function(self) SAAL_Play(self); end)
        else
            local button = SAAL_CreateButton(objectId, encounter, 0)
            button:SetPoint("TOPLEFT", encounter, "TOPLEFT", 330, -22);
        end
    end

    while bossID do
        bossButton = _G["EncounterJournalBossButton"..bossIndex];
        if bossButton then
            local objectId = "SAALButton_Boss_"..bossID
           if BUTTON_LIST[bossIndex] then
                local button = BUTTON_LIST[bossIndex];
                button:SetAttribute("objectId", objectId)
                button:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
                button:SetHighlightTexture("Interface\\Common\\VoiceChat-On")
                button:SetScript("OnClick", function(self) SAAL_Play(self); end)
            else
                local button = SAAL_CreateButton(objectId, bossButton, bossIndex)
                button:SetPoint("RIGHT", bossButton, "RIGHT", -16, -2);
            end
        end
        bossIndex = bossIndex + 1;
        name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
    end
end

function SAAL_Stop(self)
    SAAL_StopSound(soundHandle)
    self:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
    self:SetHighlightTexture("Interface\\Common\\VoiceChat-On")
    self:SetScript("OnClick", function(self) SAAL_Play(self); end)
end

function SAAL_StopSound(sound)
    if sound then
        StopSound(sound)
    end
    SAAL_CreateButtons()
end


function SAAL_Load()
    hooksecurefunc("EncounterJournal_DisplayInstance", SAAL_CreateButtons);
    f:UnregisterEvent("ADDON_LOADED");
end

f:SetScript("OnEvent", f.EventHandler);
f:RegisterEvent("ADDON_LOADED");

