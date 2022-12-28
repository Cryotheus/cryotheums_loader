# Cryotheum's Loader
Named as so because I needed a unique namespace but it was 3 am so give me a break.  
Directory style loader with useful features! These features are:
 *  Easy to customize load order
 *  Loading conditions
 *  Load timings
 *  Maintenance free extension loading (coming soon)

### Setup Instruction
Change the locals in scope zero (everything above the `do` block) to your project's specification. You must set `branding` to something unique, like the name of your addon.  
Place this in a custom folder in the lua directory of your project eg. `addons/johns_admin_tool/lua/johnsadmtool/loader.lua` or `gamemodes/nut_destroyer/gamemode/loader.lua` and include it from somewhere.  
**DON'T**
 *  Use this loader directly from `autorun` (including `autorun/client` and `autorun/server`)
 *  Set `branding` to a really short acronym or something potentially ubiquitous.
 *  Use dark colors in the configurable locals (this can cause the messages on 32 bit windows servers to be black, which on a black background console turns them invisible)
 *  A thousand load orders. That would look stupid.
 *  Load the loader from itself.
**DO**
 *  Have a file with the addon name in `autorun` that includes the loader, eg. `autorun/ez_screen_capture.lua` containing `include("ez_screen_capture/loader.lua")` and nothing else.
 *  Use a unique branding name, like the name of your addon or gamemode.
 *  Use light colors in the configurable locals.
 *  Use a reasonable amount of load orders; 2 to 4 is the usual amount for medium sized projects (6-20 files).
 *  Set the loader to `"download"` in the `config` local, eg. `loader = "download"`.
 *  Leave the link to this repository in the loader file.

### Config
The structure of the `config` local table is specified in the script itself.  
Values in the `config` can be:
 *  A string, which is the loading instruction
 *  A table, which is a directory of files to load
 *  A boolean, which when `true` is the same as the file name (`false` prevents loading)
The load instruction should be styled like so: `"method modifier complex_modifier:parameter timing"`  
You should only have one method and one timing, but you can have as many modifiers as you want.  
The order of the modifiers is the order they will be checked in.  
Although not currently used, complex modifiers can have multiple parameters, separated by a a colon (eg. `"custom_complex_modifier:Canada:31415926:github.com"`)

#### Loading Methods
Must go first.
|    Method    | Description
| :----------: | ---
|  `"client"`   | Loads on the client and server, but only AddCSLuaFile's on the server.
| `"download"`  | Only AddCSLuaFile's on the server.
|  `"server"`   | Only loads on the server.
|  `"shared"`   | Loads on the client and server, and AddCSLuaFile's on the server.
|   `false`     | Completely ignored: Doesn't load. Doesn't check modifiers.
|    `true`     | Same as the file name.
| Anything else | Same as `false`.

#### Loading Modifiers
|     Modifier     | Parameters  | Description
| :--------------: | ----------- | --- 
|  `"dedicated"`   |             | Only loads on dedicated servers.
|  `"developer"`   |             | Only loads if the `developer` convar is set.
|   `"hosted"`     |             | Only loads on listen or dedicated servers.
|  `"if_addon"`    | Workshop ID | Only loads if the specified addon is installed.
| `"if_gamemode"`  | Global name | Only loads if the specified gamemode is selected.
|  `"if_global"`   | Global name | Only loads if the specified global exists.
|   `"listen"`     |             | Only loads on listen servers.
|  `"no_addon"`    | Workshop ID | Only loads if the specified addon is not installed.
| `"no_gamemode"`  | Global name | Only loads if the specified gamemode is not selected.
|  `"no_global"`   | Global name | Only loads if the specified global does not exist.
|   `"simple"`     |             | Only loads on listen or single player servers.
|   `"single"`     |             | Only loads on single player servers.
|                  |             |
| Timing Modifiers | Parameters  | Modifiers that delay the script's load. Only one should be used, always should be last.
|    `"await"`     | Hook name   | Loads when the specified hook is called, all loads afterwards are instantaneous.
|   `"gamemode"`   |             | Same as `"await:Initialize"`.
|     `"hook"`     | Hook name   | Loads every time the hook is called. Use `"await"` instead if you want to delay a load until the hook is called.
|    `"player"`    |             | Same as `"await:PlayerInitialSpawn"`.
|    `"world"`     |             | Same as `"await:InitPostEntity"`.