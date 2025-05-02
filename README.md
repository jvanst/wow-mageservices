# Mage Service Addon

Automates mage portal selling and consumable trading in World of Warcraft: Classic.

_Note: Addon is disabled by default. Use `/mageservice on`_

## Features

- Scans local and instance chat for players wanting to buy ports, water or food
- Whispers found players & invites them to the party
- Uses a proximty scanner to detect when players are in trade range. Automatically opens trade window.
- Ensures players paying for ports put the required gold into the trade window
- Fills the trade window with food/water when players are not looking for a port
- Blacklists players who keep the trade window open without action
- Ensure casting a port doesn't interfer with conjuring food/water
- Prints a trade summary
- Persists settings across game sessions

**Buttons**
- `Accept Trade` Appears once a trade is acceptable
- `Cast Portal` Appears once a player has paid for a port
- `Conjure` Appears when the players backpack doesn't have enough water/food
- `Advertise` Appears every 60 seconds to send advertisement to local and instance channel

![Screenshot 2025-05-02 142359](https://github.com/user-attachments/assets/f82609e9-f5e2-4944-b97f-cdc3487ba849)

## Technical Overview

### Architecture

MageService uses a modular design with a central namespace (`MAGESERVICE`) that stores references to all modules. Each module handles a specific aspect of functionality and is registered in the main namespace.

### Module Structure

- **[Init.lua](Init.lua)**: Initializes the global `MAGESERVICE` table
- **[Settings.lua](Settings.lua)**: Manages persistent settings that are saved between game sessions
- **[Core.lua](Core.lua)**: Main event handler and integration point for all modules
- **[ContainerUI.lua](ContainerUI.lua)**: Manages the movable UI container and button layout system
- **[Advertiser.lua](Advertiser.lua)**: Handles chat advertisements with cooldown management
- **[Blacklist.lua](Blacklist.lua)**: Manages player blacklisting system
- **[Destinations.lua](Destinations.lua)**: Handles portal destination detection and mapping
- **[Spells.lua](Spells.lua)**: Controls spell casting for portals and conjuring
- **[Trade.lua](Trade.lua)**: Manages trade window interactions and inventory operations
- **[TradeProximityMonitor.lua](TradeProximityMonitor.lua)**: Monitors nearby players for automated trading
- **[TradeTimeoutMonitor.lua](TradeTimeoutMonitor.lua)**: Handles trade timeout detection and cancellation
- **[Utilities.lua](Utilities.lua)**: Provides common utility functions

### Data Flow

1. **Event Registration**: The Core module registers for WoW events and distributes handling to appropriate modules
2. **Chat Processing**: Monitors chat channels for portal/food/water requests
3. **Player Handling**: Tracks player status, destinations, and trade states
4. **UI Management**: Dynamic button creation and layout based on current context
5. **Trade Automation**: Manages the entire trade workflow from detection to completion
6. **Settings Management**: Persists user preferences across sessions via WoW's SavedVariables system

### Slash Commands

- `/ms` or `/mageservice`: Toggle the addon on/off
- `/ms on` or `/mageservice on`: Explicitly enable the addon
- `/ms off` or `/mageservice off`: Explicitly disable the addon
- `/mageservice show`: Show the UI container
- `/mageservice hide`: Hide the UI container

## TODO

- Detect with party invites fails
- Only add full stacks of food/water to the trade window
- Ensure port isn't on cd
- Respond to players asking for specific water/food stack combinations
- Bag sorting
- Add more user-configurable settings
