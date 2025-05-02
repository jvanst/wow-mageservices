# Mage Service Addon

Automates mage portal selling and consumable trading in World of Warcraft: Classic.

## Features

- Scans local and instance chat for players wanting to buy ports, water or food
- Whispers found players & invites them to the party
- Uses a proximty scanner to detect when players are in trade range. Automatically opens trade window.
- Ensures players paying for ports put the required gold into the trade window
- Fills the trade window with food/water when players are not looking for a port
- Blacklists players who keep the trade window open without action
- Ensure casting a port doesn't interfer with conjuring food/water
- Prints a trade summary

**Buttons**
- `Accept Trade`: Appears once a trade is accaptable
- `Cast Portal`: Appears once a player has paid for a port
- `Conjure`: Appears when the players backpack doesn't have enough water/food
- `Advertise`: Appears every 60 seconds to send advertisement to local and instance channel

## TODO

- Detect with party invites fails
- Only add full stacks of food/water to the trade window
- Ensure port isn't on cd
- Respond to players asking for specific water/food stack combinations
- Bag sorting