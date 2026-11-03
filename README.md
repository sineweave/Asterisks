# Asterisks

## Rundown
Asterisks is a simple dialogue JSON charter and exporter, aimed at dialogue based games (such as RPGs or simple visual novels) that supports Godot 4.3+

Asterisks utilizes Godot's graphnode and graphedit nodes to map out dialogue in simplistic graphs in which each step of dialogue is portrayed in a node.
<img width="1229" height="380" alt="image" src="https://github.com/user-attachments/assets/6490c484-9675-4cbb-9008-83c57352685d" />

Asterisks gives you several fields to edit, which change values for each key inside of each block of dialogue.
<img width="343" height="867" alt="image" src="https://github.com/user-attachments/assets/f863f58b-0730-4cf3-9fcd-c6f3440e888a" />

Asterisks is a great choice if your game has branching dialogue options.
<img width="706" height="918" alt="image" src="https://github.com/user-attachments/assets/8ece734c-fd73-4c97-b671-d84d2d205710" />

I originally created Asterisks because my own RPG game needed a dialogue editor (and the one I was previously using was pretty bad). Because of this, it reflects my own game's needs a bit excessively.

To fix this, I might add custom/modular input fields and more robust dialogue optioning in a later version. But that won't be for a while. For now, you can fork it to do whatever fits your game.

## Features
* Exporting and importing dialogue JSON files (or other extensions so long as they have the same syntax)
* Support for data such as character names, voices, tones, dialogue options, and function execution (for example, animations or sounds)
* MIT licensed (you can put this in your game or fork it for free without royalties or credit)
* Integrates seamlessly in Godot as a popup window
* Simple graph-based UI with support for branching dialogue.
