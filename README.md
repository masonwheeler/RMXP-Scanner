# RMXP Scanner
Has the size and complexity of your project ever driven you crazy?  Do you sometimes spend hours looking for where you put that one bit of scripting?  Have you ever come back to something after weeks or months, and you can't find how the pieces of a quest fit together anymore?  RM 2003 had an Event Search command that could help with this, but XP doesn't.

RMXP Scanner is designed to help with that.  It scans every map in your project and looks for event commands that reference a specific object ID, then reports their location.  Suddenly, tracking down missing bits of project logic becomes much simpler!

# How to use
## Project Scanning:
 - Click the ... button next to the Map Location box, and select any file in the `\Data` folder of your project.
 - Select an operation and a value to scan for.  For example, to look for all events that teleport to map #5, select "Teleport To Map" from the "Operation to scan" dropdown menu, and set the number in the Value box to 5.
 - (Optional) If you check the "Show All Values" checkbox, the results will include a raw dump of the parameter data for the event commands that match the scan criteria.  This can be useful to see what location a teleport leads to, for example, or what the value of a variable is set to.
 - Press the "Scan" button.  After a few moments, the results will appear in the text box.

## File Viewing:
To decode the contents of a data file, check the "Decode file data" checkbox.  It will disable project scanning, and instead show the data contained in the file, converted to JSON format.  Among other things, this can be used to determine the codes used in event commands, to write filters.

## Filters:
It's not possible to define everything anyone might ever want to search for ahead of time.  Several of the most common things have been added by default, but you're also free to add your own search criteria.  The criteria used are found in the file `filters.txt`, which RMXP Scanner will place in a `RMXP Scanner` folder inside your My Documents.

## Adding Filters:
 - In the `filters.txt` file is a list of filters that the program can use to search for event commands.  Each one is defined by the word "Filter", followed by a name in quotes, a colon, and a list of criteria.  Each criterion should be on its own line, indented by one Tab.  (Following this style is very important to the parser that reads the filters.  The style should be familiar to anyone who's used the Python programming language, but programming experience isn't necessary to build your own filters.)
 - There are two types of criteria: `Code` and `Value`
  - The `Code` criterion means that the event command's Code has to be equal to the number given.  These values can be found with the File Viewing feature, as described above.  You should generally have a single `Code` criterion on each filter.
  - The `Value` criterion is followed by a number, indicating which value from the event command's `Params` list it checks against.  This should be followed by a comparing operator and a value.  The value can be a number, a text string (which must be in quotes), or the special word `Target`, (no quotes, must be capitalized), which represents the target value entered in the UI.
 - If you have more than one criterion in a filter, *all of them* need to match an event command in order for the event command to be a valid match.
 
# Work In Progress
 Only a limited number of premade event commands have been implemented so far.  More will be added over time.
 
 Only RMXP and VX Ace are supported.  Support for RPG Maker VX is unlikely, as I don't own a copy of RMVX.

 If you have any suggestions on how RMXP Scanner could be improved, or if you run into any bugs, please post them on the Issues for this project.
