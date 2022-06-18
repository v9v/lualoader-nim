# lualoader
A project to load .lua files onto ESP8266 chips with NodeMCU firmware. Can be compiled to a single executable.

### Functionality

* Loading .lua files onto chip
	* all it does is send a ``file.putcontents()`` command over serial, but slowly so that the chip can interpret it
* (faulty) Inspecting onboard .lua files
	* sends a ``file.list()`` command and formats the results

### To-Do

* remove the wonky TUI interface and convert to a CLI utility
* fix/remove ``file.list()`` functionality



