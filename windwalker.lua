WW = {
  abilities = {
    jab = 100780,
    tigerPalm = 100787,
    rsk = 107428,
    fof = 113656,
    chiWave = 115098,
    bok = 100784,
    expelHarm = 115072,
  },

  gcd = 100780, -- jab

  -- buffs
  buffIDs = {
    tigerPower = 125359,
    comboTigerPalm = 118864,
    comboBok = 116768
  },

  hasTigerPower = function()
    local index = 1
    while UnitBuff("PLAYER", index) do
      local name = UnitBuff("PLAYER", index)
      if name == 'Tiger Power' then
        return true
      end
      index = index + 1
    end
    return false
  end,

  hasComboTigerPalm = function()
    local index = 1
    while UnitBuff("PLAYER", index) do
      local name = UnitBuff("PLAYER", index)
      if name == 'Combo Breaker: Tiger Palm' then
        return true
      end
      index = index + 1
    end
    return false
  end,

  tigerPowerDuration = function()
    local index = 1
    while UnitBuff("PLAYER", index) do
      local name, rank, icon, count, debuffType, duration = UnitBuff("PLAYER", index)
      if name == WW.buffIDs.tigerPower then
        return duration
      end
      index = index + 1
    end
    return 0
  end,

  -- ww rotations for WoD
  --
  -- Tiger Palm if no buff up or if dropping in next 2 GCDs
  -- RSK
  -- FoF if energy won't cap
  -- Chi Wave
  -- Blackout Kick
  -- Expel Harm if below 85% health
  -- Jab
  priorities = {
    list = 'tigerPalm rsk fof chi bok expel jab',
    one = nil,
    two = nil,
    spells = {
      tigerPalm = {
        id = 100787,
        chi = function()
          return -1
        end,
        energy = 0,
        priority = function()
          local id = WW.priorities.spells.tigerPalm.id
          local start, duration, enabled = GetSpellCooldown(id)
          if WW.combatState.chi.value >= 1 then
            if WW.hasTigerPower() or WW.tigerPowerDuration() > 2.0 then
              return 100
            else
              return duration
            end
          end
          return 100
        end,
        expected = function()
          local id = WW.priorities.spells.tigerPalm.id
          if WW.priorities.one.id == id then
            return 100
          else
            local start, duration, enabled = GetSpellCooldown(id)
            if WW.futureState.chi.value >= 1 then
              if WW.hasTigerPower() or WW.tigerPowerDuration() > 2.0 + WW.combatState.gcdLength.value then
                return 100
              else
                return duration - WW.combatState.gcdLength.value
              end
            end
            return 100
          end
        end
      },
      rsk = {
        id = 107428,
        chi = function()
          return -2
        end,
        energy = 0,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.rsk.id)
          if WW.combatState.chi.value >= 2 then
            return duration
          else
            return 100
          end
        end,
        expected = function()
          if WW.priorities.one.id == WW.priorities.spells.rsk.id then
            return 100
          else
            local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.rsk.id)
            if WW.futureState.chi.value >= 2 then
              return duration - WW.combatState.gcdLength.value
            else
              return 100
            end
          end
        end
      },
      fof = {
        id = 113656,
        chi = function()
          return -3
        end,
        energy = 0,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.fof.id)
          if WW.combatState.chi.value >= 3 then
            return duration
          else
            return 100
          end
        end,
        expected = function()
          if WW.priorities.one.id == WW.priorities.spells.fof.id then
            return 100
          else
            local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.fof.id)
            if WW.futureState.chi.value >= 3 then
              return duration - WW.combatState.gcdLength.value
            else
              return 100
            end
          end

        end
      },
      chi = {
        id = 115098,
        chi = function()
          return 0
        end,
        energy = 0,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.chi.id)
          return duration
        end,
        expected = function()
          if WW.priorities.one.id == WW.priorities.spells.chi.id then
            return 100
          else
            local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.chi.id)
            return duration - WW.combatState.gcdLength.value
          end
        end
      },
      bok = {
        id = 100784,
        chi = function()
          return -2
        end,
        energy = 0,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.bok.id)
          if WW.combatState.chi.value >= 2 then
            return duration
          else
            return 100
          end
        end,
        expected = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.bok.id)
          if WW.futureState.chi.value >= 2 then
            return duration - WW.combatState.gcdLength.value
          else
            return 100
          end
        end
      },
      expel = {
        id = 115072,
        chi = function()
          return 2
        end,
        energy = -40,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.expel.id)
          if WW.combatState.maxChi.value - WW.combatState.chi.value >= 2 then
            if WW.combatState.maxHealth.value - WW.combatState.health.value >= 3000 then
              return duration
            end
          end
          return 100
        end,
        expected = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.expel.id)
          if WW.combatState.maxChi.value - WW.futureState.chi.value >= 2 then
            if WW.combatState.maxHealth.value - WW.combatState.health.value >= 3000 then
              return duration
            end
          end
          return 100
        end
      },
      jab = {
        id = 100780,
        chi = function()
          return 2
        end,
        energy = -45,
        priority = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.jab.id)

          return duration
        end,
        expected = function()
          local start, duration, enabled = GetSpellCooldown(WW.priorities.spells.jab.id)

          return duration - WW.combatState.gcdLength.value
        end
      },
    }
  },

  futureState = {
    chi = {
      value = 0,
      update = function()
        WW.futureState.chi.value = WW.combatState.chi.value + WW.priorities.one.chi()
      end
    },
    energy = {
      value = 0,
      update = function()
        local calculatedEnergy = WW.combatState.energy.value + WW.priorities.one.energy + WW.combatState.gcdLength.value * WW.combatState.energyRegen.value
        WW.futureState.energy.value = math.min(WW.combatState.maxEnergy.value, calculatedEnergy)
      end
    },
  },

  combatState = {
    energyRegen = {
      value = 0,
      update = function()
        local inactiveRegen, activeRegen = GetPowerRegen()
        WW.combatState.energyRegen.value = activeRegen
      end
    },
    gcdLength = {
      value = nil,
      update = function()
        _,gcd=GetSpellCooldown(WW.gcd)
        WW.combatState.gcdLength.value = gcd
      end
    },
    currentHaste = {
      value = 0,
      update = function()
        WW.combatState.currentHaste.value = UnitSpellHaste('player')
      end
    },
    chi = {
      value = 0,
      update = function()
        WW.combatState.chi.value = UnitPower("player", SPELL_POWER_CHI)
      end
    },
    maxChi = {
      value = 0,
      update = function()
        WW.combatState.maxChi.value = UnitPowerMax("player", SPELL_POWER_CHI)
      end
    },
    energy = {
      value = 0,
      update = function()
        WW.combatState.energy.value = UnitPower("player", SPELL_POWER_ENERGY)
      end
    },
    maxEnergy = {
      value = 0,
      update = function()
        WW.combatState.maxEnergy.value = UnitPowerMax("player", SPELL_POWER_ENERGY)
      end
    },
    health = {
      value = 0,
      update = function()
        WW.combatState.health.value = UnitHealth("player")
      end
    },
    maxHealth = {
      value = 0,
      update = function()
        WW.combatState.maxHealth.value = UnitHealthMax("player")
      end
    }
  },

  updateCombatState = function()
    for state, value in pairs(WW.combatState) do
      value.update()
    end
  end,

  updateFutureState = function()
    for state, value in pairs(WW.futureState) do
      value.update()
    end
  end,

  calculateSpell = function (priorityFunction)
    local firstSpell = nil
    local lowestValue = nil
    for spell in string.gmatch(WW.priorities.list, "%S+") do
      currentValue = WW.priorities.spells[spell][priorityFunction]()
      if firstSpell == nil then
        firstSpell = WW.priorities.spells[spell]
        lowestValue = currentValue
      else
        if currentValue < lowestValue then
          firstSpell = WW.priorities.spells[spell]
          lowestValue = currentValue
        end
      end
    end

    return firstSpell
  end,

  updatePriorities = function()
    WW.updateCombatState()

    -- First priority
    WW.priorities.one = WW.calculateSpell('priority')

    WW.updateFutureState()

    -- Second Priority
    WW.priorities.two = WW.calculateSpell('expected')
  end,

  priority1 = function()
    WW.updatePriorities()
    return WW.priorities.one.id
  end,

  priority2 = function()
    return WW.priorities.two.id
  end
}
