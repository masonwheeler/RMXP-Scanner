namespace TURBU.RubyMarshal

import System
import System.Collections.Generic
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
	
	private def chkReadFileClick(sender as object, e as System.EventArgs):
		if chkReadFile.Checked:
			button1.Enabled = not string.IsNullOrEmpty(self.txtRMProject.Text)
		else:
			button1.Enabled = not string.IsNullOrEmpty(comboBox1.Text)
	
	private def BtnRMProjectClick(sender as object, e as System.EventArgs):
		if dlgRMLocation.ShowDialog() == DialogResult.OK:
			self.txtRMProject.Text = dlgRMLocation.FileName
			button1.Enabled = true if chkReadFile.Checked
	
	private def Button1Click(sender as object, e as System.EventArgs):
		unless string.IsNullOrEmpty(txtRMProject.Text):
			if chkReadFile.Checked:
				ReadFile()
			else: ScanProject()
	
	private def ReadFile():
		marshal = RubyMarshal()
		marshal.AddUnique('Table', Table)
		marshal.AddUnique('Tone', Tone)
		marshal.AddUnique('Color', Tone)
		values = marshal.Read(txtRMProject.Text)
		vList = values as Boo.Lang.List
		if vList is not null:
			self.txtOutput.Clear()
			list = System.Collections.Generic.List[of string]()
			for i in range(vList.Count):
				list.Add(Hash2JSON(vList[i]).ToString())
			self.txtOutput.Lines = list.ToArray()
		else:
			values = Hash2JSON(values)
			self.txtOutput.Text = values.ToString()
			JsonToTree(Path.GetFileName(txtRMProject.Text), values)
	
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
	
	private def CheckCommonEventsForMatch(value as Boo.Lang.List):
		for obj as Hash in value:
			continue if obj is null
			assert obj['Class'] == "RPG::CommonEvent"
			values as Hash = obj['Values']
			id as int = values["@id"]
			eventCommands as Boo.Lang.List = values['@list']
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
			pages as Boo.Lang.List = eventValues['@pages']
			x as int = eventValues['@x']
			y as int = eventValues['@y']
			for pageID as int, page as Hash in enumerate(pages):
				CheckPageForMatch(eventID, pageID, page, x, y)
	
	private def CheckPageForMatch(eventID as int, pageID as int, value as Hash, x as int, y as int):
		assert value['Class'] == "RPG::Event::Page"
		values as Hash = value['Values']
		eventCommands as Boo.Lang.List = values['@list']
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
	
	private def List2JSON(values as Boo.Lang.List) as JArray:
		result = JArray()
		for elem as object in values:
			if elem isa Hash:
				result.Add(Hash2JSON(elem))
			elif elem isa Boo.Lang.List:
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
			elif elem isa Boo.Lang.List:
				elem = List2JSON(elem)
			key as object = entry.Key
			key = Hash2JSON(key).ToString().Replace('\r\n', '') if key isa Hash
			result.Add(key.ToString(), elem)
		return result
	
	private def ComboBox1SelectedIndexChanged(sender as object, e as System.EventArgs):
		_activeFilter = _filters[comboBox1.Text]
		button1.Enabled = true

	// The routines JsonToTree and Json2Tree are adapted from code found at
	// http://stackoverflow.com/a/29260447/32914
	private def JsonToTree(filename as string, obj as JObject):
		try:
			tvwDisplay.Nodes.Clear()
			parent as TreeNode = Json2Tree(obj)
			parent.Text = filename
			tvwDisplay.Nodes.Add(parent)
		except ex as Exception:
			MessageBox.Show(ex.Message, 'ERROR')

	private def Json2Tree(obj as JObject) as TreeNode:
		//create the parent node
		//loop through the obj. all token should be pair<key, value>
		//change the display Content of the parent
		//create the child node
		//check if the value is of type obj recall the method
		// child.Text = token.Key.ToString();
		//create a new JObject using the the Token.value
		o as JObject
		parent = TreeNode()
		for token as KeyValuePair[of string, JToken] in obj:
			key as string = token.Key.ToString()
			continue if key == 'Type'
			child = TreeNode()
			if token.Value.Type.ToString() == 'Object':
				o = (token.Value cast JObject)
				//recall the method
				child = Json2Tree(o)
				//add the child to the parentNode
				parent.Nodes.Add(child)
			elif token.Value.Type.ToString() == 'Array':
			//if type is of array
				ix as int = (-1)
				//  child.Text = token.Key.ToString();
				//loop though the array
				for itm in token.Value:
					//check if value is an Array of objects
					if itm.Type.ToString() == 'Object':
						objTN = TreeNode()
						//child.Text = token.Key.ToString();
						//call back the method
						ix += 1
						
						o = (itm cast JObject)
						objTN = Json2Tree(o)
						objTN.Text = (((token.Key.ToString() + '[') + ix) + ']')
						child.Nodes.Add(objTN)
					elif itm.Type.ToString() == 'Array':
					//parent.Nodes.Add(child);
					//regular array string, int, etc
						ix += 1
						dataArray = TreeNode()
						for data in itm:
							dataArray.Text = (((token.Key.ToString() + '[') + ix) + ']')
							dataArray.Nodes.Add(data.ToString())
						child.Nodes.Add(dataArray)
					else:
						
						child.Nodes.Add(itm.ToString())
				parent.Nodes.Add(child)
			else:
				//if token.Value is not nested
				// child.Text = token.Key.ToString();
				//change the value into N/A if value == null or an empty string 
				if token.Value.ToString() == '':
					child.Nodes.Add('N/A')
				else:
					child.Nodes.Add(token.Value.ToString())
				parent.Nodes.Add(child)
			child.Text = token.Key.ToString()
		return parent
		

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
