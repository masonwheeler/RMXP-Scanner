﻿namespace TURBU.RubyMarshal

partial class MainForm(System.Windows.Forms.Form):
	private components as System.ComponentModel.IContainer = null
	
	protected override def Dispose(disposing as bool) as void:
		if disposing:
			if components is not null:
				components.Dispose()
		super(disposing)
	
	// This method is required for Windows Forms designer support.
	// Do not change the method contents inside the source code editor. The Forms designer might
	// not be able to load this method if it was changed manually.
	private def InitializeComponent():
		self.btnRMProject = System.Windows.Forms.Button()
		self.label1 = System.Windows.Forms.Label()
		self.txtRMProject = System.Windows.Forms.TextBox()
		self.dlgRMLocation = System.Windows.Forms.OpenFileDialog()
		self.button1 = System.Windows.Forms.Button()
		self.txtOutput = System.Windows.Forms.TextBox()
		self.label2 = System.Windows.Forms.Label()
		self.txtItemID = System.Windows.Forms.NumericUpDown()
		self.comboBox1 = System.Windows.Forms.ComboBox()
		self.label3 = System.Windows.Forms.Label()
		self.chkShowAllValues = System.Windows.Forms.CheckBox()
		cast(System.ComponentModel.ISupportInitialize,self.txtItemID).BeginInit()
		self.SuspendLayout()
		# 
		# btnRMProject
		# 
		self.btnRMProject.Anchor = cast(System.Windows.Forms.AnchorStyles,(System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right))
		self.btnRMProject.Font = System.Drawing.Font("Microsoft Sans Serif", 7.8, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, cast(System.Byte,0))
		self.btnRMProject.Location = System.Drawing.Point(605, 12)
		self.btnRMProject.Name = "btnRMProject"
		self.btnRMProject.Size = System.Drawing.Size(33, 23)
		self.btnRMProject.TabIndex = 6
		self.btnRMProject.Text = "..."
		self.btnRMProject.TextAlign = System.Drawing.ContentAlignment.TopCenter
		self.btnRMProject.UseVisualStyleBackColor = true
		self.btnRMProject.Click += self.BtnRMProjectClick as System.EventHandler
		# 
		# label1
		# 
		self.label1.Location = System.Drawing.Point(53, 15)
		self.label1.Name = "label1"
		self.label1.Size = System.Drawing.Size(143, 23)
		self.label1.TabIndex = 7
		self.label1.Text = "RPG Maker File:"
		# 
		# txtRMProject
		# 
		self.txtRMProject.Anchor = cast(System.Windows.Forms.AnchorStyles,(System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right))
		self.txtRMProject.Location = System.Drawing.Point(243, 12)
		self.txtRMProject.Name = "txtRMProject"
		self.txtRMProject.ReadOnly = true
		self.txtRMProject.Size = System.Drawing.Size(356, 22)
		self.txtRMProject.TabIndex = 5
		# 
		# dlgRMLocation
		# 
		self.dlgRMLocation.Filter = "RPG Maker File (*.rxdata) | *.rxdata"
		# 
		# button1
		# 
		self.button1.Anchor = cast(System.Windows.Forms.AnchorStyles,(System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left))
		self.button1.Enabled = false
		self.button1.Location = System.Drawing.Point(207, 348)
		self.button1.Name = "button1"
		self.button1.Size = System.Drawing.Size(75, 23)
		self.button1.TabIndex = 8
		self.button1.Text = "button1"
		self.button1.UseVisualStyleBackColor = true
		self.button1.Click += self.Button1Click as System.EventHandler
		# 
		# txtOutput
		# 
		self.txtOutput.Anchor = cast(System.Windows.Forms.AnchorStyles,((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
						| System.Windows.Forms.AnchorStyles.Left))
		self.txtOutput.Location = System.Drawing.Point(46, 124)
		self.txtOutput.Multiline = true
		self.txtOutput.Name = "txtOutput"
		self.txtOutput.ScrollBars = System.Windows.Forms.ScrollBars.Both
		self.txtOutput.Size = System.Drawing.Size(874, 173)
		self.txtOutput.TabIndex = 9
		# 
		# label2
		# 
		self.label2.Location = System.Drawing.Point(53, 54)
		self.label2.Name = "label2"
		self.label2.Size = System.Drawing.Size(160, 23)
		self.label2.TabIndex = 10
		self.label2.Text = "Operation to scan for:"
		# 
		# txtItemID
		# 
		self.txtItemID.Location = System.Drawing.Point(518, 52)
		self.txtItemID.Maximum = System.Decimal((of int: 10000, 0, 0, 0))
		self.txtItemID.Minimum = System.Decimal((of int: 1, 0, 0, 0))
		self.txtItemID.Name = "txtItemID"
		self.txtItemID.Size = System.Drawing.Size(120, 22)
		self.txtItemID.TabIndex = 12
		self.txtItemID.Value = System.Decimal((of int: 1, 0, 0, 0))
		# 
		# comboBox1
		# 
		self.comboBox1.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
		self.comboBox1.FormattingEnabled = true
		self.comboBox1.Location = System.Drawing.Point(243, 51)
		self.comboBox1.Name = "comboBox1"
		self.comboBox1.Size = System.Drawing.Size(211, 24)
		self.comboBox1.Sorted = true
		self.comboBox1.TabIndex = 13
		self.comboBox1.SelectedIndexChanged += self.ComboBox1SelectedIndexChanged as System.EventHandler
		# 
		# label3
		# 
		self.label3.Location = System.Drawing.Point(460, 54)
		self.label3.Name = "label3"
		self.label3.Size = System.Drawing.Size(52, 23)
		self.label3.TabIndex = 14
		self.label3.Text = "Value:"
		# 
		# chkShowAllValues
		# 
		self.chkShowAllValues.Location = System.Drawing.Point(644, 51)
		self.chkShowAllValues.Name = "chkShowAllValues"
		self.chkShowAllValues.Size = System.Drawing.Size(206, 24)
		self.chkShowAllValues.TabIndex = 15
		self.chkShowAllValues.Text = "ShowAllValues"
		self.chkShowAllValues.UseVisualStyleBackColor = true
		# 
		# MainForm
		# 
		self.AutoScaleDimensions = System.Drawing.SizeF(8, 16)
		self.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
		self.ClientSize = System.Drawing.Size(955, 399)
		self.Controls.Add(self.chkShowAllValues)
		self.Controls.Add(self.label3)
		self.Controls.Add(self.comboBox1)
		self.Controls.Add(self.txtItemID)
		self.Controls.Add(self.label2)
		self.Controls.Add(self.txtOutput)
		self.Controls.Add(self.button1)
		self.Controls.Add(self.btnRMProject)
		self.Controls.Add(self.label1)
		self.Controls.Add(self.txtRMProject)
		self.Name = "MainForm"
		self.Text = "MainForm"
		cast(System.ComponentModel.ISupportInitialize,self.txtItemID).EndInit()
		self.ResumeLayout(false)
		self.PerformLayout()
	private chkShowAllValues as System.Windows.Forms.CheckBox
	private label3 as System.Windows.Forms.Label
	private comboBox1 as System.Windows.Forms.ComboBox
	private txtItemID as System.Windows.Forms.NumericUpDown
	private label2 as System.Windows.Forms.Label
	private txtOutput as System.Windows.Forms.TextBox
	private button1 as System.Windows.Forms.Button
	private dlgRMLocation as System.Windows.Forms.OpenFileDialog
	private txtRMProject as System.Windows.Forms.TextBox
	private label1 as System.Windows.Forms.Label
	private btnRMProject as System.Windows.Forms.Button

