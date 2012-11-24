Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/GUIDial.lua")

class 'GUIHandCannonDisplay' (GUIScript)

local kAmmoDialWidth = 300
local kAmmoDialHeight = 256
local kAmmoDialBackgroundTextureX1 = 0
local kAmmoDialBackgroundTextureX2 = 512
local kAmmoDialBackgroundTextureY1 = 0
local kAmmoDialBackgroundTextureY2 = 512

local kAmmoDialForegroundTextureX1 = 512
local kAmmoDialForegroundTextureX2 = 1024
local kAmmoDialForegroundTextureY1 = 0
local kAmmoDialForegroundTextureY2 = 512


local kAmmoDialSize = Vector(kAmmoDialWidth, kAmmoDialHeight, 0)

local kAmmoDialTextureName = "ui/health_circle.dds"
local kAmmoColors = { Color(0.8, 0, 0), Color(0.8, 0.5, 0), Color(0.7, 0.7, 0.7) }
local kNumberAmmoColors = table.maxn(kAmmoColors)

function GUIHandCannonDisplay:Initialize()

    self.weaponClip     = 0
    self.weaponAmmo     = 0
    self.weaponClipSize = 10
    
    self.onDraw = 0
    self.onHolster = 0

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(256, 512, 0) )
    self.background:SetPosition( Vector(0, 0, 0))    
    self.background:SetTexture("ui/RifleDisplay.dds")
	self.background:SetColor(Color(1, 1, 1, 0.1))
    self.background:SetIsVisible(true)

    // Slightly larger copy of the text for a glow effect
    self.ammoTextBg = GUIManager:CreateTextItem()
    self.ammoTextBg:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoTextBg:SetFontIsBold(true)
    self.ammoTextBg:SetFontSize(75)
    self.ammoTextBg:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoTextBg:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoTextBg:SetPosition(Vector(135, 125, 0))
    self.ammoTextBg:SetColor(Color(1, 1, 1, 0.25))

    // Text displaying the amount of ammo in the clip
    self.ammoText = GUIManager:CreateTextItem()
    self.ammoText:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoText:SetFontIsBold(true)
    self.ammoText:SetFontSize(60)
    self.ammoText:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoText:SetPosition(Vector(135, 125, 0))
	
	// Text displaying the amount of ammo in the clip
    self.reserveText = GUIManager:CreateTextItem()
    self.reserveText:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.reserveText:SetFontIsBold(true)
    self.reserveText:SetFontSize(30)
    self.reserveText:SetTextAlignmentX(GUIItem.Align_Center)
    self.reserveText:SetTextAlignmentY(GUIItem.Align_Center)
    self.reserveText:SetPosition(Vector(135, 300, 0))
    
    // Create the indicators for the number of bullets in reserve.
	local ammoDialSettings = {}
    ammoDialSettings.BackgroundWidth = kAmmoDialSize.x
    ammoDialSettings.BackgroundHeight = kAmmoDialSize.y
    ammoDialSettings.BackgroundAnchorX = GUIItem.Left
    ammoDialSettings.BackgroundAnchorY = GUIItem.Bottom
    ammoDialSettings.BackgroundOffset = Vector(0, 0, 0)
    ammoDialSettings.BackgroundTextureName = kAmmoDialTextureName
    ammoDialSettings.BackgroundTextureX1 = kAmmoDialBackgroundTextureX1
    ammoDialSettings.BackgroundTextureY1 = kAmmoDialBackgroundTextureY1
    ammoDialSettings.BackgroundTextureX2 = kAmmoDialBackgroundTextureX2
    ammoDialSettings.BackgroundTextureY2 = kAmmoDialBackgroundTextureY2
    ammoDialSettings.ForegroundTextureName = kAmmoDialTextureName
    ammoDialSettings.ForegroundTextureWidth = kAmmoDialWidth
    ammoDialSettings.ForegroundTextureHeight = kAmmoDialHeight
    ammoDialSettings.ForegroundTextureX1 = kAmmoDialForegroundTextureX1
    ammoDialSettings.ForegroundTextureY1 = kAmmoDialForegroundTextureY1
    ammoDialSettings.ForegroundTextureX2 = kAmmoDialForegroundTextureX2
    ammoDialSettings.ForegroundTextureY2 = kAmmoDialForegroundTextureY2
    ammoDialSettings.InheritParentAlpha = false
    self.ammoDial = GUIDial()
    self.ammoDial:Initialize(ammoDialSettings)
	
	// Hide the right side.
    self.ammoDial:GetRightSide():SetColor(Color(0, 0, 0, 0))
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIHandCannonDisplay:Uninitialize()

    if self.ammoDial then
        self.ammoDial:Uninitialize()
        self.ammoDial = nil
    end
    
end

function GUIHandCannonDisplay:InitFlashInOverLay()

end

function GUIHandCannonDisplay:Update(deltaTime)

    PROFILE("GUIBulletDisplay:Update")
    
    // Update the ammo counter.
    local ammoFormat = string.format("%02d", self.weaponClip) 
    self.ammoText:SetText( ammoFormat )
    self.ammoTextBg:SetText( ammoFormat )
	
	// Update the dial
	local ammoFraction = 50 + (self.weaponClip / self.weaponClipSize * 50)
	ammoFraction = math.min(math.max(ammoFraction, 0), 100) / 100
	// Need to use half the percentage because the dial code expects two dials!
	self.ammoDial:SetPercentage(ammoFraction)
	// Pulse the dial when it is low...
	// Red when nearly out of ammo?
	self.dialColor = Color(1, 1, 1, 1)
    self.ammoDial:Update(deltaTime)
	self.ammoDial:GetLeftSide():SetColor(self.dialColor)
	
	local reserveFormat = string.format("%02d", self.weaponAmmo) 
	self.reserveText:SetText( reserveFormat )

end

function GUIHandCannonDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIHandCannonDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIHandCannonDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIHandCannonDisplay:SetClipFraction(clipIndex, fraction)

    local offset   = (1 - fraction) * self.clipHeight
    local position = Vector( self.clip[clipIndex]:GetPosition().x, self.clipTop + offset, 0 )
    local size     = self.clip[clipIndex]:GetSize()
    
    self.clip[clipIndex]:SetPosition( position )
    self.clip[clipIndex]:SetSize( Vector( size.x, fraction * self.clipHeight, 0 ) )
    self.clip[clipIndex]:SetTexturePixelCoordinates( position.x, position.y + 256, position.x + self.clipWidth, self.clipTop + self.clipHeight + 256 )

end