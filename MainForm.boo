namespace TURBU.RubyMarshal

import System
import System.IO
import System.Linq.Enumerable
import System.Windows.Forms
import Newtonsoft.Json.Linq
import Boo.Lang.Interpreter

partial class MainForm:
	private _target as int
	private _mapName as string
	private _mapFile as string
	private _extension as string
	private _results = List[of string]()
	private _mapData = System.Collections.Generic.Dictionary[of int, string]()
	private _filters = System.Collections.Generic.Dictionary[of string, Func[of XPEventCommand, int, bool]]()
	private _activeFilter as Func[of XPEventCommand, int, bool]
	
	public def constructor():
		// The InitializeComponent() call is required for Windows Forms designer support.
		InitializeComponent()
		filters = GetFilterText()
		LoadFilters(filters)
	
	private def GetFilterText() as string:
		var path = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), 'RMXP Scanner')
		Directory.CreateDirectory(path) unless Directory.Exists(path)
		path = Path.Combine(path, 'filters.txt')
		if File.Exists(path):
			return File.ReadAllText(path)
		else:
			var result = DefaultFilters.Value
			File.WriteAllText(path, result)
			return result
	
	private def LoadFilters(text as string):
		interpreter = InteractiveInterpreter()
		interpreter.References.Add(System.Reflection.Assembly.GetCallingAssembly())
		var results = interpreter.Eval(`import TURBU.RubyMarshal.Reader
AddFilter as System.Action[of string, System.Func[of TURBU.RubyMarshal.XPEventCommand, int, bool]] = null`)
		System.Diagnostics.Debugger.Break() if results.Errors.Count > 0
		addFilter as System.Action[of string, System.Func[of TURBU.RubyMarshal.XPEventCommand, int, bool]] = self.AddFilter
		interpreter.SetValue('AddFilter', addFilter)
		interpreter.Pipeline.Insert(1, FilterValidator())
		results = interpreter.Eval(text)
		if results.Errors.Count > 0:
			System.Windows.Forms.MessageBox.Show(
				results.Errors.ToString(),
				'Unable to load filters.txt',
				System.Windows.Forms.MessageBoxButtons.OK,
				System.Windows.Forms.MessageBoxIcon.Error)
	
	private def AddFilter(name as string, handler as Func[of XPEventCommand, int, bool]):
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
		vList = values as List
		if vList is not null:
			self.txtOutput.Clear()
			list = System.Collections.Generic.List[of string]()
			for i in range(vList.Count):
				list.Add(Hash2JSON(vList[i]).ToString())
			self.txtOutput.Lines = list.ToArray()
		else:
			self.txtOutput.Text = Hash2JSON(values).ToString()
	
	private def NewMarshal() as RubyMarshal:
		result = RubyMarshal()
		result.AddUnique('Table', Table)
		result.AddUnique('Tone', Tone)
		result.AddUnique('Color', Tone)
		return result
	
	private def ScanProject():
		_target = self.txtItemID.Value
		_results.Clear()
		marshal = RubyMarshal()
		_extension = Path.GetExtension(txtRMProject.Text)
		values = marshal.Read(Path.Combine(Path.GetDirectoryName(txtRMProject.Text), "MapInfos$_extension"))
		LoadMapData(values)
		for filename in Directory.EnumerateFiles(Path.GetDirectoryName(txtRMProject.Text), "Map*$_extension"):
			values = NewMarshal().Read(filename)
			_mapFile = Path.GetFileNameWithoutExtension(filename)
			id as int
			continue unless int.TryParse(_mapFile[3:], id)
			_mapName = _mapData[id]
			CheckMapForMatch(values)
		CheckCommonEventsForMatch(NewMarshal().Read(Path.Combine(Path.GetDirectoryName(txtRMProject.Text), "CommonEvents$_extension")))
		self.txtOutput.Lines = _results.ToArray()
	
	private def LoadMapData(data as Hash):
		
		def ExtractMapName(value) as string:
			return value if value isa string
			hVal = value cast Hash
			return hVal["Object"]
		
		_mapData.Clear()
		for key, value as Hash in array((item.Key, item.Value) for item in (data["Values"] as Hash)):
			assert value["Class"] == "RPG::MapInfo"
			props = value["Values"] as Hash
			_mapData.Add(key, ExtractMapName(props["@name"]))
	
	private def CheckCommonEventsForMatch(value as List):
		for obj as Hash in value:
			continue if obj is null
			assert obj['Class'] == "RPG::CommonEvent"
			values as Hash = obj['Values']
			id as int = values["@id"]
			eventCommands as List = values['@list']
			validSet = GetValidSet( eventCommands.Cast[of Hash]().Select({h | XPEventCommand(h)}) ).ToArray()
			first = true
			for valid in validSet:
				if first:
					_results.Add("$(comboBox1.Text) found at Common Event $id")
					first = false
				if chkShowAllValues.Checked:
					_results.Add("	Values: [$(join(valid.Params, ', '))]")
				else: break
	
	private def CheckMapForMatch(value as Hash):
		assert value['Class'] == "RPG::Map"
		values as Hash = value['Values']
		events as Hash = values['@events'] as Hash
		for eventID, mapEvent as Hash in array((item.Key, item.Value) for item in (events['Values'] as Hash)):
			assert mapEvent['Class'] == "RPG::Event"
			eventValues as Hash = mapEvent['Values']
			assert eventValues['@id'] == eventID
			pages as List = eventValues['@pages']
			x as int = eventValues['@x']
			y as int = eventValues['@y']
			for pageID as int, page as Hash in enumerate(pages):
				CheckPageForMatch(eventID, pageID, page, x, y)
	
	private def CheckPageForMatch(eventID as int, pageID as int, value as Hash, x as int, y as int):
		assert value['Class'] == "RPG::Event::Page"
		values as Hash = value['Values']
		eventCommands as List = values['@list']
		validSet = GetValidSet( eventCommands.Cast[of Hash]().Select({h | XPEventCommand(h)}) ).ToArray()
		first = true
		for valid in validSet:
			if first:
				_results.Add("$(comboBox1.Text) found at \"$_mapName\" ($_mapFile), Event #$eventID ($x, $y), page $(pageID + 1)")
				first = false
			if chkShowAllValues.Checked:
				_results.Add("	Values: [$(join(valid.Params, ', '))]")
			else: break
	
	private def GetValidSet(eventCommands as XPEventCommand*):
		return eventCommands.Where({c | _activeFilter(c, _target)})
	
	private def List2JSON(values as List) as JArray:
		result = JArray()
		for elem as object in values:
			if elem isa Hash:
				result.Add(Hash2JSON(elem))
			elif elem isa List:
				result.Add(List2JSON(elem))
			else: result.Add(elem)
		return result
	
	private def Hash2JSON(value as Hash) as JToken:
		return JValue.CreateNull() if value is null
		
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

public class XPEventCommand:
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
