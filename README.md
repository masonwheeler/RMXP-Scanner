# RMXP Scanner
Has the size and complexity of your project ever driven you crazy?  Do you sometimes spend hours looking for where you put that one bit of scripting?  Have you ever come back to something after weeks or months, and you can't find how the pieces of a quest fit together anymore?  RM 2003 had an Event Search command that could help with this, but XP doesn't.

RMXP Scanner is designed to help with that.  It scans every map in your project and looks for event commands that reference a specific object ID, then reports their location.  Suddenly, tracking down missing bits of project logic becomes much simpler!

# How to use
 - Click the ... button next to the Map Location box, and select any file in the `\Data` folder of your project.
 - Select an operation and a value to scan for.  For example, to look for all events that teleport to map #5, select "Teleport To Map" from the "Operation to scan" dropdown menu, and set the number in the Value box to 5.
 - (Optional) If you check the "Show All Values" checkbox, the results will include a raw dump of the parameter data for the event commands that match the scan criteria.  This can be useful to see what location a teleport leads to, for example, or what the value of a variable is set to.
 - Press the "Scan" button.  After a few moments, the results will appear in the text box.
 
# Work In Progress
 Only a limited number of event commands have been implemented so far.  More will be added over time.
 
 Only RMXP is supported at the moment.  Support may be added for VX Ace.  VX support is less likely, as I don't own a copy of RMVX.
