using Documate.Library;
using static Documate.Library.StatusStripHelper;
using System.Data;

namespace Documate.Models
{
    public class CreateControls : ICreateControls
    {
        private readonly IAppDbMaintainModel _appDbMaintainModel;
        private readonly LoggingModel _loggingModel;
        private readonly IDataGridViewModel _dataGridViewModel;
        private readonly IAppDbCreateModel _appDbCreateModel;

        private bool _componentsCreated = false;
        //private TabPage? _tabPage;
        private Panel? _panel;
        private int _numberOfPanels = -1;

        private readonly List<Control> _controls = [];
        private readonly List<Control> _controlsHeader = [];
        private readonly List<Control> _controlsMiddle = [];
        private readonly List<Control> _controlsBottom = [];

        private const string _panelBodyName = "PanelBody_";
        private const string PanelHeaderName = "PanelHeader_";
        private const string PanelSearchName = "PanelSearch_";
        private const string PanelMiddleName = "PanelMiddle_";

        public bool ComponentsCreated
        {
            get => _componentsCreated;
            set => _componentsCreated = value;
        }


        public CreateControls(IAppDbMaintainModel appDbMaintainModel, LoggingModel loggingModel, IDataGridViewModel dataGridViewModel, IAppDbCreateModel appDbCreateModel)
        {
            _appDbMaintainModel = appDbMaintainModel;
            _loggingModel = loggingModel;
            _dataGridViewModel = dataGridViewModel;
            _appDbCreateModel = appDbCreateModel;

            //Console.WriteLine($"Nieuwe instantie van DataGridViewModel: {this.GetHashCode()}");

        }
        public void CreateComponents(string DatabaseFileName, Panel APanel)
        {
            Cursor.Current = Cursors.WaitCursor;
            DocumateUtils.LevelCount = _appDbMaintainModel.GetColCount();

            _panel = APanel ?? throw new InvalidOperationException(LocalizationHelper.GetString("TabPageIsMissing", LocalizationPaths.CreateControls));

            if (DocumateUtils.LevelCount > 0)
            {
                SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("GettingReady", LocalizationPaths.CreateControls));
                
                _appDbCreateModel.CloseDatabaseConnection();
                RemoveComponents(APanel);
                CreateAllComponents(DocumateUtils.LevelCount, APanel);
            }

            Cursor.Current = Cursors.Default;
        }

        public void RemoveComponents(Panel APanel)
        {
            foreach (Control c in APanel.Controls)
            {
                if (c is SplitContainer splitContainer)
                {
                    splitContainer.Panel1.Controls.Clear();
                    splitContainer.Panel2.Controls.Clear();

                    c.Dispose();  // Remove the SplitContainer.
                }
            }


            _controls.Clear();
            _controlsHeader.Clear();
            _controlsMiddle.Clear();
            _controlsBottom.Clear();
            DataGridViewHelper.ClearDgv();
        }
        private void CreateAllComponents(int numberOfPanels, Panel APanel)
        {
            APanel.SuspendLayout();
            _numberOfPanels = numberOfPanels;

            SplitContainer splitContainer = new()
            {
                Dock = DockStyle.Fill,
                Name = "MainSplitContainer",
                Orientation = Orientation.Vertical,
                SplitterDistance = 50                
            };
            splitContainer.Panel2.AutoScroll = true;

            APanel.Controls.Add(splitContainer);

            CreateBodyPanelsAndSplitters(splitContainer.Panel1);
            AddBodyPanelsToForm(splitContainer.Panel2);

            CreateSubPanels(PanelHeaderName, DockStyle.Top, Color.AliceBlue, BorderStyle.FixedSingle);  // BlueViolet
            CreateSubPanels(PanelSearchName, DockStyle.Bottom, Color.AliceBlue, BorderStyle.FixedSingle);   // Bisque
            CreateSubPanels(PanelMiddleName, DockStyle.Fill, Color.AliceBlue, BorderStyle.FixedSingle);      // Coral

            // Place the controls on the panels
            AddSubPanelsToBodyPanel();

            CreatedatagridViews();
            AddNewComponentsToMiddlePanel();

            APanel.ResumeLayout();
            ComponentsCreated = true;  // TODO; wordt dit gebruikt?
        }

        private void CreateBodyPanelsAndSplitters(Panel panelLeft)
        {
            int childindex = 0;

            for (int i = 1; i <= _numberOfPanels; i++)
            {
                if (i == 1)
                {                    
                    Panel p = CreatePanel(i, DockStyle.Fill, _panelBodyName, Color.AliceBlue, BorderStyle.None);
                    panelLeft.Controls.Add(p);                    
                }
                else
                {
                    if (i < _numberOfPanels)
                    {
                        Panel p = CreatePanel(i, DockStyle.Left, _panelBodyName, Color.AliceBlue, BorderStyle.None);
                        p.Tag = childindex;
                        _controls.Add(p);

                        childindex++;

                        Splitter s = CreateSplitter(i);
                        s.Tag = childindex;
                        _controls.Add(s);

                        childindex++;
                    }
                    else
                    {
                        Panel p = CreatePanel(i, DockStyle.Fill, _panelBodyName, Color.AliceBlue, BorderStyle.None);
                        
                        p.Tag = childindex;
                        _controls.Add(p);
                    }                    
                }
            }
        }

        private void CreateSubPanels(string panelType, DockStyle dockStyle, Color color, BorderStyle borderStyle)
        {
            for (int i = 1; i <= _numberOfPanels; i++)
            {
                Panel p = CreatePanel(i, dockStyle, panelType, color, borderStyle);

                if (panelType == PanelHeaderName)
                {
                    p.Tag = 2;
                    _controlsHeader.Add(p);
                }
                else if (panelType == PanelMiddleName)
                {
                    p.Tag = 1;
                    _controlsMiddle.Add(p);
                }
                else if (panelType == PanelSearchName)
                {
                    p.Tag = 0;
                    _controlsBottom.Add(p);
                }
            }
        }
        private void AddBodyPanelsToForm(Panel panelRight)
        {
            // Sort tho components before placing on the form.
            List<Control> sortedList = [.. _controls.OrderByDescending(o => o.Tag)];

            int i = 1;
            foreach (Control c in sortedList)
            {
                panelRight.Controls.Add(c);
                panelRight.Controls.SetChildIndex(c, i);
                i++;
            }
        }

        private void AddSubPanelsToBodyPanel()
        {
            if (_panel != null)
            {
                int panelNumber;

                foreach (Control c in _panel.Controls)
                {
                    if (c is SplitContainer splitContainer)
                    {
                        foreach (Panel splitPanel in new[] { splitContainer.Panel1, splitContainer.Panel2 })
                        {                            
                            foreach (Control bodyControl in splitPanel.Controls)
                            {
                                string tmp = bodyControl.Name;

                                panelNumber = ExtractDigets(bodyControl.Name);

                                foreach (Control ctrlMiddle in _controlsMiddle) // this must be assigned firtst!
                                {
                                    if (ExtractDigets(ctrlMiddle.Name) == panelNumber)
                                    {
                                        ctrlMiddle.Dock = DockStyle.Fill;
                                        bodyControl.Controls.Add(ctrlMiddle);
                                    }
                                }

                                foreach (Control ctrlHeader in _controlsHeader)
                                {
                                    if (ExtractDigets(ctrlHeader.Name) == panelNumber)
                                    {
                                        ctrlHeader.Dock = DockStyle.Top;
                                        bodyControl.Controls.Add(ctrlHeader);
                                    }
                                }

                                foreach (Control ctrlBottom in _controlsBottom)
                                {
                                    if (ExtractDigets(ctrlBottom.Name) == panelNumber)
                                    {
                                        ctrlBottom.Parent = bodyControl;
                                        bodyControl.Controls.Add(ctrlBottom);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorPlacingSubpanels", LocalizationPaths.CreateControls));
            }
        }

        private static Panel CreatePanel(int panelNumber, DockStyle dockStyle, string panelType, Color color, BorderStyle borderStyle)
        {
            // Create a dynamic panel
            Panel dynamicPanel = new()
            {
                Name = panelType + panelNumber.ToString(),
                Size = new Size(100, 50),
                Location = new Point(10, 10),
                BackColor = color,
                BorderStyle = borderStyle, //BorderStyle.FixedSingle,
                Dock = dockStyle,
                AutoSize = false,
            };

            
            // Add a label to the panel during debuging
            /*dynamicPanel.Controls.Add(new Label()
            {
                Text = dynamicPanel.Name,
                Location = new Point(1, 1)
            });*/
            

            return dynamicPanel;
        }

        private static Splitter CreateSplitter(int splitterNumber)
        {
            Splitter splitter = new()
            {
                Name = "SPLITTER_" + splitterNumber.ToString(),
                Dock = DockStyle.Left,
                Width = 5,
               // BackColor = Color.DodgerBlue,
                Location = new Point(0, 0),
            };

            return splitter;
        }

        private void CreatedatagridViews()
        {
            _controls.Clear();  // A list used for placing the component on the Middle panel.
            DataGridViewHelper.ClearDgv();

            for (int i = 1; i <= _numberOfPanels; i++)
            {
                DataGridView dgv = CreateDataGridView(i);
                dgv.BackgroundColor = SystemColors.Window;

                // Link the event handlers via the helper class.
                dgv.CellValueChanged += _dataGridViewModel.HandleCellValueChanged!;
                dgv.RowsAdded += _dataGridViewModel.HandleRowsAdded!;
                dgv.RowLeave += _dataGridViewModel.RowLeave!;
                dgv.CellClick += _dataGridViewModel.CellClicked!;
                dgv.CurrentCellChanged += _dataGridViewModel.CurrentCellChanged!;

                dgv.RowValidating += _dataGridViewModel.RowValidating!;
                dgv.KeyDown += _dataGridViewModel.KeyDown!;

                _controls.Add(dgv);
                DataGridViewHelper.AddDgv(dgv);  // Store the DataGridViews. They are used a lot later on.
            }
        }

        private static DataGridView CreateDataGridView(int datagridViewNumber)
        {
            DataGridView dgv = new()
            {
                Name = "DGV_" + datagridViewNumber.ToString(),
                Location = new Point(5, 5),
                Dock = DockStyle.Fill,
                RowHeadersVisible = false,
                ColumnHeadersVisible = false,
                //CellBorderStyle = DataGridViewCellBorderStyle.None,
                GridColor = Color.LightGray,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None,  // Do not autosize the colomn width
                ScrollBars = ScrollBars.Both,
                BorderStyle = BorderStyle.None,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                AllowUserToResizeRows = false,
                AutoGenerateColumns = false,
            };

            // Create a DataTable for the DataGridView and bind it to the DataGridView.
            BindingSource bs = new()
            {
                DataSource = CreateDataTable(datagridViewNumber)
            };

            dgv.DataSource = bs;

            /*
            dgv.Columns.Add(new DataGridViewCheckBoxColumn
            {
                Name = "Guid",
                HeaderText = "Guid",
                DataPropertyName = "Guid", // Koppel aan de DataTable-kolom
                Width = 50
            });

            dgv.Columns.Add(new DataGridViewCheckBoxColumn
            {
                Name = "Level",
                HeaderText = "Level",
                DataPropertyName = "Level", // Koppel aan de DataTable-kolom
                Width = 5
            });*/

            dgv.Columns.Add(new DataGridViewCheckBoxColumn
            {
                Name = "Parent",
                HeaderText = "Parent",
                DataPropertyName = "Parent", // Koppel aan de DataTable-kolom
                Width = 50
            });

            dgv.Columns.Add(new DataGridViewCheckBoxColumn
            {
                Name = "Child",
                HeaderText = "Child",
                DataPropertyName = "Child", // Koppel aan de DataTable-kolom
                Width = 50
            });

            dgv.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "Name",
                HeaderText = "Description",
                DataPropertyName = "Name", // Koppel aan de DataTable-kolom
                Width = 200,
                AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill,  // auto fill the last column.
            });

            // TEST extre kolom om object in op te slaan
            dgv.Columns.Add(new DataGridViewTextBoxColumn
            {
                Name = "ItemObject",
                HeaderText = "ItemObject",
                DataPropertyName = "ItemObjecct", // Koppel aan de DataTable-kolom
                Width = 50,
            });

            dgv.ColumnHeadersVisible = true;
            return dgv;
        }

        private static DataTable CreateDataTable(int dataTableNumber)
        {
            DataTable dt = new()
            {
                TableName = "DATATABLE_" + dataTableNumber.ToString(),
            };

            dt.Columns.Add("Guid", typeof(string));
            dt.Columns.Add("Level", typeof (int));
            dt.Columns.Add("Parent", typeof(bool));
            dt.Columns.Add("Child", typeof(bool));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("ItemObject", typeof(object));

            //dt.Rows.Add(false, false, "Row 1");  // For test/debug.
            //dt.Rows.Add(true, false, "Row 2");  // For test/debug.

            return dt;
        }

        private void AddNewComponentsToMiddlePanel()
        {
            if (_panel != null)
            {
                int panelNumber;

                foreach (Control c in _controlsMiddle)
                {
                    if (c is Panel middlePanel && middlePanel.Name.Contains(PanelMiddleName))
                    {
                        panelNumber = ExtractDigets(middlePanel.Name);

                        foreach (Control ctrl in _controls.Where(ctrl => ExtractDigets(ctrl.Name) == panelNumber))
                        {
                            ctrl.Dock = DockStyle.Fill; // Zorg dat de DataGridView de ruimte van het paneel volledig vult
                            middlePanel.Controls.Add(ctrl);
                        }
                    }
                }
            }
            else
            {
                _loggingModel.WriteToLog(Common.LogAction.ERROR, LocalizationHelper.GetString("ErrorPlacingSubpanels", LocalizationPaths.CreateControls));
            }
        }
        private static int ExtractDigets(string input)
        {
            string output = string.Empty;
            for (int i = 0; i < input.Length; i++)
            {
                if (Char.IsDigit(input[i]))
                    output += input[i];
            }
            return int.Parse(output);
        }
    }
}
