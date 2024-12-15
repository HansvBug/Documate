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
            statusStrip1 = new StatusStrip();
            ToolStripStatusLabel1 = new ToolStripStatusLabel();
            ToolStripStatusLabel2 = new ToolStripStatusLabel();
            TabControlMain = new TabControl();
            TabPageReadItems = new TabPage();
            TabPageEditItems = new TabPage();
            dataGridView1 = new DataGridView();
            MenuStripMain.SuspendLayout();
            statusStrip1.SuspendLayout();
            TabControlMain.SuspendLayout();
            TabPageReadItems.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)dataGridView1).BeginInit();
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
            // statusStrip1
            // 
            statusStrip1.ImageScalingSize = new Size(24, 24);
            statusStrip1.Items.AddRange(new ToolStripItem[] { ToolStripStatusLabel1, ToolStripStatusLabel2 });
            resources.ApplyResources(statusStrip1, "statusStrip1");
            statusStrip1.Name = "statusStrip1";
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
            // TabPageEditItems
            // 
            resources.ApplyResources(TabPageEditItems, "TabPageEditItems");
            TabPageEditItems.Name = "TabPageEditItems";
            TabPageEditItems.UseVisualStyleBackColor = true;
            // 
            // dataGridView1
            // 
            dataGridView1.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            resources.ApplyResources(dataGridView1, "dataGridView1");
            dataGridView1.Name = "dataGridView1";
            // 
            // MainForm
            // 
            resources.ApplyResources(this, "$this");
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(TabControlMain);
            Controls.Add(statusStrip1);
            Controls.Add(MenuStripMain);
            MainMenuStrip = MenuStripMain;
            Name = "MainForm";
            MenuStripMain.ResumeLayout(false);
            MenuStripMain.PerformLayout();
            statusStrip1.ResumeLayout(false);
            statusStrip1.PerformLayout();
            TabControlMain.ResumeLayout(false);
            TabPageReadItems.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)dataGridView1).EndInit();
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
        private StatusStrip statusStrip1;
        private ToolStripStatusLabel ToolStripStatusLabel1;
        private ToolStripStatusLabel ToolStripStatusLabel2;
        private TabControl TabControlMain;
        private TabPage TabPageReadItems;
        private TabPage TabPageEditItems;
        private DataGridView dataGridView1;
    }
}
