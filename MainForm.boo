namespace TURBU.RubyMarshal

import System
import System.IO
import System.Linq.Enumerable
import System.Windows.Forms
import Newtonsoft.Json.Linq

partial class MainForm:
	private _target as int
	private _mapName as string
	private _mapFile as string
	private _results = List[of string]()
	private _mapData = System.Collections.Generic.Dictionary[of int, string]()
	private _filters = System.Collections.Generic.Dictionary[of string, Predicate[of XPEventCommand]]()
	private _activeFilter as Predicate[of XPEventCommand]
	
	public def constructor():
		// The InitializeComponent() call is required for Windows Forms designer support.
		InitializeComponent()
		AddFilter('Add Item', {c | c.Code == 126 and c.Params[0] == _target})
		AddFilter('Set Variable', {c | c.Code == 122 and _target >= (c.Params[0] cast int) and _target <= (c.Params[1] cast int)})
		AddFilter('Teleport To Map', {c | c.Code == 201 and _target == c.Params[1] cast int})
	
	private def AddFilter(name as string, handler as Predicate[of XPEventCommand]):
		self.comboBox1.Items.Add(name)
		self._filters.Add(name, handler)
	
	private def BtnRMProjectClick(sender as object, e as System.EventArgs):
		if dlgRMLocation.ShowDialog() == DialogResult.OK:
			self.txtRMProject.Text = dlgRMLocation.FileName
	
	private def Button1Click(sender as object, e as System.EventArgs):
		unless string.IsNullOrEmpty(txtRMProject.Text):
			//ReadFile()
			ScanProject()
	
	private def ReadFile():
		marshal = RubyMarshal()
		marshal.AddUnique('Table', Table)
		marshal.AddUnique('Tone', Tone)
		marshal.AddUnique('Color', Tone)
		values = marshal.Read(txtRMProject.Text)
		self.txtOutput.Text = Hash2JSON(values).ToString()
	
	private def ScanProject():
		_target = self.txtItemID.Value
		_results.Clear()
		marshal = RubyMarshal()
		values = marshal.Read(Path.Combine(Path.GetDirectoryName(txtRMProject.Text), 'MapInfos.rxdata'))
		LoadMapData(values)
		for filename in Directory.EnumerateFiles(Path.GetDirectoryName(txtRMProject.Text), 'Map*.rxdata'):
			marshal = RubyMarshal()
			marshal.AddUnique('Table', Table)
			marshal.AddUnique('Tone', Tone)
			marshal.AddUnique('Color', Tone)
			values = marshal.Read(filename)
			_mapFile = Path.GetFileNameWithoutExtension(filename)
			id as int
			continue unless int.TryParse(_mapFile[3:], id)
			System.Diagnostics.Debugger.Break() if id == 59
			_mapName = _mapData[id]
			CheckMapForMatch(values)
		self.txtOutput.Lines = _results.ToArray()
	
	private def LoadMapData(data as Hash):
		_mapData.Clear()
		for key, value as Hash in array((item.Key, item.Value) for item in (data["Values"] as Hash)):
			assert value["Class"] == "RPG::MapInfo"
			props = value["Values"] as Hash
			_mapData.Add(key, props["@name"])
	
	private def CheckMapForMatch(value as Hash):
		assert value['Class'] == "RPG::Map"
		values as Hash = value['Values']
		events as Hash = values['@events'] as Hash
		for eventID, mapEvent as Hash in array((item.Key, item.Value) for item in (events['Values'] as Hash)):
			assert mapEvent['Class'] == "RPG::Event"
			eventValues as Hash = mapEvent['Values']
			assert eventValues['@id'] == eventID
			pages as List = eventValues['@pages']
			for pageID as int, page as Hash in enumerate(pages):
				CheckPageForMatch(eventID, pageID, page)
	
	private def CheckPageForMatch(eventID as int, pageID as int, value as Hash):
		assert value['Class'] == "RPG::Event::Page"
		values as Hash = value['Values']
		eventCommands as List = values['@list']
		validSet = eventCommands.Cast[of Hash]().Select({h | XPEventCommand(h)}).Where(_activeFilter).ToArray()
		first = true
		for valid in validSet:
			if first:
				_results.Add("$(comboBox1.Text) found at \"$_mapName\" ($_mapFile), Event #$eventID, page $(pageID + 1)")
				first = false
			if chkShowAllValues.Checked:
				_results.Add("	Values: [$(join(valid.Params, ', '))]")
			else: break
	
	private def List2JSON(values as List) as JArray:
		result = JArray()
		for elem as object in values:
			if elem isa Hash:
				result.Add(Hash2JSON(elem))
			elif elem isa List:
				result.Add(List2JSON(elem))
			else: result.Add(elem)
		return result
	
	private def Hash2JSON(value as Hash) as JObject:
		result = JObject()
		enumerator = value.GetEnumerator()
		while enumerator.MoveNext():
			entry = enumerator.Entry
			elem as object = entry.Value
			if elem isa Hash:
				elem = Hash2JSON(elem)
			elif elem isa List:
				elem = List2JSON(elem)
			key as object = entry.Key
			key = Hash2JSON(key).ToString().Replace('\r\n', '') if key isa Hash
			result.Add(key.ToString(), elem)
		return result
	
	private def ComboBox1SelectedIndexChanged(sender as object, e as System.EventArgs):
		_activeFilter = _filters[comboBox1.Text]
		button1.Enabled = true

private class XPEventCommand:
	[Getter(Params)]
	_params = []
	[Getter(Code)]
	_code as int
	
	def constructor(value as Hash):
		assert value["Class"] == "RPG::EventCommand"
		values as Hash = value["Values"]
		for param in values["@parameters"]:
			if param isa Hash:
				pHash = param cast Hash
				if pHash["Type"] == 'IVAR':
					_params.Add(pHash["Object"])
				else: _params.Add(pHash)
			else: _params.Add(param)
		_code = values["@code"]

[STAThread]
public def Main(argv as (string)) as void:
	Application.EnableVisualStyles()
	Application.SetCompatibleTextRenderingDefault(false)
	Application.Run(MainForm())
