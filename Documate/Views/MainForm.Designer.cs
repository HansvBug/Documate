namespace Documate
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            MenuStripMain = new MenuStrip();
            MenuItemProgram = new ToolStripMenuItem();
            MenuItemProgramOpenFile = new ToolStripMenuItem();
            MenuItemProgramCloseFile = new ToolStripMenuItem();
            MenuItemProgramNewFile = new ToolStripMenuItem();
            MenuItemProgramSep1 = new ToolStripSeparator();
            MenuItemProgramExit = new ToolStripMenuItem();
            MenuItemOptions = new ToolStripMenuItem();
            MenuItemOptionsOptions = new ToolStripMenuItem();
            MenuItemLanguage = new ToolStripMenuItem();
            MenuItemLanguageEN = new ToolStripMenuItem();
            MenuItemLanguageNL = new ToolStripMenuItem();
            TabControlMain = new TabControl();
            TabPageReadItems = new TabPage();
            dataGridView1 = new DataGridView();
            TabPageEditItems = new TabPage();
            PanelMain = new Panel();
            panel1 = new Panel();
            TextBoxCtrlObject = new TextBox();
            ButtonSave = new Button();
            GroupBoxRbEditItems = new GroupBox();
            RbSetRelations = new RadioButton();
            RbModify = new RadioButton();
            RbRead = new RadioButton();
            StatusStrip1 = new StatusStrip();
            ToolStripStatusLabel1 = new ToolStripStatusLabel();
            ToolStripStatusLabel2 = new ToolStripStatusLabel();
            ToolStripStatusLabel3 = new ToolStripStatusLabel();
            ToolStripStatusLabel4 = new ToolStripStatusLabel();
            MenuStripMain.SuspendLayout();
            TabControlMain.SuspendLayout();
            TabPageReadItems.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).BeginInit();
            TabPageEditItems.SuspendLayout();
            panel1.SuspendLayout();
            GroupBoxRbEditItems.SuspendLayout();
            StatusStrip1.SuspendLayout();
            SuspendLayout();
            // 
            // MenuStripMain
            // 
            MenuStripMain.ImageScalingSize = new Size(24, 24);
            MenuStripMain.Items.AddRange(new ToolStripItem[] { MenuItemProgram, MenuItemOptions });
            resources.ApplyResources(MenuStripMain, "MenuStripMain");
            MenuStripMain.Name = "MenuStripMain";
            // 
            // MenuItemProgram
            // 
            MenuItemProgram.DropDownItems.AddRange(new ToolStripItem[] { MenuItemProgramOpenFile, MenuItemProgramCloseFile, MenuItemProgramNewFile, MenuItemProgramSep1, MenuItemProgramExit });
            MenuItemProgram.Name = "MenuItemProgram";
            resources.ApplyResources(MenuItemProgram, "MenuItemProgram");
            // 
            // MenuItemProgramOpenFile
            // 
            MenuItemProgramOpenFile.Image = Resources.Images.ImagesMainView.Database_open_24;
            MenuItemProgramOpenFile.Name = "MenuItemProgramOpenFile";
            resources.ApplyResources(MenuItemProgramOpenFile, "MenuItemProgramOpenFile");
            // 
            // MenuItemProgramCloseFile
            // 
            MenuItemProgramCloseFile.Image = Resources.Images.ImagesMainView.Database_close_24;
            MenuItemProgramCloseFile.Name = "MenuItemProgramCloseFile";
            resources.ApplyResources(MenuItemProgramCloseFile, "MenuItemProgramCloseFile");
            // 
            // MenuItemProgramNewFile
            // 
            MenuItemProgramNewFile.Image = Resources.Images.ImagesMainView.Database_new_24;
            MenuItemProgramNewFile.Name = "MenuItemProgramNewFile";
            resources.ApplyResources(MenuItemProgramNewFile, "MenuItemProgramNewFile");
            // 
            // MenuItemProgramSep1
            // 
            MenuItemProgramSep1.Name = "MenuItemProgramSep1";
            resources.ApplyResources(MenuItemProgramSep1, "MenuItemProgramSep1");
            // 
            // MenuItemProgramExit
            // 
            MenuItemProgramExit.Image = Resources.Images.ImagesMainView.Exit_24;
            MenuItemProgramExit.Name = "MenuItemProgramExit";
            resources.ApplyResources(MenuItemProgramExit, "MenuItemProgramExit");
            // 
            // MenuItemOptions
            // 
            MenuItemOptions.DropDownItems.AddRange(new ToolStripItem[] { MenuItemOptionsOptions, MenuItemLanguage });
            MenuItemOptions.Name = "MenuItemOptions";
            resources.ApplyResources(MenuItemOptions, "MenuItemOptions");
            // 
            // MenuItemOptionsOptions
            // 
            MenuItemOptionsOptions.Name = "MenuItemOptionsOptions";
            resources.ApplyResources(MenuItemOptionsOptions, "MenuItemOptionsOptions");
            // 
            // MenuItemLanguage
            // 
            MenuItemLanguage.DropDownItems.AddRange(new ToolStripItem[] { MenuItemLanguageEN, MenuItemLanguageNL });
            MenuItemLanguage.Name = "MenuItemLanguage";
            resources.ApplyResources(MenuItemLanguage, "MenuItemLanguage");
            // 
            // MenuItemLanguageEN
            // 
            MenuItemLanguageEN.Name = "MenuItemLanguageEN";
            resources.ApplyResources(MenuItemLanguageEN, "MenuItemLanguageEN");
            // 
            // MenuItemLanguageNL
            // 
            MenuItemLanguageNL.Name = "MenuItemLanguageNL";
            resources.ApplyResources(MenuItemLanguageNL, "MenuItemLanguageNL");
            // 
            // TabControlMain
            // 
            TabControlMain.Controls.Add(TabPageReadItems);
            TabControlMain.Controls.Add(TabPageEditItems);
            resources.ApplyResources(TabControlMain, "TabControlMain");
            TabControlMain.Name = "TabControlMain";
            TabControlMain.SelectedIndex = 0;
            // 
            // TabPageReadItems
            // 
            TabPageReadItems.Controls.Add(dataGridView1);
            resources.ApplyResources(TabPageReadItems, "TabPageReadItems");
            TabPageReadItems.Name = "TabPageReadItems";
            TabPageReadItems.UseVisualStyleBackColor = true;
            // 
            // dataGridView1
            // 
            dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            resources.ApplyResources(dataGridView1, "dataGridView1");
            dataGridView1.Name = "dataGridView1";
            // 
            // TabPageEditItems
            // 
            TabPageEditItems.Controls.Add(PanelMain);
            TabPageEditItems.Controls.Add(panel1);
            resources.ApplyResources(TabPageEditItems, "TabPageEditItems");
            TabPageEditItems.Name = "TabPageEditItems";
            TabPageEditItems.UseVisualStyleBackColor = true;
            // 
            // PanelMain
            // 
            resources.ApplyResources(PanelMain, "PanelMain");
            PanelMain.Name = "PanelMain";
            // 
            // panel1
            // 
            panel1.Controls.Add(TextBoxCtrlObject);
            panel1.Controls.Add(ButtonSave);
            panel1.Controls.Add(GroupBoxRbEditItems);
            resources.ApplyResources(panel1, "panel1");
            panel1.Name = "panel1";
            // 
            // TextBoxCtrlObject
            // 
            resources.ApplyResources(TextBoxCtrlObject, "TextBoxCtrlObject");
            TextBoxCtrlObject.Name = "TextBoxCtrlObject";
            // 
            // ButtonSave
            // 
            resources.ApplyResources(ButtonSave, "ButtonSave");
            ButtonSave.Name = "ButtonSave";
            ButtonSave.UseVisualStyleBackColor = true;
            ButtonSave.Click += ButtonSave_Click;
            // 
            // GroupBoxRbEditItems
            // 
            GroupBoxRbEditItems.Controls.Add(RbSetRelations);
            GroupBoxRbEditItems.Controls.Add(RbModify);
            GroupBoxRbEditItems.Controls.Add(RbRead);
            resources.ApplyResources(GroupBoxRbEditItems, "GroupBoxRbEditItems");
            GroupBoxRbEditItems.Name = "GroupBoxRbEditItems";
            GroupBoxRbEditItems.TabStop = false;
            // 
            // RbSetRelations
            // 
            resources.ApplyResources(RbSetRelations, "RbSetRelations");
            RbSetRelations.Name = "RbSetRelations";
            RbSetRelations.TabStop = true;
            RbSetRelations.UseVisualStyleBackColor = true;
            // 
            // RbModify
            // 
            resources.ApplyResources(RbModify, "RbModify");
            RbModify.Name = "RbModify";
            RbModify.TabStop = true;
            RbModify.UseVisualStyleBackColor = true;
            // 
            // RbRead
            // 
            resources.ApplyResources(RbRead, "RbRead");
            RbRead.Name = "RbRead";
            RbRead.TabStop = true;
            RbRead.UseVisualStyleBackColor = true;
            // 
            // StatusStrip1
            // 
            StatusStrip1.ImageScalingSize = new Size(24, 24);
            StatusStrip1.Items.AddRange(new ToolStripItem[] { ToolStripStatusLabel1, ToolStripStatusLabel2, ToolStripStatusLabel3, ToolStripStatusLabel4 });
            resources.ApplyResources(StatusStrip1, "StatusStrip1");
            StatusStrip1.Name = "StatusStrip1";
            // 
            // ToolStripStatusLabel1
            // 
            ToolStripStatusLabel1.Name = "ToolStripStatusLabel1";
            resources.ApplyResources(ToolStripStatusLabel1, "ToolStripStatusLabel1");
            // 
            // ToolStripStatusLabel2
            // 
            ToolStripStatusLabel2.Name = "ToolStripStatusLabel2";
            resources.ApplyResources(ToolStripStatusLabel2, "ToolStripStatusLabel2");
            // 
            // ToolStripStatusLabel3
            // 
            ToolStripStatusLabel3.Name = "ToolStripStatusLabel3";
            resources.ApplyResources(ToolStripStatusLabel3, "ToolStripStatusLabel3");
            ToolStripStatusLabel3.Spring = true;
            // 
            // ToolStripStatusLabel4
            // 
            ToolStripStatusLabel4.Name = "ToolStripStatusLabel4";
            resources.ApplyResources(ToolStripStatusLabel4, "ToolStripStatusLabel4");
            // 
            // MainForm
            // 
            resources.ApplyResources(this, "$this");
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(StatusStrip1);
            Controls.Add(TabControlMain);
            Controls.Add(MenuStripMain);
            MainMenuStrip = MenuStripMain;
            Name = "MainForm";
            MenuStripMain.ResumeLayout(false);
            MenuStripMain.PerformLayout();
            TabControlMain.ResumeLayout(false);
            TabPageReadItems.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dataGridView1).EndInit();
            TabPageEditItems.ResumeLayout(false);
            panel1.ResumeLayout(false);
            panel1.PerformLayout();
            GroupBoxRbEditItems.ResumeLayout(false);
            GroupBoxRbEditItems.PerformLayout();
            StatusStrip1.ResumeLayout(false);
            StatusStrip1.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private MenuStrip MenuStripMain;
        private ToolStripMenuItem MenuItemProgram;
        private ToolStripMenuItem MenuItemProgramOpenFile;
        private ToolStripMenuItem MenuItemProgramCloseFile;
        private ToolStripMenuItem MenuItemProgramNewFile;
        private ToolStripSeparator MenuItemProgramSep1;
        private ToolStripMenuItem MenuItemProgramExit;
        private ToolStripMenuItem MenuItemOptions;
        private ToolStripMenuItem MenuItemOptionsOptions;
        private ToolStripMenuItem MenuItemLanguage;
        private ToolStripMenuItem MenuItemLanguageEN;
        private ToolStripMenuItem MenuItemLanguageNL;
        private TabControl TabControlMain;
        private TabPage TabPageReadItems;
        private TabPage TabPageEditItems;
        private DataGridView dataGridView1;
        private Panel panel1;
        private GroupBox GroupBoxRbEditItems;
        private RadioButton RbSetRelations;
        private RadioButton RbModify;
        private RadioButton RbRead;
        private Button ButtonSave;
        private Panel PanelMain;
        private TextBox TextBoxCtrlObject;
        private StatusStrip StatusStrip1;
        public ToolStripStatusLabel ToolStripStatusLabel1;
        public ToolStripStatusLabel ToolStripStatusLabel2;
        private ToolStripStatusLabel ToolStripStatusLabel3;
        private ToolStripStatusLabel ToolStripStatusLabel4;
    }
}
